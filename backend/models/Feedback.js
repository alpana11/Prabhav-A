const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    complaintId: { type: String },
    rating: { type: Number, min: 0, max: 5 },
    feedbackText: { type: String },
    aspectRatings: { type: Object },
    isAnonymous: { type: Boolean, default: false },
    status: { type: String, default: 'Submitted' },
  },
  { timestamps: { createdAt: 'submittedAt' } }
);

module.exports = mongoose.model('Feedback', feedbackSchema);
