const jwt = require('jsonwebtoken');
const logger = require('../logger');

/**
 * Verify JWT token and attach user to request
 */
const authMiddleware = (req, res, next) => {
  try {
    const auth = req.headers.authorization;
    
    if (!auth || !auth.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized - No token provided',
      });
    }

    const token = auth.split(' ')[1];

    try {
      const decoded = jwt.verify(
        token,
        process.env.JWT_SECRET || 'dev-secret'
      );
      req.userId = decoded.userId || decoded.id || null;
      // Provide a normalized req.user with `id` for controllers that expect req.user.id
      req.user = Object.assign({}, decoded, { id: decoded.userId || decoded.id });
      next();
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'Token expired. Please login again.',
        });
      }
      return res.status(401).json({
        success: false,
        message: 'Invalid token',
      });
    }
  } catch (error) {
    logger.error(`[AUTH] authMiddleware error: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Authentication error',
    });
  }
};

// Export both default function and named property for compatibility
module.exports = authMiddleware;
module.exports.authMiddleware = authMiddleware;
