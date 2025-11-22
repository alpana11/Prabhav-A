const Feedback = require('../models/Feedback');

exports.submitFeedback = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : null;
    const { complaintId, rating, feedbackText, aspectRatings, isAnonymous } = req.body;

    // Allow anonymous submissions when explicitly requested; otherwise require authentication
    if (!userId && !isAnonymous) {
      return res.status(401).json({ success: false, message: 'Authentication required or set isAnonymous=true' });
    }

    const payload = { complaintId, rating, feedbackText, aspectRatings, isAnonymous };
    if (userId) payload.user = userId;

    const fb = await Feedback.create(payload);
    res.status(201).json({ success: true, message: 'Feedback submitted', data: fb });
  } catch (err) {
    console.error('submitFeedback error', err);
    res.status(500).json({ success: false, message: 'Error submitting feedback' });
  }
};

exports.getFeedbackByUser = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : null;
    if (!userId) return res.status(401).json({ success: false, message: 'Authentication required' });
    const list = await Feedback.find({ user: userId }).sort({ submittedAt: -1 });
    res.json({ success: true, data: list });
  } catch (err) {
    console.error('getFeedbackByUser error', err);
    res.status(500).json({ success: false, message: 'Error fetching feedback' });
  }
};
