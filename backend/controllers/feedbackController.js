const Feedback = require('../models/Feedback');

exports.submitFeedback = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : null;
    const { complaintId, rating, feedbackText, aspectRatings, isAnonymous } = req.body;

    if (!userId && !isAnonymous) {
      return res.status(401).json({
        success: false,
        message: "Login required unless submitting anonymously."
      });
    }

    const payload = {
      complaintId,
      rating,
      feedbackText,
      aspectRatings,
      isAnonymous,
      submittedAt: new Date()
    };

    if (userId) payload.user = userId;

    const feedback = await Feedback.create(payload);

    res.status(201).json({
      success: true,
      message: "Feedback submitted successfully",
      data: feedback
    });

  } catch (err) {
    console.error("submitFeedback error", err);
    res.status(500).json({
      success: false,
      message: "Internal error while submitting feedback"
    });
  }
};

exports.getFeedbackByUser = async (req, res) => {
  try {
    const userId = req.user.id;

    const list = await Feedback.find({ user: userId })
      .sort({ submittedAt: -1 });

    res.json({
      success: true,
      data: list
    });

  } catch (err) {
    console.error("getFeedbackByUser error", err);
    res.status(500).json({
      success: false,
      message: "Failed to fetch feedback"
    });
  }
};
