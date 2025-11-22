const express = require('express');
const router = express.Router();
const blockchainController = require('../controllers/blockchainController');
const auth = require('../middleware/auth');

router.get('/trail', auth, blockchainController.getTrail);

module.exports = router;
