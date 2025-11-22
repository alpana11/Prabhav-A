const http = require('http');

// Require the server which will start Express (server.js logs when ready)
require('./server');

// Small helper to POST JSON to send-otp and print response
function postSendOtp() {
  const data = JSON.stringify({ aadhar: '123456789012' });
  const options = {
    hostname: '127.0.0.1',
    port: 4000,
    path: '/api/auth/send-otp',
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
      // Allow a short delay for server console logs to flush, then exit
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

// Wait a moment for server to be ready (server.js logs readiness immediately)
setTimeout(postSendOtp, 1200);
