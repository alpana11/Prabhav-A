const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
const os = require('os');

dotenv.config();

const connectDB = require('./config/db');
const firebaseService = require('./services/firebaseService');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const officerRoutes = require('./routes/officerRoutes');
const adminRoutes = require('./routes/adminRoutes');
const complaintRoutes = require('./routes/complaintRoutes');
const blockchainRoutes = require('./routes/blockchainRoutes');
const feedbackRoutes = require('./routes/feedbackRoutes');
const testRoutes = require('./routes/testRoutes');

const errorHandler = require('./middleware/errorHandler');

const app = express();

// -------- LOGGING --------
app.use(morgan('dev'));

const logger = winston.createLogger({
  level: 'info',
  transports: [new winston.transports.Console()],
});
app.locals.logger = logger;

// -------- MIDDLEWARES --------
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));

// -------- RATE LIMITER --------
app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: 'Too many requests from this IP, please try again later.',
  })
);

// -------- ROUTES --------
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/officers', officerRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/complaints', complaintRoutes);
app.use('/api/feedback', feedbackRoutes);
app.use('/api/blockchain', blockchainRoutes);
app.use('/api/test', testRoutes);

// -------- HEALTH CHECK --------
app.get('/api/health', async (req, res) => {
  try {
    const mongoose = require('mongoose');
    const admin = require('firebase-admin');

    res.json({
      success: true,
      message: 'Backend is healthy',
      timestamp: new Date().toISOString(),
      mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'not connected',
      firebase: admin.apps.length > 0 ? 'initialized' : 'not initialized',
    });
  } catch (e) {
    res.status(500).json({
      success: false,
      message: 'Health check failed',
      error: e.message,
    });
  }
});

// -------- GET LOCAL IP --------
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name in interfaces) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) return iface.address;
    }
  }
  return 'localhost';
}

const LOCAL_IP = getLocalIP();

// -------- ERROR HANDLER --------
app.use(errorHandler);

// -------- SERVER START --------
const PORT = process.env.PORT || 4000;
const HOST = process.env.HOST || '0.0.0.0';

(async () => {
  try {
    await connectDB();
    logger.info('✅ MongoDB connected successfully');
  } catch (err) {
    logger.error('❌ MongoDB connection failed. Exiting.');
    process.exit(1);
  }

  try {
    await firebaseService.initFirebase();
  } catch (e) {
    logger.warn('⚠️ Firebase init skipped:', e.message);
  }

  const server = app.listen(PORT, HOST, () => {
    const addr = server.address();
    logger.info(`------------------------------------------`);
    logger.info(`🟢 SERVER RUNNING`);
    logger.info(`➡️ Local: http://localhost:${PORT}/api`);
    logger.info(`📱 Mobile Access: http://${LOCAL_IP}:${PORT}/api`);
    logger.info(`🌐 Bound to: ${HOST}`);
    logger.info(`------------------------------------------`);
  });

  process.on('uncaughtException', (err) => logger.error('Uncaught Exception:', err));
  process.on('unhandledRejection', (reason, p) => logger.error('Unhandled Rejection:', reason));
})();
