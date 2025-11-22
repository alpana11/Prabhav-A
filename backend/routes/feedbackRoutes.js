const express = require('express');
const router = express.Router();
const feedbackController = require('../controllers/feedbackController');
const auth = require('../middleware/auth');

// Optional auth: allow anonymous feedback submissions when client sets isAnonymous
const optionalAuth = (req, res, next) => {
	const token = req.headers.authorization?.split(' ')[1];
	if (token) {
		return auth(req, res, next);
	}
	next();
};

router.post('/submit', optionalAuth, feedbackController.submitFeedback);
router.get('/user/me', auth, feedbackController.getFeedbackByUser);

module.exports = router;
