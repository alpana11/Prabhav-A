const mongoose = require('mongoose');

const otpLogSchema = new mongoose.Schema({
  aadharEncrypted: { type: String, required: true, index: true },
  phone: { type: String, required: true },
  otpHash: { type: String }, // SHA256 of OTP + salt (not plaintext)
  provider: { type: String },
  providerResponse: { type: mongoose.Schema.Types.Mixed },
  messageSid: { type: String },
  sentAt: { type: Date, default: Date.now },
  expiresAt: { type: Date },
  attempts: { type: Number, default: 0 },
  success: { type: Boolean, default: false },
  ipAddress: { type: String },
});

module.exports = mongoose.model('OtpLog', otpLogSchema);
