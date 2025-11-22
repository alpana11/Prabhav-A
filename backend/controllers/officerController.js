const Officer = require('../models/Officer');
const Complaint = require('../models/Complaint');
const blockchain = require('../services/blockchainService');

exports.getDepartmentComplaints = async (req, res) => {
  try {
    const officer = await Officer.findById(req.user.id);
    if (!officer) return res.status(404).json({ message: 'Officer not found' });
    
    const complaints = await Complaint.find({ department: officer.department }).sort({ createdAt: -1 });
    res.json(complaints);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching complaints' });
  }
};

exports.updateComplaint = async (req, res) => {
  try {
    const { complaintId } = req.params;
    const { status, remark } = req.body;
    const images = (req.files || []).map(f => `/uploads/${f.filename}`);
    
    const officer = await Officer.findById(req.user.id);
    const complaint = await Complaint.findOne({ complaintId });
    if (!complaint) return res.status(404).json({ message: 'Complaint not found' });
    
    if (status) complaint.status = status;
    if (remark || images.length) {
      complaint.remarks.push({ officer: officer._id, remark, images });
    }
    await complaint.save();
    await blockchain.createBlock('UpdateStatus', complaintId, { status: complaint.status, remark, images, officer: officer.officerId });
    
    res.json({ message: 'Complaint updated', complaint });
  } catch (err) {
    res.status(500).json({ message: 'Error updating complaint' });
  }
};

exports.departmentDashboard = async (req, res) => {
  try {
    const officer = await Officer.findById(req.user.id);
    const total = await Complaint.countDocuments({ department: officer.department });
    const pending = await Complaint.countDocuments({ department: officer.department, status: 'Pending' });
    const resolved = await Complaint.countDocuments({ department: officer.department, status: 'Resolved' });
    
    res.json({ department: officer.department, total, pending, resolved });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching dashboard' });
  }
};
