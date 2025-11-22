const mongoose = require('mongoose');

const remarkSchema = new mongoose.Schema({
  officer: { type: mongoose.Schema.Types.ObjectId, ref: 'Officer' },
  remark: String,
  images: [String],
  createdAt: { type: Date, default: Date.now }
});

const complaintSchema = new mongoose.Schema(
  {
    complaintId: { type: String, required: true, unique: true, index: true },
    citizen: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    department: { type: String, required: true },
    title: { type: String, required: true },
    description: { type: String, required: true },
    address: { type: String },
    severity: { type: String, enum: ['Low', 'Medium', 'High', 'Urgent'], default: 'Medium' },
    anonymous: { type: Boolean, default: false },
    images: [String],
    status: { type: String, enum: ['Pending', 'In Progress', 'Resolved'], default: 'Pending' },
    remarks: [remarkSchema],
  },
  { timestamps: true }
);

module.exports = mongoose.model('Complaint', complaintSchema);
