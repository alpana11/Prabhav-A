const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const auth = require('../middleware/auth');
const roles = require('../middleware/roles');

router.post('/create-officer', auth, roles('admin'), adminController.createOfficer);
router.get('/analytics', auth, roles('admin'), adminController.analytics);
router.get('/blockchain', auth, roles('admin'), adminController.blockchainLogs);

module.exports = router;
