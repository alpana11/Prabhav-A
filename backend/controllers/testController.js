const otpService = require('../services/otpService');
const logger = require('../logger');

/**
 * POST /api/test/check-otp-service
 * Test endpoint to verify OTP service is working
 * NOTE: Only available in development mode
 */
exports.checkOtpService = async (req, res) => {
  try {
    if (process.env.NODE_ENV === 'production') {
      return res.status(403).json({
        success: false,
        message: 'This endpoint is not available in production',
      });
    }

    const { aadhar, phone } = req.body;

    if (!aadhar || !phone) {
      return res.status(400).json({
        success: false,
        message: 'Aadhar and phone are required',
      });
    }

    // Send OTP
    const result = await otpService.sendOtp(aadhar, phone);

    logger.info(`[TEST] OTP service check for ${aadhar}`);

    res.json({
      success: result.success,
      message: result.message,
      note: 'Check your console or phone for the OTP code',
    });
  } catch (error) {
    logger.error(`[TEST] checkOtpService error: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error checking OTP service',
    });
  }
};

/**
 * GET /api/test/status
 * Health check endpoint
 */
exports.healthCheck = (req, res) => {
  res.json({
    success: true,
    message: 'API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
  });
};

/**
 * GET /api/test/config
 * Check backend configuration (development only)
 */
exports.checkConfig = (req, res) => {
  if (process.env.NODE_ENV === 'production') {
    return res.status(403).json({
      success: false,
      message: 'Not available in production',
    });
  }

  res.json({
    success: true,
    config: {
      environment: process.env.NODE_ENV,
      mongoDbConnected: !!process.env.MONGO_URI,
      twilioConfigured: !!(
        process.env.TWILIO_ACCOUNT_SID &&
        process.env.TWILIO_AUTH_TOKEN &&
        process.env.TWILIO_FROM
      ),
      jwtSecretSet: !!process.env.JWT_SECRET,
      nodeVersion: process.version,
      timestamp: new Date().toISOString(),
    },
  });
};
