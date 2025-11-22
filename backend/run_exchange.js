const http = require('http');
const otpService = require('./services/otpService');

require('./server');

// Generate OTP in-process so we can immediately verify
const aadhar = '123456789012';
const otp = otpService.sendOtp(aadhar);
console.log('Generated OTP (in-process):', otp);

function postVerifyOtp() {
  const data = JSON.stringify({ aadhar, otp });
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
