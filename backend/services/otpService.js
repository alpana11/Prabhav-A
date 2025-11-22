const logger = require('../logger');
const crypto = require('crypto');
const OtpLog = require('../models/OtpLog');
const OtpVerification = require('../models/OtpVerification');

const OTP_EXPIRY_MS = parseInt(process.env.OTP_EXPIRY_MS || `${10 * 60 * 1000}`, 10); // 10 minutes default
const OTP_RESEND_DELAY_MS = parseInt(process.env.OTP_RESEND_DELAY_MS || `${30 * 1000}`, 10); // 30 seconds between resends
const MAX_VERIFY_ATTEMPTS = parseInt(process.env.MAX_VERIFY_ATTEMPTS || '5', 10);
const OTP_SALT = process.env.OTP_SALT || 'otp-default-salt';

function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Persist and send OTP via SMS. OTPs are stored hashed in MongoDB (OtpVerification).
 */
async function sendOtp(aadhar, phone) {
  try {
    if (!aadhar || aadhar.length !== 12 || !/^\d{12}$/.test(aadhar)) {
      throw new Error('Invalid Aadhar number');
    }
    if (!phone || !/^\d{10}$/.test(phone.replace(/\D/g, ''))) {
      throw new Error('Invalid phone number');
    }

    // Rate limit: check most recent OTP for this aadhar
    const recent = await OtpVerification.findOne({ aadhar }).sort({ sentAt: -1 });
    if (recent && Date.now() - new Date(recent.sentAt).getTime() < OTP_RESEND_DELAY_MS) {
      const waitMs = OTP_RESEND_DELAY_MS - (Date.now() - new Date(recent.sentAt).getTime());
      const waitSec = Math.ceil(waitMs / 1000);
      logger.warn(`[OTP] Rate limited: ${aadhar} requested too soon`);
      return { success: false, message: `Please wait ${waitSec} seconds before requesting another OTP` };
    }

    const otp = generateOTP();
    const now = Date.now();
    const otpHash = crypto.createHash('sha256').update(otp + OTP_SALT).digest('hex');

    // Create a DB verification entry before sending (will be marked verified on success)
    const entry = new OtpVerification({
      aadhar,
      phone,
      otpHash,
      sentAt: new Date(now),
      expiresAt: new Date(now + OTP_EXPIRY_MS),
      attempts: 0,
      verified: false,
      success: false,
    });

    await entry.save();

    // Try to send real SMS via configured provider
    const smsService = require('./smsService');
    let smsResult = { success: false };
    
    try {
      smsResult = await smsService.sendOTP(phone, otp);
      if (smsResult.success) {
        logger.info(`[OTP] SMS sent successfully via ${smsResult.provider || 'unknown'} to ${phone}`);
      } else {
        logger.warn(`[OTP] SMS sending failed: ${smsResult.message || 'Unknown error'}`);
      }
    } catch (smsError) {
      logger.error(`[OTP] SMS sending error: ${smsError.message}`);
      // Continue even if SMS fails - OTP is still stored in DB
    }

    // Add an OtpLog record for auditing
    const logEntry = new OtpLog({
      aadharEncrypted: aadhar,
      phone,
      otpHash,
      provider: smsResult.provider || 'unknown',
      sentAt: new Date(now),
      expiresAt: new Date(now + OTP_EXPIRY_MS),
      attempts: 0,
      success: smsResult.success,
    });
    await logEntry.save();

    if (smsResult.success) {
      logger.info(`[OTP] OTP sent via SMS to ${phone} for Aadhar ${aadhar}`);
      return { 
        success: true, 
        message: 'OTP sent successfully via SMS', 
        provider: smsResult.provider,
        aadhar: aadhar 
      };
    } else {
      // If SMS fails, still return success but warn user
      logger.warn(`[OTP] OTP generated but SMS not sent. OTP stored in DB: ${otp}`);
      return { 
        success: true, 
        message: 'OTP generated. SMS delivery may have failed. Please check your phone or contact support.', 
        provider: 'fallback',
        aadhar: aadhar,
        warning: 'SMS delivery failed - OTP stored in database'
      };
    }
  } catch (error) {
    logger.error(`[OTP] sendOtp error: ${error.message}`);
    return { success: false, message: error.message || 'Error sending OTP' };
  }
}

/**
 * Verify OTP against the latest not-yet-verified DB entry
 */
