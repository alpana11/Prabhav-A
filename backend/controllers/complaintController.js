const { v4: uuidv4 } = require('uuid');
const Complaint = require('../models/Complaint');
const User = require('../models/User');
const blockchain = require('../services/blockchainService');
const firebaseService = require('../services/firebaseService');
const path = require('path');
const logger = require('../logger');

exports.createComplaint = async (req, res) => {
  try {
    const body = req.body || {};
    const department = body.department || body.category || 'general';
    const title = body.title || body.subject || '';
    const description = body.description || body.details || '';
    const address = body.address || body.locationAddress || '';
    const severity = body.severity || 'Medium';
    const anonymous = body.anonymous === true || body.anonymous === 'true';

    if (!title || !description) {
      return res.status(400).json({ success: false, message: 'Title and description are required' });
    }

    const complaintId = `C-${uuidv4().substring(0, 8)}`;
    const userId = req.user?.id || req.user?._id || null;

    // Handle file uploads to Firebase
    const files = req.files || [];
    const images = [];
    for (const f of files) {
      try {
        const ext = path.extname(f.originalname) || '';
        const filename = `complaints/${complaintId}-${Date.now()}-${uuidv4()}${ext}`;
        const url = await firebaseService.uploadBuffer(f.buffer, filename, f.mimetype || 'application/octet-stream');
        images.push(url);
      } catch (e) {
        logger.warn('Firebase upload failed:', e.message || e);
      }
    }

    const complaintData = {
      complaintId,
      citizen: userId,
      department,
      title,
      description,
      address,
      severity,
      anonymous,
      images,
      status: 'Pending',
    };

    // Save to MongoDB
    const complaint = new Complaint(complaintData);
    await complaint.save();

    logger.info(`[COMPLAINT] Created: ${complaintId} by user ${userId}`);

    // If complaint created by an authenticated user, attach complaint to user record
    try {
      if (userId) {
        const user = await User.findById(userId);
        if (user) {
          if (!user.complaints) user.complaints = [];
          if (!user.complaints.includes(complaint._id)) {
            user.complaints.push(complaint._id);
            user.totalComplaints = (user.totalComplaints || 0) + 1;
            await user.save();
          }
          logger.info(`[COMPLAINT] Linked complaint ${complaintId} to user ${userId} (firebaseUid: ${user.firebaseUid})`);
        }
      }
    } catch (e) {
      logger.warn('[COMPLAINT] Could not attach complaint to user:', e.message || e);
    }

    return res.status(201).json({
      success: true,
      message: 'Complaint created successfully',
      data: complaint,
    });
  } catch (err) {
    logger.error('[COMPLAINT] createComplaint error:', err.message || err);
    res.status(500).json({
      success: false,
      message: 'Error creating complaint',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined,
    });
  }
};

exports.getById = async (req, res) => {
  try {
    const { id } = req.params; // complaintId
    const complaint = await Complaint.findOne({ complaintId: id }).populate('citizen', 'aadhar username firebaseUid');
    if (!complaint) return res.status(404).json({ success: false, message: 'Complaint not found' });
    res.json({ success: true, data: complaint });
  } catch (err) {
    logger.error('[COMPLAINT] getById error:', err.message || err);
    res.status(500).json({ success: false, message: 'Error fetching complaint' });
  }
};

exports.getByUser = async (req, res) => {
  try {
    const userId = req.user?.id || req.user?._id || null;
    if (!userId)
      return res.status(401).json({ success: false, message: 'Unauthorized' });

    const complaints = await Complaint.find({ citizen: userId })
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      complaints: complaints,   // 👈 IMPORTANT
      total: complaints.length,
    });

  } catch (err) {
    logger.error('[COMPLAINT] getByUser error:', err.message || err);
    res.status(500).json({ success: false, message: 'Error fetching complaints' });
  }
};


exports.getByDepartment = async (req, res) => {
  try {
    const { department } = req.params;
    const complaints = await Complaint.find({ department }).sort({ createdAt: -1 });
    res.json({ success: true, data: complaints });
  } catch (err) {
    logger.error('[COMPLAINT] getByDepartment error:', err.message || err);
    res.status(500).json({ success: false, message: 'Error fetching complaints' });
  }
};

exports.uploadImages = async (req, res) => {
  try {
    const { id } = req.params; // complaintId
    const filesSrc = req.files || [];
    const complaint = await Complaint.findOne({ complaintId: id });
    if (!complaint) return res.status(404).json({ success: false, message: 'Complaint not found' });
    const uploaded = [];
    for (const f of filesSrc) {
      try {
        const ext = path.extname(f.originalname) || '';
        const filename = `complaints/${id}-${Date.now()}-${uuidv4()}${ext}`;
        const url = await firebaseService.uploadBuffer(f.buffer, filename, f.mimetype || 'application/octet-stream');
        uploaded.push(url);
      } catch (e) {
        logger.warn('Failed to upload image to Firebase:', e.message || e);
      }
    }

    complaint.images.push(...uploaded);
    await complaint.save();
    await blockchain.createBlock('UploadImages', id, { images: uploaded });

    res.json({ success: true, message: 'Images uploaded successfully', data: complaint });
  } catch (err) {
    logger.error('[COMPLAINT] uploadImages error:', err.message || err);
    res.status(500).json({ success: false, message: 'Error uploading images' });
  }
};
