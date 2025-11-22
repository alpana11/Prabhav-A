const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('./models/User');
const Officer = require('./models/Officer');
const Complaint = require('./models/Complaint');
const Block = require('./models/Block');

const connectDB = async () => {
  try {
    const uri = process.env.MONGO_URI || 'mongodb://localhost:27017/prabhav';
    await mongoose.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    console.log('✅ MongoDB connected');
  } catch (err) {
    console.error('⚠️  MongoDB not available. Using mock data mode.');
    console.log('\n💡 To use real MongoDB:');
    console.log('   1. Install MongoDB locally OR');
    console.log('   2. Update MONGO_URI in .env with your MongoDB Atlas connection string');
    process.exit(0);
  }
};

const seedData = async () => {
  try {
    // Attempt to remove any non-default indexes on collections that may block seeding
    try {
      const db = mongoose.connection.db;
      const colls = ['users', 'officers', 'complaints', 'blocks'];
      for (const name of colls) {
        try {
          const coll = db.collection(name);
          const indexes = await coll.indexes();
          for (const ix of indexes) {
            if (ix.name && ix.name !== '_id_') {
              try {
                await coll.dropIndex(ix.name);
                console.log(`🗑️ Dropped legacy index ${ix.name} on ${name} collection`);
              } catch (dropErr) {
                console.warn(`Could not drop index ${ix.name} on ${name}:`, dropErr.message || dropErr);
              }
            }
          }
        } catch (cErr) {
          console.warn(`Could not inspect indexes for ${name}:`, cErr.message || cErr);
        }
      }
    } catch (ixErr) {
      // Non-fatal: log and continue
      console.warn('Index cleanup error (continuing):', ixErr.message || ixErr);
    }

    // Clear existing data
    await User.deleteMany({});
    await Officer.deleteMany({});
    await Complaint.deleteMany({});
    await Block.deleteMany({});
    console.log('🧹 Cleared existing data');

    // Create test users
    const users = await User.create([
      {
        aadhar: '12345678901234',
        name: 'Raj Kumar',
        phone: '9876543210',
        address: 'Mumbai, Maharashtra',
        email: 'raj@example.com'
      },
      {
        aadhar: '98765432109876',
        name: 'Priya Singh',
        phone: '9123456789',
        address: 'Delhi, India',
        email: 'priya@example.com'
      },
      {
        aadhar: '11111111111111',
        name: 'Amit Patel',
        phone: '9999999999',
        address: 'Bangalore, Karnataka',
        email: 'amit@example.com'
      }
    ]);
    console.log('👥 Created 3 test users');

    // Create test officers
    const officers = await Officer.create([
      {
        officerId: 'OFF001',
        password: 'officer123',
        name: 'Vikram Sharma',
        department: 'road'
      },
      {
        officerId: 'OFF002',
        password: 'officer123',
        name: 'Neha Gupta',
        department: 'water'
      },
      {
        officerId: 'OFF003',
        password: 'officer123',
        name: 'Suresh Kumar',
        department: 'electricity'
      },
      {
        officerId: 'OFF004',
        password: 'officer123',
        name: 'Meera Desai',
        department: 'sanitation'
      }
    ]);
    console.log('👮 Created 4 test officers (departments: road, water, electricity, sanitation)');

    // Create test complaints
    const complaints = await Complaint.create([
      {
        complaintId: 'C-001',
        citizen: users[0]._id,
        department: 'road',
        location: { lat: 19.0760, lng: 72.8777 },
        title: 'Large pothole on Main Street',
        description: 'Dangerous pothole causing accidents near market',
        status: 'Pending',
        remarks: []
      },
      {
        complaintId: 'C-002',
        citizen: users[1]._id,
        department: 'water',
        location: { lat: 28.6139, lng: 77.2090 },
        title: 'Water supply broken',
        description: 'No water supply for 3 days in the area',
        status: 'In Progress',
        remarks: [
          {
            officer: officers[1]._id,
            remark: 'Investigation started. Found pipe burst at Junction 5.',
            images: [],
            createdAt: new Date()
          }
        ]
      },
      {
        complaintId: 'C-003',
        citizen: users[2]._id,
        department: 'electricity',
        location: { lat: 13.0827, lng: 80.2707 },
        title: 'Power outage',
        description: 'Frequent power cuts affecting household appliances',
        status: 'Resolved',
        remarks: [
          {
            officer: officers[2]._id,
            remark: 'Transformer replaced successfully',
            images: [],
            createdAt: new Date()
          }
        ]
      }
    ]);
    console.log('📝 Created 3 test complaints');

    console.log('\n✨ Database seeded successfully!\n');
    console.log('📊 Test Data:');
    console.log('   Users: 3 (with Aadhar numbers)');
    console.log('   Officers: 4 (all departments)');
    console.log('   Complaints: 3 (various statuses)');
    console.log('\n🔐 Officer Login Credentials:');
    console.log('   - OFF001 / officer123 (Road Department)');
    console.log('   - OFF002 / officer123 (Water Department)');
    console.log('   - OFF003 / officer123 (Electricity Department)');
    console.log('   - OFF004 / officer123 (Sanitation Department)');
    console.log('\n💡 Admin Login:');
    console.log('   - Username: admin');
    console.log('   - Password: admin123');
    console.log('\n👤 User Aadhar Numbers:');
    console.log('   - 12345678901234 (Raj Kumar)');
    console.log('   - 98765432109876 (Priya Singh)');
    console.log('   - 11111111111111 (Amit Patel)');

    process.exit(0);
  } catch (err) {
    console.error('❌ Seeding error:', err.message);
    process.exit(1);
  }
};

connectDB().then(() => seedData());