async function verifyOtp(aadhar, otp) {
  try {
    const record = await OtpVerification.findOne({ aadhar, verified: false }).sort({ sentAt: -1 });
    if (!record) {
      logger.warn(`[OTP] No record for ${aadhar}`);
      return { success: false, message: 'OTP not found. Please request a new OTP.' };
    }

    if (Date.now() > new Date(record.expiresAt).getTime()) {
      await OtpVerification.deleteOne({ _id: record._id });
      logger.warn(`[OTP] Expired for ${aadhar}`);
      return { success: false, message: 'OTP has expired. Please request a new one.' };
    }

    if (record.attempts >= MAX_VERIFY_ATTEMPTS) {
      await OtpVerification.deleteOne({ _id: record._id });
      logger.warn(`[OTP] Max attempts exceeded for ${aadhar}`);
      return { success: false, message: 'Too many failed attempts. Please request a new OTP.' };
    }

    const otpHash = crypto.createHash('sha256').update(otp + OTP_SALT).digest('hex');
    if (otpHash !== record.otpHash) {
      record.attempts += 1;
      await record.save();
      const remaining = MAX_VERIFY_ATTEMPTS - record.attempts;
      logger.warn(`[OTP] Invalid OTP for ${aadhar} (attempt ${record.attempts}/${MAX_VERIFY_ATTEMPTS})`);
      return { success: false, message: `Invalid OTP. ${remaining} attempt${remaining === 1 ? '' : 's'} remaining.`, attempts: record.attempts };
    }

    // Mark verified
    record.verified = true;
    record.success = true;
    await record.save();

    // Mark OtpLog success if present
    try {
      const log = await OtpLog.findOne({ aadharEncrypted: aadhar, phone: record.phone, otpHash }).sort({ sentAt: -1 });
      if (log) {
        log.success = true;
        log.attempts = record.attempts;
        await log.save();
      }
    } catch (e) {
      logger.warn(`[OTP] Could not mark otp log success for ${aadhar}: ${e.message}`);
    }

    logger.info(`[OTP] Verified successfully for ${aadhar}`);
    return { success: true, message: 'OTP verified successfully' };
  } catch (error) {
    logger.error(`[OTP] verifyOtp error: ${error.message}`);
    return { success: false, message: 'Error verifying OTP' };
  }
}

/**
 * Verify a prepared OTP entry by matching a phone that was verified via Firebase
 * @param {string} aadhar
 * @param {string} phoneNormalized - could be '+919876543210' or '9876543210'
 */
async function verifyWithPhone(aadhar, phoneNormalized) {
  try {
    let record = await OtpVerification.findOne({ aadhar, phone: phoneNormalized, verified: false }).sort({ sentAt: -1 });
    if (!record) {
      const last10 = phoneNormalized.replace(/\D/g, '').slice(-10);
      record = await OtpVerification.findOne({ aadhar, phone: last10, verified: false }).sort({ sentAt: -1 });
      if (!record) return { success: false, message: 'OTP record not found for this phone. Please request a new OTP.' };
    }

    if (Date.now() > new Date(record.expiresAt).getTime()) {
      await OtpVerification.deleteOne({ _id: record._id });
      return { success: false, message: 'OTP has expired. Please request a new one.' };
    }

    record.verified = true;
    record.success = true;
    await record.save();

    try {
      const log = await OtpLog.findOne({ aadharEncrypted: aadhar, phone: record.phone }).sort({ sentAt: -1 });
      if (log) {
        log.success = true;
        await log.save();
      }
    } catch (e) {
      logger.warn(`[OTP] Could not mark otp log success for ${aadhar}: ${e.message}`);
    }

    return { success: true, message: 'OTP verified via Firebase phone auth' };
  } catch (err) {
    logger.error(`[OTP] verifyWithPhone error: ${err.message}`);
    return { success: false, message: 'Error verifying OTP via Firebase' };
  }
}

async function isOtpVerified(aadhar) {
  const record = await OtpVerification.findOne({ aadhar, verified: true }).sort({ sentAt: -1 });
  return !!record;
}

async function clearOtp(aadhar) {
  try {
    await OtpVerification.deleteMany({ aadhar });
    logger.info(`[OTP] Cleared for ${aadhar}`);
  } catch (e) {
    logger.warn(`[OTP] clearOtp error for ${aadhar}: ${e.message}`);
  }
}

module.exports = {
  sendOtp,
  verifyOtp,
  isOtpVerified,
  clearOtp,
  verifyWithPhone,
};
