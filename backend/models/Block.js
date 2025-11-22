const mongoose = require('mongoose');

const blockSchema = new mongoose.Schema({
  action: { type: String, required: true },
  complaintId: { type: String, required: true },
  meta: { type: Object },
  prevHash: { type: String },
  hash: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Block', blockSchema);
