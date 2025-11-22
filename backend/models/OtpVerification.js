const mongoose = require('mongoose');

const otpVerificationSchema = new mongoose.Schema({
  aadhar: { type: String, required: true, index: true },
  phone: { type: String, required: true },
  otpHash: { type: String, required: true },
  sentAt: { type: Date, default: Date.now },
  expiresAt: { type: Date },
  attempts: { type: Number, default: 0 },
  verified: { type: Boolean, default: false },
  success: { type: Boolean, default: false },
  meta: { type: mongoose.Schema.Types.Mixed },
}, { timestamps: true });

module.exports = mongoose.model('OtpVerification', otpVerificationSchema);
