const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Officer = require('../models/Officer');
const logger = require('../logger');

/**
 * POST /api/auth/send-otp
 * Initiates Firebase Phone Authentication flow
 * No real SMS sent by backend - client handles Firebase phone verification
 */
exports.sendOtp = async (req, res) => {
  try {
    const { aadhar, phone } = req.body;

    if (!aadhar) {
      return res.status(400).json({
        success: false,
        message: 'Aadhar number is required',
      });
    }

    const cleanAadhar = aadhar.replace(/\s/g, '');
    if (!/^\d{12}$/.test(cleanAadhar)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid Aadhar number (must be 12 digits)',
      });
    }

    // Phone is optional; lookup from DB if not provided
    let cleanPhone = phone ? phone.replace(/\D/g, '') : null;
    if (!cleanPhone) {
      const user = await User.findByAadhar(cleanAadhar);
      if (user && user.phone) {
        cleanPhone = String(user.phone).replace(/\D/g, '');
      }
    }

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: 'Phone number not provided or not found for this Aadhar (10 digits required)',
      });
    }

    logger.info(`[AUTH] Send OTP requested for Aadhar: ${cleanAadhar}, Phone: ${cleanPhone}`);

    // Call OTP service to generate and send OTP
    const otpService = require('../services/otpService');
    const result = await otpService.sendOtp(cleanAadhar, cleanPhone);

    if (result.success) {
      return res.json({
        success: true,
        message: result.message || 'OTP sent successfully',
        phone: cleanPhone,
        provider: result.provider,
        warning: result.warning,
      });
    } else {
      return res.status(400).json({
        success: false,
        message: result.message || 'Failed to send OTP',
      });
    }
  } catch (error) {
    logger.error(`[AUTH] sendOtp error: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error preparing OTP',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * POST /api/auth/verify-otp
 * Verify OTP code or Firebase ID token
 * Supports both SMS OTP verification and Firebase phone auth
 */
exports.verifyOtp = async (req, res) => {
  try {
    const { aadhar, otp, idToken } = req.body;

    if (!aadhar) {
      return res.status(400).json({ success: false, message: 'Aadhar is required' });
    }

    const cleanAadhar = aadhar.replace(/\s/g, '');

    // If OTP is provided, verify using OTP service
    if (otp) {
      const otpService = require('../services/otpService');
      const otpResult = await otpService.verifyOtp(cleanAadhar, otp);
      
      if (!otpResult.success) {
        return res.status(400).json({
          success: false,
          message: otpResult.message || 'Invalid OTP',
          attempts: otpResult.attempts,
        });
      }

      // OTP verified successfully - create or update user
      let user = await User.findByAadhar(cleanAadhar);
      if (!user) {
        // Get phone from OTP record
        const OtpVerification = require('../models/OtpVerification');
        const otpRecord = await OtpVerification.findOne({ aadhar: cleanAadhar, verified: true }).sort({ sentAt: -1 });
        const phone = otpRecord ? otpRecord.phone : null;

        user = new User({
          aadhar: cleanAadhar,
          phone: phone,
          verified: true,
          verifiedAt: new Date(),
        });
        await user.save();
        logger.info(`[AUTH] New user created via OTP verification: ${cleanAadhar}`);
      } else {
        user.verified = true;
        user.verifiedAt = new Date();
        await user.save();
        logger.info(`[AUTH] Existing user verified via OTP: ${cleanAadhar}`);
      }

      // Create temp token for set-password flow
      const tempToken = jwt.sign(
        { aadhar: cleanAadhar, userId: user._id, verified: 'otp' },
        process.env.JWT_SECRET || 'dev-secret',
        { expiresIn: '15m' }
      );

      return res.json({
        success: true,
        message: 'OTP verified successfully',
        tempToken,
        userId: user._id,
      });
    }

    // If Firebase ID token is provided, verify using Firebase Admin SDK
    if (!idToken) {
      return res.status(400).json({ success: false, message: 'OTP or Firebase ID token is required' });
    }

    try {
      // Verify Firebase ID token using Admin SDK (STRICT - no fallback)
      const admin = require('firebase-admin');
      if (!admin.apps || admin.apps.length === 0) {
        try {
          const firebaseService = require('../services/firebaseService');
          await firebaseService.initFirebase();
        } catch (ie) {
          logger.error('[AUTH] Firebase init failed:', ie.message);
          return res.status(500).json({ success: false, message: 'Firebase not initialized' });
        }
      }

      logger.info(`[AUTH] Verifying Firebase ID token for Aadhar: ${cleanAadhar}`);
      const decoded = await admin.auth().verifyIdToken(idToken);

      const firebaseUid = decoded.uid;
      const phoneNumber = decoded.phone_number || '';

      if (!firebaseUid) {
        logger.warn(`[AUTH] Firebase token has no UID`);
        return res.status(400).json({ success: false, message: 'Firebase token invalid: no UID' });
      }

      logger.info(`[AUTH] Firebase token verified: UID=${firebaseUid}, Phone=${phoneNumber}`);

      // Link user: find or create and attach Firebase UID
      let user = await User.findByAadhar(cleanAadhar);
      if (user) {
        user.firebaseUid = firebaseUid;
        if (phoneNumber && !user.phone) {
          user.phone = phoneNumber;
        }
        user.verified = true;
        user.verifiedAt = new Date();
        await user.save();
        logger.info(`[AUTH] Linked existing user to Firebase UID: ${firebaseUid}`);
      } else {
        user = new User({
          aadhar: cleanAadhar,
          firebaseUid,
          phone: phoneNumber,
          verified: true,
          verifiedAt: new Date(),
        });
        await user.save();
        logger.info(`[AUTH] Created new user with Firebase UID: ${firebaseUid}`);
      }

      // Create temp token for set-password flow
      const tempToken = jwt.sign(
        { aadhar: cleanAadhar, firebaseUid, userId: user._id, verified: 'firebase-phone' },
        process.env.JWT_SECRET || 'dev-secret',
        { expiresIn: '15m' }
      );

      return res.json({
        success: true,
        message: 'Firebase phone verification successful',
        tempToken,
        userId: user._id,
        firebaseUid,
      });
    } catch (e) {
      logger.error(`[AUTH] Firebase token verification failed: ${e.code || 'UNKNOWN'} - ${e.message}`);
      return res.status(401).json({
        success: false,
        message: `Firebase verification failed: ${e.message}`,
      });
    }
  } catch (error) {
    logger.error(`[AUTH] verifyOtp error: ${error.message}`);
    res.status(500).json({ success: false, message: 'Error verifying OTP' });
  }
};

/**
 * POST /api/auth/set-password
 * Set password after OTP verification
 */
exports.setPassword = async (req, res) => {
  try {
    const { aadhar, password, confirmPassword } = req.body;
    const tempToken = req.headers.authorization?.split(' ')[1];

    if (!aadhar || !password) {
      return res.status(400).json({
        success: false,
        message: 'Aadhar and password are required',
      });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'Passwords do not match',
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long',
      });
    }

    if (!tempToken) {
      return res.status(401).json({
        success: false,
        message: 'OTP verification required first',
      });
    }

    try {
      const decoded = jwt.verify(
        tempToken,
        process.env.JWT_SECRET || 'dev-secret'
      );
      if (decoded.aadhar !== aadhar.replace(/\s/g, '') || decoded.verified !== 'firebase-phone') {
        throw new Error('Invalid token');
      }
    } catch (err) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired OTP verification token',
      });
    }

    const cleanAadhar = aadhar.replace(/\s/g, '');

    let user = await User.findByAadhar(cleanAadhar);

    const hashedPassword = await bcrypt.hash(password, 10);

    if (user) {
      user.password = hashedPassword;
      user.passwordSetAt = new Date();
      await user.save();
      logger.info(`[AUTH] Password updated for Aadhar: ${cleanAadhar}`);
    } else {
      user = new User({
        aadhar: cleanAadhar,
        password: hashedPassword,
        passwordSetAt: new Date(),
      });
      const savedUser = await user.save();
      logger.info(`[AUTH] New user created for Aadhar: ${cleanAadhar}, ID: ${savedUser._id}`);
    }

    res.json({
      success: true,
      message: 'Password set successfully',
      userId: user._id,
    });
  } catch (error) {
    logger.error(`[AUTH] setPassword error: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error setting password',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
};

/**
 * POST /api/auth/set-username
 * Set username after OTP/password setup
 */
exports.setUsername = async (req, res) => {
  try {
    const { aadhar, username } = req.body;

    if (!aadhar || !username) {
      return res.status(400).json({
        success: false,
        message: 'Aadhar and username are required',
      });
    }

    if (username.length < 3) {
      return res.status(400).json({
        success: false,
        message: 'Username must be at least 3 characters',
      });
    }

    const cleanAadhar = aadhar.replace(/\s/g, '');

    const user = await User.findByAadhar(cleanAadhar);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const existing = await User.findOne({ usernameLower: username.toLowerCase() });
    if (existing && existing._id.toString() !== user._id.toString()) {
      return res.status(400).json({ success: false, message: 'Username already taken' });
    }

    user.username = username;
    user.usernameSetAt = new Date();
    await user.save();

    logger.info(`[AUTH] Username set for ${cleanAadhar}: ${username}`);

    res.json({
      success: true,
      message: 'Username set successfully',
    });
  } catch (error) {
    logger.error(`[AUTH] setUsername error: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error setting username',
    });
  }
};

/**
 * POST /api/auth/login
 * Login with Aadhar/Username/Mobile and password
 */
exports.login = async (req, res) => {
  try {
    const { aadhar, username, mobile, password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required',
      });
    }

    if (!aadhar && !username && !mobile) {
      return res.status(400).json({
        success: false,
        message: 'Aadhar, username, or mobile number is required',
      });
    }

    let user = null;

    // Try to find user by Aadhar
    if (aadhar) {
      const cleanAadhar = aadhar.replace(/\s/g, '');
      user = await User.findByAadhar(cleanAadhar);
    }
    
    // Try to find user by username
    if (!user && username) {
      user = await User.findOne({ usernameLower: username.toLowerCase() });
    }
    
    // Try to find user by mobile
    if (!user && mobile) {
      const cleanMobile = mobile.replace(/\D/g, '');
      user = await User.findOne({ phone: cleanMobile });
    }

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    if (!user.password) {
      return res.status(401).json({
        success: false,
        message: 'Password not set. Please complete account setup.',
      });
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    const token = jwt.sign(
      { userId: user._id, aadhar: user.aadhar, firebaseUid: user.firebaseUid },
      process.env.JWT_SECRET || 'dev-secret',
      { expiresIn: '30d' }
    );

    user.lastLogin = new Date();
    await user.save();

    logger.info(`[AUTH] Login successful for ${cleanAadhar}`);

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        aadhar: user.aadhar,
        username: user.username,
        profilePic: user.profilePic,
      },
    });
  } catch (error) {
    logger.error(`[AUTH] login error: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error logging in',
    });
  }
};

