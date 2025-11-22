const User = require('../models/User');
const Complaint = require('../models/Complaint');
const logger = require('../logger');

/**
 * GET /api/user/profile
 * Get user profile
 */
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      user: user.toJSON(),
    });
  } catch (err) {
    logger.error(`[USER] getProfile error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching profile',
    });
  }
};

/**
 * PUT /api/user/profile
 * Update user profile
 */
exports.updateProfile = async (req, res) => {
  try {
    const { fullName, email, phone, dateOfBirth, gender } = req.body;

    const updates = {};
    if (fullName) updates.fullName = fullName;
    if (email) updates.email = email;
    if (phone) updates.phone = phone;
    if (dateOfBirth) updates.dateOfBirth = dateOfBirth;
    if (gender) updates.gender = gender;

    const user = await User.findByIdAndUpdate(req.userId, updates, {
      new: true,
      runValidators: true,
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    logger.info(`[USER] Profile updated for ${user.aadhar}`);

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: user.toJSON(),
    });
  } catch (err) {
    logger.error(`[USER] updateProfile error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error updating profile',
    });
  }
};

/**
 * POST /api/user/location
 * Update user location
 */
exports.updateLocation = async (req, res) => {
  try {
    const { latitude, longitude, address, accuracy } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required',
      });
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Update location using model method
    user.addLocationUpdate(
      { latitude, longitude },
      address || 'Unknown location',
      accuracy || 0
    );
    await user.save();

    logger.info(`[USER] Location updated for ${user.aadhar} (${latitude}, ${longitude})`);

    res.json({
      success: true,
      message: 'Location updated successfully',
    });
  } catch (err) {
    logger.error(`[USER] updateLocation error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error updating location',
    });
  }
};

/**
 * GET /api/user/location-history
 * Get user location history
 */
exports.getLocationHistory = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      totalLocations: user.locationHistory.length,
      currentLocation: user.currentLocation,
      history: user.locationHistory.slice(-50), // Last 50 locations
    });
  } catch (err) {
    logger.error(`[USER] getLocationHistory error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching location history',
    });
  }
};

/**
 * POST /api/user/upload-profile-pic
 * Upload profile picture (expects file in req.file)
 */
exports.uploadProfilePic = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file provided',
      });
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // In production, upload to Cloudinary/S3
    // For now, store file path
    user.profilePic = `/uploads/profiles/${req.file.filename}`;
    user.profilePicUploadedAt = new Date();
    await user.save();

    logger.info(`[USER] Profile pic uploaded for ${user.aadhar}`);

    res.json({
      success: true,
      message: 'Profile picture uploaded successfully',
      profilePic: user.profilePic,
    });
  } catch (err) {
    logger.error(`[USER] uploadProfilePic error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error uploading profile picture',
    });
  }
};

/**
 * POST /api/user/permissions
 * Update user permissions status
 */
exports.updatePermissions = async (req, res) => {
  try {
    const { location, camera, microphone, gallery, files } = req.body;

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (location) user.permissions.location = location;
    if (camera) user.permissions.camera = camera;
    if (microphone) user.permissions.microphone = microphone;
    if (gallery) user.permissions.gallery = gallery;
    if (files) user.permissions.files = files;

    await user.save();

    logger.info(`[USER] Permissions updated for ${user.aadhar}`);

    res.json({
      success: true,
      message: 'Permissions updated successfully',
      permissions: user.permissions,
    });
  } catch (err) {
    logger.error(`[USER] updatePermissions error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error updating permissions',
    });
  }
};

/**
 * GET /api/user/permissions
 * Get user permissions
 */
exports.getPermissions = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      permissions: user.permissions,
    });
  } catch (err) {
    logger.error(`[USER] getPermissions error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching permissions',
    });
  }
};

/**
 * GET /api/user/complaints
 * Get user's complaints
 */
exports.getMyComplaints = async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const complaints = await Complaint.find({ citizen: req.userId }).sort({ createdAt: -1 });

    res.json({
      success: true,
      totalComplaints: complaints.length,
      complaints,
    });
  } catch (err) {
    logger.error(`[USER] getMyComplaints error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching complaints',
    });
  }
};

/**
 * GET /api/user/complaint/:id
 * Track a specific complaint
 */
exports.trackComplaint = async (req, res) => {
  try {
    const { id } = req.params;

    const complaint = await Complaint.findById(id)
      .populate('citizen', 'aadhar username phone')
      .populate('assignedTo', 'name email department');

    if (!complaint) {
      return res.status(404).json({
        success: false,
        message: 'Complaint not found',
      });
    }

    // Check if user owns this complaint
    if (complaint.citizen._id.toString() !== req.userId) {
      return res.status(403).json({
        success: false,
        message: 'Access denied',
      });
    }

    res.json({
      success: true,
      complaint,
    });
  } catch (err) {
    logger.error(`[USER] trackComplaint error: ${err.message}`);
    res.status(500).json({
      success: false,
      message: 'Error tracking complaint',
    });
  }
};
