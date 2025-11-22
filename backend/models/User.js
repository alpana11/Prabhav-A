const mongoose = require('mongoose');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');

// Encryption helper for sensitive data
// AES-256-CBC encryption helper using an IV. Ciphertext format: iv:hex
function encryptAadhar(aadhar) {
  if (!aadhar) return aadhar;
  const key = (process.env.ENCRYPTION_KEY || 'default-32-char-key-please-change!').slice(0, 32);
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(key, 'utf8'), iv);
  const encrypted = Buffer.concat([cipher.update(aadhar, 'utf8'), cipher.final()]);
  return iv.toString('hex') + ':' + encrypted.toString('hex');
}

function decryptAadhar(encrypted) {
  if (!encrypted) return encrypted;
  try {
    const key = (process.env.ENCRYPTION_KEY || 'default-32-char-key-please-change!').slice(0, 32);
    const parts = encrypted.split(':');
    if (parts.length !== 2) return encrypted;
    const iv = Buffer.from(parts[0], 'hex');
    const data = Buffer.from(parts[1], 'hex');
    const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(key, 'utf8'), iv);
    const decrypted = Buffer.concat([decipher.update(data), decipher.final()]);
    return decrypted.toString('utf8');
  } catch (err) {
    // If decryption fails, return original value (avoid crashing)
    return encrypted;
  }
}

const userSchema = new mongoose.Schema(
  {
    // Core authentication
    aadhar: {
      type: String,
      required: true,
      unique: true,
      index: true,
      set: (v) => encryptAadhar(v),
      get: (v) => (process.env.NODE_ENV === 'production' ? decryptAadhar(v) : v),
    },
    password: {
      type: String,
      default: null,
    },
    passwordSetAt: Date,
    firebaseUid: {
      type: String,
      unique: true,
      sparse: true,
      index: true,
    },
    verified: {
      type: Boolean,
      default: false,
    },
    verifiedAt: Date,

    // User profile
    // Display username (exact as user entered)
    username: {
      type: String,
      trim: true,
    },
    // Lowercased username used for uniqueness (case-insensitive)
    usernameLower: {
      type: String,
      unique: true,
      sparse: true,
      index: true,
      set: (v) => (v ? v.toLowerCase() : v),
    },
    usernameSetAt: Date,
    phone: String,
    email: String,
    fullName: String,
    dateOfBirth: Date,
    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
    },

    // Profile media
    profilePic: String, // URL to image
    profilePicUploadedAt: Date,
    documents: [
      {
        type: String, // URL
        uploadedAt: Date,
        documentType: String, // 'aadhar_front', 'aadhar_back', etc.
      },
    ],

    // Location tracking
    currentLocation: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        default: [0, 0],
      },
      address: String,
      accuracy: Number, // meters
      updatedAt: Date,
    },
    locationHistory: [
      {
        coordinates: [Number], // [longitude, latitude]
        address: String,
        accuracy: Number,
        timestamp: {
          type: Date,
          default: Date.now,
        },
      },
    ],

    // Complaint tracking
    complaints: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Complaint',
      },
    ],
    totalComplaints: {
      type: Number,
      default: 0,
    },

    // OTP verification log
    otpVerifications: [
      {
        phone: String,
        verifiedAt: Date,
        ipAddress: String,
      },
    ],

    // Device info
    devices: [
      {
        deviceId: String,
        deviceName: String,
        osType: String, // Android, iOS, Windows
        osVersion: String,
        appVersion: String,
        registeredAt: Date,
        lastActiveAt: Date,
      },
    ],

    // Session management
    lastLogin: Date,
    sessions: [
      {
        token: String,
        deviceId: String,
        createdAt: Date,
        expiresAt: Date,
        ipAddress: String,
      },
    ],

    // Permissions tracking
    permissions: {
      location: {
        type: String,
        enum: ['denied', 'granted', 'pending'],
        default: 'pending',
      },
      camera: {
        type: String,
        enum: ['denied', 'granted', 'pending'],
        default: 'pending',
      },
      microphone: {
        type: String,
        enum: ['denied', 'granted', 'pending'],
        default: 'pending',
      },
      gallery: {
        type: String,
        enum: ['denied', 'granted', 'pending'],
        default: 'pending',
      },
      files: {
        type: String,
        enum: ['denied', 'granted', 'pending'],
        default: 'pending',
      },
    },

    // Account status
    status: {
      type: String,
      enum: ['active', 'suspended', 'deleted'],
      default: 'active',
    },
    deletedAt: Date,

    // Metadata
    metadata: {
      source: String, // 'mobile', 'web', 'admin'
      referredBy: String,
      tags: [String],
    },
  },
  {
    timestamps: true,
    getters: true, // Enable getters for decryption
  }
);

