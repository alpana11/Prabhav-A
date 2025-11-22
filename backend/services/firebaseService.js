const admin = require('firebase-admin');
const logger = require('../logger');
const path = require('path');

let bucket = null;

async function initFirebase() {
  try {
    // Avoid top-level require of packages that may be published as ESM
    // Initialize using GOOGLE_APPLICATION_CREDENTIALS if present, otherwise try JSON from env
    if (admin.apps && admin.apps.length > 0) return;

    if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
      const keyPath = path.resolve(path.join(__dirname, '..', process.env.FIREBASE_SERVICE_ACCOUNT_PATH));
      console.log('[Firebase] Loading service account from:', keyPath);
      admin.initializeApp({
        credential: admin.credential.cert(require(keyPath)),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
      });
    } else if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
      const svc = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
      admin.initializeApp({
        credential: admin.credential.cert(svc),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
      });
    } else {
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
      });
    }

    const bucketName = process.env.FIREBASE_STORAGE_BUCKET || (admin?.options?.storageBucket);
    if (!bucketName) {
      logger.warn('Firebase storage bucket not configured: set FIREBASE_STORAGE_BUCKET');
    } else {
      // dynamic import in case @google-cloud/storage is an ESM package
      // but admin.storage() is sufficient to get bucket; keep dynamic import as fallback
      bucket = admin.storage().bucket(bucketName);
      logger.info(`✅ Firebase initialized with bucket: ${bucketName}`);
    }
  } catch (err) {
    logger.error('❌ Firebase initialization failed:', err.message || err);
    console.error(err);
  }
}

/**
 * Upload a buffer to Firebase Storage and return a public URL (signed URL)
 * @param {Buffer} buffer
 * @param {string} filename
 * @param {string} contentType
 */
async function uploadBuffer(buffer, filename, contentType = 'application/octet-stream') {
  try {
    if (!admin.apps || admin.apps.length === 0) initFirebase();
    if (!bucket) {
      throw new Error('Firebase bucket not configured');
    }

    const file = bucket.file(filename);
    const stream = file.createWriteStream({ metadata: { contentType } });

    await new Promise((resolve, reject) => {
      stream.on('error', (err) => reject(err));
      stream.on('finish', () => resolve());
      stream.end(buffer);
    });

    // Make file private but return a signed URL
    const expiresAt = Date.now() + (1000 * 60 * 60 * 24 * 365); // 1 year
    const [url] = await file.getSignedUrl({ action: 'read', expires: new Date(expiresAt) });
    return url;
  } catch (err) {
    logger.error('Firebase upload error:', err.message || err);
    throw err;
  }
}

module.exports = { initFirebase, uploadBuffer };
