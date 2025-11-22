const Officer = require('../models/Officer');
const Complaint = require('../models/Complaint');
const blockchain = require('../services/blockchainService');

exports.createOfficer = async (req, res) => {
  try {
    const { officerId, password, name, department } = req.body;
    const exist = await Officer.findOne({ officerId });
    if (exist) return res.status(400).json({ message: 'Officer already exists' });
    
    const officer = await Officer.create({ officerId, password, name, department });
    res.json({ message: 'Officer created successfully', officer: { id: officer._id, officerId, name, department } });
  } catch (err) {
    res.status(500).json({ message: 'Error creating officer' });
  }
};

exports.analytics = async (req, res) => {
  try {
    const total = await Complaint.countDocuments();
    const pending = await Complaint.countDocuments({ status: 'Pending' });
    const inProgress = await Complaint.countDocuments({ status: 'In Progress' });
    const resolved = await Complaint.countDocuments({ status: 'Resolved' });
    
    const byDepartment = await Complaint.aggregate([
      { $group: { _id: '$department', count: { $sum: 1 }, resolved: { $sum: { $cond: [{ $eq: ['$status', 'Resolved'] }, 1, 0] } } } }
    ]);
    
    res.json({ total, pending, inProgress, resolved, byDepartment });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching analytics' });
  }
};

exports.blockchainLogs = async (req, res) => {
  try {
    const logs = await blockchain.getAllBlocks();
    res.json(logs);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching blockchain logs' });
  }
};
