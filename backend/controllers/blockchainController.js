const blockchain = require('../services/blockchainService');

exports.getTrail = async (req, res) => {
  try {
    const logs = await blockchain.getAllBlocks();
    res.json(logs);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching audit trail' });
  }
};
