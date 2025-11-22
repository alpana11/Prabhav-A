const mongoose = require('mongoose');
require('dotenv').config();

async function run() {
  try {
    await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
    console.log('Connected to MongoDB for counts');
    const db = mongoose.connection.db;
    const names = ['users','officers','complaints','blocks'];
    for (const name of names) {
      try {
        const count = await db.collection(name).countDocuments();
        console.log(`${name}: ${count}`);
      } catch (e) {
        console.log(`${name}: error (${e.message})`);
      }
    }
  } catch (err) {
    console.error('Connection error:', err && err.message ? err.message : err);
  } finally {
    process.exit(0);
  }
}

run();
