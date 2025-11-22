# TWILIO SMS OTP SETUP GUIDE

## Quick Start: Real OTP Delivery in 10 Minutes

This guide shows how to set up Twilio to send real SMS OTP codes to users' phones.

---

## Step 1: Create Twilio Account

1. Go to https://www.twilio.com/try-twilio
2. Sign up with your email
3. Verify your email
4. Create a free trial account
5. You'll get a default phone number (e.g., +1234567890)

---

## Step 2: Get Your Twilio Credentials

1. Log in to Twilio Console: https://console.twilio.com
2. Copy your **Account SID** (starts with `AC...`)
3. Copy your **Auth Token** (keep this secret!)
4. Note your **Twilio Phone Number** (starts with `+1...`)

**Example**:
```
Account SID: ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Auth Token:  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Phone:      +15551234567
```

---

## Step 3: For Testing (Free Twilio Trial)

Twilio free trial limits: You can only send SMS to **verified phone numbers**.

### Add Your Phone Number:
1. In Twilio Console, go to **Phone Numbers → Verified Caller IDs**
2. Click **Verify a Number**
3. Enter your phone number (e.g., +919876543210 for India)
4. Twilio sends you a verification code via SMS
5. Enter the code to verify

**Repeated Testing**:
After verification, you can:
- Send unlimited SMSes to your verified number during trial
- You can verify up to 20 numbers for free trial

---

## Step 4: Update Backend Configuration

### Option A: Environment Variables (.env)

Create file: `backend/.env`

```
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_FROM=+15551234567
PRODUCTION_MODE=false
```

### Option B: Hardcode (Development Only)

**Do NOT do this in production. Use .env instead.**

---

## Step 5: Install Twilio Package

```bash
cd backend
npm install twilio
```

Verify in `package.json`:
```json
{
  "dependencies": {
    "twilio": "^4.0.0"
  }
}
```

---

## Step 6: Verify OTP Service Implementation

Check `backend/services/otpService.js` includes:

```javascript
if (accountSid && authToken && from && phone) {
  try {
    const twilio = require('twilio')(accountSid, authToken);
    const phoneNumber = phone.startsWith('+') ? phone : '+91' + phone;
    const message = await twilio.messages.create({
      body: `Your Prabhav verification code is: ${otp}`,
      from,
      to: phoneNumber,
    });
    logger.info(`SMS sent: ${message.sid} to ${phoneNumber}`);
    return otp;
  } catch (err) {
    throw new Error('Failed to send OTP via SMS');
  }
}
```

---

## Step 7: Test OTP Delivery

### Using curl:

```bash
curl -X POST http://localhost:4000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "aadhar": "123456789012",
    "phone": "+919876543210"
  }'
```

**Expected Response**:
```json
{
  "message": "OTP sent successfully",
  "aadhar": "123456789012"
}
```

**Your Phone**: You should receive SMS within 10 seconds:
```
Your Prabhav verification code is: 654321

This code will expire in 10 minutes.
```

### Using Flutter App:

1. Run `flutter run`
2. Select "Create an Account"
3. Select "Aadhar Card"
4. Enter test Aadhar: 123456789012
5. Enter your verified phone number: 9876543210
6. Tap "Send OTP"
7. Check your phone for SMS

---

## Step 8: For Production (Paid Twilio)

When you're ready to deploy to production:

1. **Upgrade Your Account**:
   - Go to Twilio Console
   - Click on "Account" → "Upgrade"
   - Add payment method
   - Account is now in production mode

2. **Buy a Twilio Phone Number**:
   - Go to **Phone Numbers → Buy Numbers**
   - Choose your country
   - Search for a number (cost: ~$1/month)
   - Click "Buy"
   - Note the number

3. **Update .env**:
```
TWILIO_ACCOUNT_SID=ACxxxxxxxx...
TWILIO_AUTH_TOKEN=xxxxxxxx...
TWILIO_FROM=+new_twilio_number
PRODUCTION_MODE=true
```

4. **Deploy**:
   - Push changes to your server
   - App now sends real SMS to ANY phone number (not just verified ones)

---

## Troubleshooting

### "OTP sent but I didn't receive SMS"

1. Check phone number format:
   - With country code: +919876543210
   - Or without: 9876543210 (backend auto-adds +91)

2. Check number is verified (free trial only)
   - Go to Twilio Console → Verified Caller IDs
   - Is your number listed?

3. Check backend logs:
   ```bash
   tail -f backend.log
   ```
   Look for:
   ```
   Twilio message sent: SMxxxxxxxx to +919876543210
   ```

4. Check phone's carrier:
   - Some carriers block messages from unknown senders
   - Try a different phone

### "Error: Twilio not configured"

1. Check .env file exists: `backend/.env`
2. Check all three variables are set:
   ```
   TWILIO_ACCOUNT_SID=...
   TWILIO_AUTH_TOKEN=...
   TWILIO_FROM=...
   ```
3. Restart backend server: `npm start`

### "Rate limited: Please wait before requesting another OTP"

This is by design. Users must wait 30 seconds between OTP requests.

To reset for testing:
```bash
# Restart backend server
npm start
# OTP memory cache is cleared
```

---

## Cost Estimation

| Usage | Cost |
|-------|------|
| Free Trial | $15 credit (up to ~150 SMS) |
| Paid Account | $0.0075 per SMS in India |
| 1,000 SMS/month | ~$7.50 |
| Twilio Number | $1-2/month |

---

## Next Steps

1. ✅ Create Twilio account
2. ✅ Get credentials
3. ✅ Verify your phone number
4. ✅ Install twilio npm package
5. ✅ Set .env variables
6. ✅ Test with curl or Flutter app
7. ✅ Verify SMS arrives on your phone
8. ✅ Deploy to production (when ready)

---

## Security Notes

**DO NOT**:
- Hardcode credentials in code
- Commit .env file to git
- Share your Auth Token
- Use Twilio number in frontend code

**DO**:
- Keep .env file in backend/ only
- Add `backend/.env` to `.gitignore`
- Use environment variables in production
- Rotate Auth Token annually
- Monitor SMS costs in Twilio Console

---

## Support

- Twilio Docs: https://www.twilio.com/docs
- SMS API Docs: https://www.twilio.com/docs/sms
- Support: support@twilio.com