// Index for geospatial queries
userSchema.index({ 'currentLocation.coordinates': '2dsphere' });
userSchema.index({ createdAt: -1 });
userSchema.index({ lastLogin: -1 });

// Virtuals for computed fields
userSchema.virtual('isVerified').get(function () {
  return this.password !== null && this.password !== undefined;
});

userSchema.virtual('totalLocationHistory').get(function () {
  return this.locationHistory ? this.locationHistory.length : 0;
});

// Methods
userSchema.methods.toJSON = function () {
  const obj = this.toObject({ getters: true });
  // Remove sensitive fields
  delete obj.password;
  delete obj.__v;
  // Mask aadhar when present
  try {
    if (obj.aadhar) {
      const raw = typeof obj.aadhar === 'string' ? obj.aadhar : '';
      // If encrypted, decrypt to mask safely
      const decrypted = decryptAadhar(raw);
      const masked = decrypted && decrypted.length >= 8
        ? `${decrypted.slice(0, 4).replace(/./g, '*')}${decrypted.slice(-4)}`
        : '****';
      obj.aadhar = masked;
    }
  } catch (e) {
    obj.aadhar = undefined;
  }
  return obj;
};

userSchema.methods.addLocationUpdate = function (coords, address, accuracy) {
  this.currentLocation = {
    type: 'Point',
    coordinates: [coords.longitude, coords.latitude],
    address,
    accuracy,
    updatedAt: new Date(),
  };

  // Keep last 100 locations in history
  this.locationHistory.push({
    coordinates: [coords.longitude, coords.latitude],
    address,
    accuracy,
    timestamp: new Date(),
  });

  if (this.locationHistory.length > 100) {
    this.locationHistory = this.locationHistory.slice(-100);
  }
};

userSchema.methods.addDevice = function (deviceId, deviceName, osType, osVersion) {
  const existingDevice = this.devices?.find((d) => d.deviceId === deviceId);
  if (existingDevice) {
    existingDevice.lastActiveAt = new Date();
  } else {
    this.devices.push({
      deviceId,
      deviceName,
      osType,
      osVersion,
      registeredAt: new Date(),
      lastActiveAt: new Date(),
    });
  }
};

userSchema.methods.recordOTPVerification = function (phone, ipAddress) {
  this.otpVerifications.push({
    phone,
    verifiedAt: new Date(),
    ipAddress,
  });
  // Keep last 10 verifications
  if (this.otpVerifications.length > 10) {
    this.otpVerifications = this.otpVerifications.slice(-10);
  }
};

// Hash password before saving if modified
userSchema.pre('save', async function (next) {
  try {
    if (this.isModified('password') && this.password) {
      const rounds = parseInt(process.env.BCRYPT_ROUNDS || '10', 10);
      if (!this.password.startsWith('$2a$') && !this.password.startsWith('$2b$')) {
        const salt = await bcrypt.genSalt(rounds);
        this.password = await bcrypt.hash(this.password, salt);
        this.passwordSetAt = new Date();
      }
    }

    // Ensure usernameLower is set for uniqueness and validate username pattern
    if (this.username) {
      const re = /^[A-Za-z0-9_]{3,}$/;
      if (!re.test(this.username)) {
        const err = new Error('Username must be at least 3 characters and contain only letters, numbers, or underscore');
        return next(err);
      }
      this.usernameLower = this.username.toLowerCase();
      this.usernameSetAt = this.usernameSetAt || new Date();
    }

    next();
  } catch (err) {
    next(err);
  }
});

userSchema.methods.recordComplaint = function (complaintId) {
  if (!this.complaints.includes(complaintId)) {
    this.complaints.push(complaintId);
    this.totalComplaints = (this.totalComplaints || 0) + 1;
  }
};

// Static helper to find user by raw Aadhar (handles encryption)
userSchema.statics.findByAadhar = function (aadhar) {
  try {
    const encrypted = encryptAadhar(aadhar);
    return this.findOne({ aadhar: encrypted });
  } catch (e) {
    return this.findOne({ aadhar });
  }
};

module.exports = mongoose.model('User', userSchema);
