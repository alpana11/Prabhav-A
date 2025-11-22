const express = require('express');
const router = express.Router();
const officerController = require('../controllers/officerController');
const auth = require('../middleware/auth');
const roles = require('../middleware/roles');
const multer = require('multer');
const fs = require('fs');

// Create uploads folder if not exists
if (!fs.existsSync('uploads')) fs.mkdirSync('uploads');

const storage = multer.diskStorage({
  destination: 'uploads/',
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage });

router.get('/department/complaints', auth, roles('officer'), officerController.getDepartmentComplaints);
router.post('/complaint/:complaintId/update', auth, roles('officer'), upload.array('images', 5), officerController.updateComplaint);
router.get('/dashboard', auth, roles('officer'), officerController.departmentDashboard);

module.exports = router;
