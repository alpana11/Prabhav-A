# 🚀 PRABHAV - QUICK START GUIDE

**Get Production App Live in 1 Hour**

---

## ⏱️ 5-Minute Prerequisites

### What You Need
- Twilio account (free): https://www.twilio.com/console
- MongoDB account (free): https://mongodb.com/cloud/atlas
- Backend running or Heroku account
- Android device or emulator

---

## 🔴 STEP 1: Get Twilio SMS (10 minutes)

### 1.1 Create Twilio Account
```
1. Go to twilio.com
2. Sign up (free $15 credit)
3. Verify email and phone
4. Log in to console
```

### 1.2 Get Your Credentials
```
Dashboard → Account
Copy these values:
- Account SID: ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
- Auth Token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Phone Numbers section:
- Copy your Twilio number (+1234567890)
```

### 1.3 Add to .env File
```bash
cd backend
nano .env  # or edit in VS Code

# Add these lines:
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_FROM=+1234567890
```

---

## 🔵 STEP 2: Setup MongoDB (5 minutes)

### 2.1 Create MongoDB Atlas Cluster
```
1. Go to mongodb.com/cloud/atlas
2. Create free account
3. Create M0 free cluster
4. Wait 2-3 minutes for cluster creation
```

### 2.2 Get Connection String
```
Cluster → Connect → Application
Copy connection string

Example:
mongodb+srv://user:pass@cluster.mongodb.net/prabhav?retryWrites=true&w=majority
```

### 2.3 Add to .env File
```bash
# In backend/.env
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/prabhav?retryWrites=true&w=majority
```

### 2.4 Create Database User
```
Security → Database Access → Add New User
Username: prabhav
Password: your_secure_password

(Update password in MONGO_URI)
```

### 2.5 Whitelist IP Address
```
Security → Network Access → Add IP Address
Choose: Add Current IP Address
(Or 0.0.0.0/0 for testing)
```

---

## 💚 STEP 3: Start Backend Server (5 minutes)

### 3.1 Install Dependencies
```bash
cd backend
npm install
```

### 3.2 Create .env File
```bash
cp .env.sample .env
```

### 3.3 Edit .env (Add Your Credentials)
```env
NODE_ENV=production
PORT=4000
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/prabhav
JWT_SECRET=your-super-secret-key-min-32-chars-long
ENCRYPTION_KEY=32-char-base64-encoded-key
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_FROM=+1234567890
```

### 3.4 Start Server
```bash
npm start
```

### 3.5 Verify Server Running
```bash
# In another terminal
curl http://localhost:4000/health

# Should return:
# {"success":true,"message":"Server is running"}
```

---

## 🟢 STEP 4: Test API (5 minutes)

### Using Postman
```
1. Open Postman
2. Import: backend/POSTMAN_COLLECTION.json
3. Set base_url to: http://localhost:4000/api
4. Run "Send OTP" request
5. Check terminal for OTP (in dev mode)
6. Continue with Verify OTP
```

### Using cURL
```bash
# Test 1: Send OTP
curl -X POST http://localhost:4000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"aadhar":"123456789012","phone":"YOUR_PHONE"}'

# You should receive OTP via SMS

# Test 2: Verify OTP (replace with received OTP)
curl -X POST http://localhost:4000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"aadhar":"123456789012","otp":"123456"}'
```

---

## 💜 STEP 5: Setup Frontend (5 minutes)

### 5.1 Get Backend IP Address
```bash
# On Windows (where backend is running)
ipconfig

# Find IPv4 Address (e.g., 192.168.1.100)
```

### 5.2 Update API Base URL
```dart
# Edit: lib/services/api_service.dart

# Find this line:
const baseUrl = 'http://192.168.29.50:4000/api';

# Replace 192.168.29.50 with YOUR backend IP:
const baseUrl = 'http://YOUR_IP:4000/api';
```

### 5.3 Install Flutter Dependencies
```bash
flutter pub get
```

### 5.4 Get Device ID
```bash
flutter devices

# Output:
# CPH2717 (mobile) • I7FIVOAYLFVWIFVC • android-arm64 • Android 12
#   ↑ Use this device ID
```

---

## 🔴 STEP 6: Run App on Device (5 minutes)

### 6.1 Start App
```bash
flutter run -d I7FIVOAYLFVWIFVC

# Replace I7FIVOAYLFVWIFVC with your device ID
```

### 6.2 Test Authentication Flow
```
1. App opens → Aadhar Entry Screen
2. Enter:
   - Aadhar: 123456789012
   - Phone: Your actual phone number
3. Click "Send OTP"
4. Wait for SMS (30-60 seconds)
5. Enter OTP on next screen
6. Set Password (8+ chars: uppercase, lowercase, number, special)
7. Set Username (3+ chars, alphanumeric)
8. Login page appears
9. Login with Aadhar + password you set
10. See your profile!
```

