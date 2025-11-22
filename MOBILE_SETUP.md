# Mobile Setup Guide for PRABHAV App

## Your Network Configuration
- **PC IP Address**: `192.168.29.50`
- **Backend API**: `http://192.168.29.50:4000/api`
- **Port**: `4000`

---

## Prerequisites

### For Android (Physical Phone or Emulator)
- Install [Android Studio](https://developer.android.com/studio)
- Enable USB Debugging on your phone (Settings → Developer Options)
- Connect phone via USB or use emulator

### For iOS (Physical Phone or Simulator)
- Install [Xcode](https://apps.apple.com/us/app/xcode/id497799835)
- Ensure iOS Deployment Target ≥ 11.0

### Both Platforms
- Install [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Install dependencies: `flutter pub get`

---

## Step 1: Start the Backend Server

Open a terminal and run:

```bash
cd backend
npm start
```

You should see:
```
✅ Server running on port 4000
📝 Backend ready at http://localhost:4000
🔗 Base API URL: http://localhost:4000/api
📱 Access from mobile on local network: http://192.168.29.50:4000/api
✅ MongoDB connected successfully
```

**⚠️ Important**: Keep this terminal open while testing on mobile.

---

## Step 2: Get Flutter Dependencies

From the repo root:

```bash
flutter pub get
```

This installs all required packages including the `http` package for API calls.

---

## Step 3: Run on Mobile/Emulator

### For Android Emulator:
```bash
flutter emulators --launch Pixel_5  # or your emulator name
flutter run
```

### For Android Physical Device:
```bash
# Ensure USB debugging is ON and device is connected
flutter run
```

### For iOS Simulator:
```bash
open -a Simulator
flutter run
```

### For iOS Physical Device:
```bash
# Ensure device is connected and provisioned in Xcode
flutter run -d <device-id>
```

---

## Step 4: Test the App on Mobile

1. **Login**: 
   - Enter any Aadhaar number (e.g., `123456789012`)
   - Tap "Send OTP"
   - Backend logs will show: `🔐 OTP for Aadhar 123456789012: XXXXXX`
   - Enter the OTP from the debug message (because `DEBUG_OTP=true` in backend `.env`)

2. **Create a Complaint**:
   - After login, navigate to "Register Complaint"
   - Fill in details and submit
   - Complaint appears in backend MongoDB
   - Blockchain audit entry created automatically

3. **Officer Dashboard** (if available):
   - Officer ID: `OFF001`
   - Password: `officer123`
   - View and update complaint status
   - Blockchain logs every update

---

## Troubleshooting

### ❌ "Connection Refused" Error
**Problem**: App cannot reach backend
**Solution**: 
- Ensure backend is running (`npm start` in `backend/`)
- Check that `http://192.168.29.50:4000/api` is accessible from your phone
- Both phone and PC must be on the same WiFi network
- Disable VPN or firewalls if blocking connections

### ❌ "Invalid or Expired OTP"
**Problem**: OTP doesn't match
**Solution**:
- Enable `DEBUG_OTP=true` in `backend/.env` (already done)
- Restart backend: `npm start`
- Check server logs for printed OTP
- OTP expires after 5 minutes

### ❌ "Cannot reach 192.168.29.50"
**Problem**: Network routing issue
**Solution**:
- Confirm PC and phone on same WiFi
- Run `ipconfig` on PC to verify IP is `192.168.29.50`
- If different, update `lib/core/app_config.dart`:
  ```dart
  static const String baseUrl = 'http://<YOUR_PC_IP>:4000/api';
  ```

### ❌ "Build Errors"
**Problem**: Flutter build fails
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

---

## API Endpoints Available on Mobile

All endpoints use `http://192.168.29.50:4000/api`:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/auth/send-otp` | POST | Send OTP to Aadhaar |
| `/auth/verify-otp` | POST | Verify OTP and get JWT |
| `/auth/officer-login` | POST | Officer login |
| `/complaints` | POST | Create complaint |
| `/complaints/:id` | GET | Get complaint details |
| `/officers/department/complaints` | GET | List officer's complaints |
| `/officers/complaint/:id/update` | POST | Update complaint status |
| `/blockchain/trail` | GET | Fetch audit trail |

---

## Architecture Diagram

```
┌─────────────────────────────────────────┐
│          MOBILE DEVICE/EMULATOR         │
│  ┌─────────────────────────────────────┐│
│  │      PRABHAV Flutter App            ││
│  │  ┌───────────────────────────────┐ ││
│  │  │ auth_form_widget.dart         │ ││
│  │  │ - Send OTP to 192.168.29.50   │ ││
│  │  │ - Verify OTP & get JWT        │ ││
│  │  └───────────────────────────────┘ ││
│  │  ┌───────────────────────────────┐ ││
│  │  │ complaint_screen.dart         │ ││
│  │  │ - Create complaint via API    │ ││
│  │  │ - Update status               │ ││
│  │  └───────────────────────────────┘ ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
            │
            │ HTTP/HTTPS (REST API)
            │ Base: http://192.168.29.50:4000/api
            │
            ▼
┌─────────────────────────────────────────┐
│    NODE.JS BACKEND (PRABHAV SERVER)     │
│  ┌─────────────────────────────────────┐│
│  │ server.js (listening 0.0.0.0:4000)  ││
│  │ - Authentication & OTP service      ││
│  │ - Complaint CRUD operations         ││
│  │ - Officer operations                ││
│  └─────────────────────────────────────┘│
│  ┌─────────────────────────────────────┐│
│  │ Blockchain Service                  ││
│  │ - SHA-256 audit trail logging       ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
            │
            │ Mongoose ODM
            │
            ▼
┌─────────────────────────────────────────┐
│     MONGODB ATLAS (Cloud Database)      │
│  - users, officers, complaints, blocks  │
│  - All data persisted & synced          │
└─────────────────────────────────────────┘
```

---

## Performance Tips

1. **Keep logs clear**: Disable `DEBUG_OTP` in production
2. **Use WiFi**: 5G/WiFi for better latency than mobile data
3. **Check network latency**: Network → API calls → DB → Response
4. **Increase timeout** if mobile device is slow: Edit `lib/core/api_service.dart`

---

## Next Steps

After running the app successfully on mobile:
1. Test all features (OTP, complaints, officer workflows)
2. Verify blockchain audit trail
3. Check data in MongoDB Atlas dashboard
4. Create a demo video showing app flow
5. In production: rotate `DEBUG_OTP` and add proper OTP SMS integration

---

## Support

If issues occur:
1. Check backend logs (`npm start` terminal)
2. Verify network connectivity: `ping 192.168.29.50`
3. Confirm MongoDB is accessible
4. Check Flutter logs: `flutter logs`

