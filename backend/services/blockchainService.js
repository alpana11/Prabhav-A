const crypto = require('crypto');
const Block = require('../models/Block');

async function createBlock(action, complaintId, meta) {
  try {
    const last = await Block.findOne().sort({ createdAt: -1 }).limit(1);
    const prevHash = last ? last.hash : '0';
    const timestamp = Date.now();
    const payload = `${action}|${complaintId}|${timestamp}|${prevHash}|${JSON.stringify(meta || {})}`;
    const hash = crypto.createHash('sha256').update(payload).digest('hex');
    const block = await Block.create({ action, complaintId, meta, prevHash, hash });
    console.log(`⛓️  Block created: ${action} for ${complaintId}`);
    return block;
  } catch (err) {
    console.error('❌ Blockchain error:', err);
    throw err;
  }
}

async function getAllBlocks() {
  return Block.find().sort({ createdAt: 1 });
}

module.exports = { createBlock, getAllBlocks };
