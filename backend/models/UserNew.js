const mongoose = require('mongoose');
const crypto = require('crypto');

// Encryption helper for sensitive data
function encryptAadhar(aadhar) {
  const cipher = crypto.createCipher('aes-256-cbc', process.env.ENCRYPTION_KEY || 'default-key');
  return cipher.update(aadhar, 'utf8', 'hex') + cipher.final('hex');
}

function decryptAadhar(encrypted) {
  const decipher = crypto.createDecipher('aes-256-cbc', process.env.ENCRYPTION_KEY || 'default-key');
  return decipher.update(encrypted, 'hex', 'utf8') + decipher.final('utf8');
}

const userSchema = new mongoose.Schema(
  {
    // Core authentication
    aadhar: {
      type: String,
      required: true,
      unique: true,
      index: true,
      // Store encrypted in production
      set: (v) => encryptAadhar(v),
      get: (v) => (process.env.NODE_ENV === 'production' ? decryptAadhar(v) : v),
    },
    password: {
      type: String,
      default: null, // Null until user sets password
    },
    passwordSetAt: Date,

    // User profile
    username: {
      type: String,
      unique: true,
      sparse: true,
      index: true,
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
  const obj = this.toObject();
  delete obj.password;
  delete obj.__v;
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

userSchema.methods.recordComplaint = function (complaintId) {
  if (!this.complaints.includes(complaintId)) {
    this.complaints.push(complaintId);
    this.totalComplaints = (this.totalComplaints || 0) + 1;
  }
};

module.exports = mongoose.model('User', userSchema);
