const http = require('http');

require('./server');

function postVerifyOtp() {
  const data = JSON.stringify({ aadhar: '123456789012', otp: '518699' });
  const options = {
    hostname: '127.0.0.1',
    port: 4000,
    path: '/api/auth/verify-otp',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(data)
    }
  };

  const req = http.request(options, (res) => {
    let body = '';
    res.on('data', (chunk) => { body += chunk; });
    res.on('end', () => {
      console.log('--- HTTP Response ---');
      console.log('Status:', res.statusCode);
      console.log('Body:', body);
      setTimeout(() => process.exit(0), 500);
    });
  });

  req.on('error', (err) => {
    console.error('Request error:', err.message || err);
    process.exit(2);
  });

  req.write(data);
  req.end();
}

setTimeout(postVerifyOtp, 1200);
