const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    // Prefer explicit Atlas URI if provided, otherwise fallback to MONGO_URI or local
    const uri = process.env.MONGO_ATLAS_URI || process.env.MONGO_URI || 'mongodb://localhost:27017/prabhav';

    const connectOptions = {
      // keep sensible defaults and retry behavior for Atlas
      maxPoolSize: parseInt(process.env.MONGO_MAX_POOL_SIZE || '10', 10),
      serverSelectionTimeoutMS: parseInt(process.env.MONGO_SERVER_SELECTION_TIMEOUT_MS || '5000', 10),
      socketTimeoutMS: parseInt(process.env.MONGO_SOCKET_TIMEOUT_MS || '45000', 10),
      family: 4, // prefer IPv4 to avoid potential IPv6 resolution issues on some systems
      retryWrites: true,
    };

    await mongoose.connect(uri, connectOptions);
    console.log('✅ MongoDB connected successfully');
  } catch (err) {
    console.error('❌ MongoDB connection failed:', err.message);
    throw err;
  }
};

module.exports = connectDB;
