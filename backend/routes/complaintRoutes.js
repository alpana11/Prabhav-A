const express = require('express');
const router = express.Router();
const complaintController = require('../controllers/complaintController');
const auth = require('../middleware/auth');
const multer = require('multer');
const fs = require('fs');

// Create uploads folder if not exists
if (!fs.existsSync('uploads')) fs.mkdirSync('uploads');

// Use memory storage so we can upload directly to Firebase Storage
const storage = multer.memoryStorage();
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

// Middleware to allow both authenticated and anonymous users
const optionalAuth = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (token) {
    auth(req, res, next);
  } else {
    next();
  }
};

// Routes
router.post('/', optionalAuth, upload.any(), complaintController.createComplaint);
router.get('/user/me', auth, complaintController.getByUser);
router.get('/:id', complaintController.getById);
router.get('/department/:department', complaintController.getByDepartment);
router.post('/:id/images', auth, upload.any(), complaintController.uploadImages);

module.exports = router;