/**
 * GET /api/auth/me
 * Get current user info (requires auth)
 */
exports.getMe = async (req, res) => {
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
      user: {
        id: user._id,
        aadhar: user.aadhar,
        username: user.username,
        phone: user.phone,
        email: user.email,
        profilePic: user.profilePic,
        location: user.currentLocation,
        firebaseUid: user.firebaseUid,
        verified: user.verified,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    logger.error(`[AUTH] getMe error: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching user info',
    });
  }
};

exports.officerLogin = async (req, res) => {
  const { officerId, password } = req.body;
  if (!officerId || !password) {
    return res.status(400).json({ success: false, message: 'Officer ID and password required' });
  }
  try {
    const officer = await Officer.findOne({ officerId });
    if (!officer) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const match = await officer.comparePassword(password);
    if (!match) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = jwt.sign(
      { id: officer._id, role: 'officer', department: officer.department },
      process.env.JWT_SECRET || 'dev-secret',
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      token,
      officer: {
        id: officer._id,
        officerId: officer.officerId,
        name: officer.name,
        department: officer.department,
      },
    });
  } catch (err) {
    logger.error('Officer login error:', err.message);
    return res.status(500).json({ success: false, message: 'Error logging in' });
  }
};

exports.adminLogin = async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ success: false, message: 'Username and password required' });
  }
  try {
    if (username === process.env.ADMIN_USER && password === process.env.ADMIN_PASS) {
      const token = jwt.sign(
        { role: 'admin', username },
        process.env.JWT_SECRET || 'dev-secret',
        { expiresIn: '7d' }
      );
      return res.json({
        success: true,
        message: 'Admin login successful',
        token,
      });
    }
    return res.status(401).json({ success: false, message: 'Invalid admin credentials' });
  } catch (err) {
    logger.error('Admin login error:', err.message);
    return res.status(500).json({ success: false, message: 'Error logging in' });
  }
};
