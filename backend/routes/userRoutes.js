const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authMiddleware } = require('../middleware/auth');

// All user routes require authentication
router.use(authMiddleware);

// Profile endpoints
router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);

// Location endpoints
router.post('/location', userController.updateLocation);
router.get('/location-history', userController.getLocationHistory);

// Media upload endpoints
router.post('/upload-profile-pic', userController.uploadProfilePic);

// Permissions endpoints
router.get('/permissions', userController.getPermissions);
router.post('/permissions', userController.updatePermissions);

// Complaint endpoints
router.get('/complaints', userController.getMyComplaints);
router.get('/complaint/:id', userController.trackComplaint);

module.exports = router;
