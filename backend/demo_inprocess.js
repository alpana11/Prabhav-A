require('dotenv').config();
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const http = require('http');

// Start server in this process so demo can call HTTP endpoints reliably
require('./server');

const User = require('./models/User');

function httpRequest(options, body) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch (e) { resolve({ status: res.statusCode, body: data }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function run() {
  // wait a bit for server to start
  await new Promise(r => setTimeout(r, 800));

  await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
  console.log('Connected to MongoDB (demo in-process)');

  const user = await User.findOne({ aadhar: '12345678901234' });
  if (!user) { console.error('Seed user not found'); process.exit(1); }
  console.log('Using user:', user.name, user._id.toString());

  const token = jwt.sign({ id: user._id.toString(), role: 'user' }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });

  // 1) Create a complaint as user
  const createOpts = {
    hostname: '127.0.0.1', port: 4000, path: '/api/complaints', method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }
  };
  const complaintBody = { department: 'road', location: { lat: 19.0760, lng: 72.8777 }, title: 'Demo: Broken Bench', description: 'Bench broken near park' };
  const createRes = await httpRequest(createOpts, complaintBody);
  console.log('\nCreate complaint response:', createRes.status, createRes.body.message || createRes.body);
  const complaint = createRes.body.complaint || createRes.body;
  const complaintId = complaint ? complaint.complaintId : null;

  // 2) Officer login
  const officerLoginOpts = { hostname: '127.0.0.1', port: 4000, path: '/api/auth/officer-login', method: 'POST', headers: { 'Content-Type': 'application/json' } };
  const officerRes = await httpRequest(officerLoginOpts, { officerId: 'OFF001', password: 'officer123' });
  console.log('\nOfficer login:', officerRes.status, officerRes.body.message || officerRes.body);
  const officerToken = officerRes.body.token;

  // 3) Officer: get department complaints
  const getDeptOpts = { hostname: '127.0.0.1', port: 4000, path: '/api/officers/department/complaints', method: 'GET', headers: { 'Authorization': `Bearer ${officerToken}` } };
  const deptRes = await httpRequest(getDeptOpts);
  console.log('\nDepartment complaints count:', Array.isArray(deptRes.body) ? deptRes.body.length : deptRes.body);

  // 4) Officer: update complaint status
  if (complaintId) {
    const updateOpts = { hostname: '127.0.0.1', port: 4000, path: `/api/officers/complaint/${complaintId}/update`, method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${officerToken}` } };
    const updRes = await httpRequest(updateOpts, { status: 'In Progress', remark: 'Assigned to team' });
    console.log('\nUpdate complaint response:', updRes.status, updRes.body.message || updRes.body);
  }

  // 5) Fetch blockchain trail
  const bcOpts = { hostname: '127.0.0.1', port: 4000, path: '/api/blockchain/trail', method: 'GET', headers: { 'Authorization': `Bearer ${officerToken}` } };
  const bcRes = await httpRequest(bcOpts);
  console.log('\nBlockchain trail entries:', Array.isArray(bcRes.body) ? bcRes.body.length : bcRes.body);
  if (Array.isArray(bcRes.body)) console.log(bcRes.body.map(b => ({ action: b.action, complaintId: b.complaintId, hash: b.hash })).slice(-5));

  // Keep process alive briefly to show server logs
  setTimeout(() => process.exit(0), 1000);
}

run().catch(err => { console.error('Demo error:', err && err.message ? err.message : err); process.exit(1); });