---

## ✨ WHAT YOU'VE ACCOMPLISHED

✅ Real OTP delivery via Twilio SMS  
✅ Complete authentication system  
✅ User profile management  
✅ Location tracking  
✅ Permission handling  
✅ Secure database  
✅ Production-ready API  
✅ Flutter mobile app  

---

## 🚨 COMMON ISSUES & FIXES

### "OTP not received"
```
1. Check Twilio account has credits
2. Verify phone number format (+91XXXXXXXXXX)
3. Check backend logs: npm start output
4. Verify TWILIO credentials in .env
```

### "Backend Connection Error"
```
1. Verify backend running: curl http://localhost:4000/health
2. Check API_BASE_URL is correct in api_service.dart
3. Verify backend IP address (ipconfig on Windows)
4. Check firewall not blocking port 4000
```

### "MongoDB Connection Failed"
```
1. Verify MONGO_URI is correct in .env
2. Check IP whitelist in MongoDB Atlas (0.0.0.0/0)
3. Verify database user credentials
4. Check internet connection
```

### "App crashes on startup"
```
1. Check Flutter version: flutter --version (should be 3.0+)
2. Verify all dependencies: flutter pub get
3. Check API base URL is reachable
4. View logs: flutter run -v
```

---

## 📊 API ENDPOINTS REFERENCE

### Auth Endpoints
```
POST   /api/auth/send-otp        → Get OTP via SMS
POST   /api/auth/verify-otp      → Verify OTP code
POST   /api/auth/set-password    → Set password
POST   /api/auth/set-username    → Set username
POST   /api/auth/login           → Login with Aadhar + password
```

### User Endpoints
```
GET    /api/user/profile         → Get profile
PUT    /api/user/profile         → Update profile
POST   /api/user/location        → Update location
GET    /api/user/location-history → Get location history
```

### Test Endpoints
```
GET    /api/test/status          → Health check
GET    /health                   → Server health
```

---

## 🎯 NEXT STEPS

### Deploy to Production (30 min)
```bash
# Option 1: Heroku (Easiest)
heroku login
heroku create prabhav-api
git push heroku main

# Option 2: Digital Ocean ($5/month)
# See DEPLOYMENT_GUIDE.md

# Option 3: Docker
docker build -t prabhav .
docker run -p 4000:4000 prabhav
```

### Build Release APK (15 min)
```bash
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
# Share with testers or upload to Play Store
```

### Monitor Live System
```bash
# View backend logs
npm start  # Shows all requests

# Check database
MongoDB Atlas → Cluster → Collections
```

---

## 📱 TEST ACCOUNTS

Create your own accounts using the app!

**For Testing**:
```
Aadhar: 123456789012
Phone: Your phone number (will receive SMS)
Password: SecurePass123!
Username: testuser
```

---

## 🔐 SECURITY CHECKLIST

Before going live:
- [ ] Change JWT_SECRET to random 32+ char key
- [ ] Use HTTPS (not HTTP) in production
- [ ] Enable MongoDB encryption
- [ ] Whitelist specific IPs (not 0.0.0.0/0)
- [ ] Setup regular backups
- [ ] Monitor Twilio costs
- [ ] Enable CORS for specific domains
- [ ] Setup error monitoring (Sentry)

---

## 📞 HELP & DOCUMENTATION

**Full Documentation**:
- API Reference: `backend/BACKEND_README.md`
- Deployment Guide: `DEPLOYMENT_GUIDE.md`
- Production Summary: `PRODUCTION_READY_SUMMARY.md`
- API Testing: `backend/POSTMAN_COLLECTION.json`

**Twilio Help**:
- https://www.twilio.com/docs/sms

**MongoDB Help**:
- https://docs.mongodb.com/manual/

**Flutter Help**:
- https://flutter.dev/docs

---

## ⏱️ TIME BREAKDOWN

```
Twilio Setup:        10 min
MongoDB Setup:        5 min
Backend Config:       5 min
Backend Start:        5 min
API Testing:          5 min
Frontend Update:      5 min
App on Device:        5 min
Full Auth Test:       5 min
─────────────────────────
TOTAL:              50 minutes
```

**You're live in under 1 hour!** 🎉

---

**Status**: ✅ READY TO DEPLOY

Start with Step 1 above and you'll have production app running in 1 hour!

If you get stuck on any step, check the "COMMON ISSUES & FIXES" section above.

Good luck! 🚀
