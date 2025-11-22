const logger = require('../logger');

class SMSService {
  constructor() {
    // Check for Twilio credentials
    this.twilioAccountSid = process.env.TWILIO_ACCOUNT_SID;
    this.twilioAuthToken = process.env.TWILIO_AUTH_TOKEN;
    this.twilioFrom = process.env.TWILIO_FROM;
    this.msg91AuthKey = process.env.MSG91_AUTH_KEY;
    this.msg91SenderId = process.env.MSG91_SENDER_ID;
    this.fast2smsApiKey = process.env.FAST2SMS_API_KEY;
    
    // Enable if any provider is configured
    this.enabled = !!(this.twilioAccountSid && this.twilioAuthToken && this.twilioFrom) ||
                   !!this.msg91AuthKey ||
                   !!this.fast2smsApiKey;
    
    if (this.enabled) {
      logger.info('[SMS] SMS service enabled with configured provider');
    } else {
      logger.warn('[SMS] SMS service disabled - no provider credentials found');
    }
  }

  async sendOTP(phoneNumber, otp) {
    if (!this.enabled) {
      logger.error(`[SMS] SMS sending disabled. Requested OTP for ${phoneNumber} not sent.`);
      return { success: false, message: 'SMS service not configured' };
    }

    const formattedPhone = this.formatPhoneNumber(phoneNumber);
    
    // Try Twilio first
    if (this.twilioAccountSid && this.twilioAuthToken && this.twilioFrom) {
      try {
        return await this._sendViaTwilio(formattedPhone, otp);
      } catch (error) {
        logger.error(`[SMS] Twilio failed: ${error.message}`);
        // Fall through to try other providers
      }
    }

    // Try MSG91
    if (this.msg91AuthKey) {
      try {
        return await this._sendViaMSG91(formattedPhone, otp);
      } catch (error) {
        logger.error(`[SMS] MSG91 failed: ${error.message}`);
        // Fall through to try Fast2SMS
      }
    }

    // Try Fast2SMS
    if (this.fast2smsApiKey) {
      try {
        return await this._sendViaFast2SMS(formattedPhone, otp);
      } catch (error) {
        logger.error(`[SMS] Fast2SMS failed: ${error.message}`);
      }
    }

    return { success: false, message: 'All SMS providers failed' };
  }

  async _sendViaTwilio(phoneNumber, otp) {
    const twilio = require('twilio');
    const client = twilio(this.twilioAccountSid, this.twilioAuthToken);
    
    const message = await client.messages.create({
      body: `Your Prabhav verification code is: ${otp}. This code will expire in 10 minutes.`,
      from: this.twilioFrom,
      to: phoneNumber,
    });

    logger.info(`[SMS] Twilio SMS sent: ${message.sid} to ${phoneNumber}`);
    return { success: true, messageId: message.sid, provider: 'twilio' };
  }

  async _sendViaMSG91(phoneNumber, otp) {
    const https = require('https');
    const phoneDigits = phoneNumber.replace(/\D/g, '');
    
    const postData = JSON.stringify({
      sender: this.msg91SenderId || 'PRABHV',
      route: '4',
      country: '91',
      sms: [
        {
          message: `Your Prabhav verification code is: ${otp}. This code will expire in 10 minutes.`,
          to: [phoneDigits],
        },
      ],
    });

    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'control.msg91.com',
        path: '/api/v5/flow/',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData),
          'authkey': this.msg91AuthKey,
        },
      };

      const req = https.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          if (res.statusCode === 200) {
            logger.info(`[SMS] MSG91 SMS sent to ${phoneNumber}`);
            resolve({ success: true, provider: 'msg91' });
          } else {
            reject(new Error(`MSG91 API error: ${res.statusCode} - ${data}`));
          }
        });
      });

      req.on('error', (error) => {
        reject(error);
      });

      req.write(postData);
      req.end();
    });
  }

  async _sendViaFast2SMS(phoneNumber, otp) {
    const https = require('https');
    const phoneDigits = phoneNumber.replace(/\D/g, '').slice(-10); // Last 10 digits for India
    
    const message = encodeURIComponent(`Your Prabhav verification code is: ${otp}. This code will expire in 10 minutes.`);
    const url = `/api/smshttp?authorization=${this.fast2smsApiKey}&route=q&message=${message}&language=english&flash=0&numbers=${phoneDigits}`;

    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'www.fast2sms.com',
        path: url,
        method: 'GET',
      };

      const req = https.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          try {
            const result = JSON.parse(data);
            if (result.return === true) {
              logger.info(`[SMS] Fast2SMS sent to ${phoneNumber}`);
              resolve({ success: true, provider: 'fast2sms' });
            } else {
              reject(new Error(`Fast2SMS error: ${result.message || 'Unknown error'}`));
            }
          } catch (error) {
            reject(new Error(`Fast2SMS parse error: ${error.message}`));
          }
        });
      });

      req.on('error', (error) => {
        reject(error);
      });

      req.end();
    });
  }

  /**
   * Format phone number to E.164 format
   * @param {string} phoneNumber
   * @returns {string}
   */
  formatPhoneNumber(phoneNumber) {
    // Remove all non-digits
    const digits = phoneNumber.replace(/\D/g, '');
    
    // If 10 digits (India), add +91
    if (digits.length === 10) {
      return `+91${digits}`;
    }
    
    // If 12 digits starting with 91 (India with country code), add +
    if (digits.length === 12 && digits.startsWith('91')) {
      return `+${digits}`;
    }
    
    // If already has country code
    if (!phoneNumber.startsWith('+')) {
      return `+${digits}`;
    }
    
    return phoneNumber;
  }
}

module.exports = new SMSService();
