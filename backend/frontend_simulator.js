require('dotenv').config();
const http = require('http');

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
  console.log('Frontend simulator starting...');
  await new Promise(r => setTimeout(r, 600));

  // 1) Send OTP for a seeded user (use a known aadhar from seed)
  const aadhar = '12345678901234';
  const sendOtpOpts = { hostname: '127.0.0.1', port: 4000, path: '/api/auth/send-otp', method: 'POST', headers: { 'Content-Type': 'application/json' } };
  const sendRes = await httpRequest(sendOtpOpts, { aadhar });
  console.log('\nsend-otp response:', sendRes.status, sendRes.body);

  const otp = sendRes.body && sendRes.body.otp ? sendRes.body.otp : null;
  if (!otp) {
    console.error('No OTP returned by send-otp (ensure DEBUG_OTP=true in backend .env and server restarted)');
    process.exit(1);
  }

  // 2) Verify OTP
  const verifyOpts = { hostname: '127.0.0.1', port: 4000, path: '/api/auth/verify-otp', method: 'POST', headers: { 'Content-Type': 'application/json' } };
  const verifyRes = await httpRequest(verifyOpts, { aadhar, otp });
  console.log('\nverify-otp response:', verifyRes.status, verifyRes.body);

  const token = verifyRes.body && verifyRes.body.token ? verifyRes.body.token : null;
  if (!token) { console.error('No token returned from verify-otp'); process.exit(1); }

  // 3) Create a complaint using the token
  const createOpts = { hostname: '127.0.0.1', port: 4000, path: '/api/complaints', method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` } };
  const complaintBody = { department: 'sanitation', location: { lat: 19.0, lng: 72.8 }, title: 'Simulator: Garbage pile', description: 'Trash uncollected near street' };
  const createRes = await httpRequest(createOpts, complaintBody);
  console.log('\ncreate complaint response:', createRes.status, createRes.body.message || createRes.body);
  const complaint = createRes.body.complaint || createRes.body;
  const complaintId = complaint ? complaint.complaintId : null;

  // 4) Officer login
  const officerLoginOpts = { hostname: '127.0.0.1', port: 4000, path: '/api/auth/officer-login', method: 'POST', headers: { 'Content-Type': 'application/json' } };
  const officerRes = await httpRequest(officerLoginOpts, { officerId: 'OFF001', password: 'officer123' });
  console.log('\nofficer-login response:', officerRes.status, officerRes.body.message || officerRes.body);
  const officerToken = officerRes.body && officerRes.body.token ? officerRes.body.token : null;

  if (officerToken && complaintId) {
    const updateOpts = { hostname: '127.0.0.1', port: 4000, path: `/api/officers/complaint/${complaintId}/update`, method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${officerToken}` } };
    const updRes = await httpRequest(updateOpts, { status: 'In Progress', remark: 'Assigned to cleaning crew' });
    console.log('\nupdate complaint response:', updRes.status, updRes.body.message || updRes.body);

    const bcOpts = { hostname: '127.0.0.1', port: 4000, path: '/api/blockchain/trail', method: 'GET', headers: { 'Authorization': `Bearer ${officerToken}` } };
    const bcRes = await httpRequest(bcOpts);
    console.log('\nblockchain trail entries:', Array.isArray(bcRes.body) ? bcRes.body.length : bcRes.body);
    if (Array.isArray(bcRes.body)) console.log(bcRes.body.map(b => ({ action: b.action, complaintId: b.complaintId, hash: b.hash })).slice(-5));
  }

  console.log('\nSimulator finished.');
  process.exit(0);
}

run().catch(err => { console.error('Simulator error:', err && err.message ? err.message : err); process.exit(1); });
