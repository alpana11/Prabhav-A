const express = require('express');
const router = express.Router();
const testController = require('../controllers/testController');

// Test endpoints (development only)
router.get('/status', testController.healthCheck);
router.get('/config', testController.checkConfig);
router.post('/check-otp-service', testController.checkOtpService);

module.exports = router;
