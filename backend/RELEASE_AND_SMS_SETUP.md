# Backend: SMS, OTP, and Release Setup

This document explains how to enable debug OTP, configure an SMS gateway (Twilio), and run the backend for demo or production. It also includes quick test commands.

## Environment variables (recommended `.env`)

Create a `.env` file in the `backend/` folder with the following variables:

```
PORT=4000
MONGO_URI=<your MongoDB connection string>    # optional for demo; if omitted backend will allow offline login
DEBUG_OTP=true                                # true for development/demo (backend returns OTP in response)
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d

# Optional: Twilio SMS (only used if USE_TWILIO=true)
USE_TWILIO=false
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_FROM=+11234567890

# Logging verbosity (info, debug, warn, error)
LOG_LEVEL=info
```

Notes:
- `DEBUG_OTP=true` causes the backend to include the generated OTP in the JSON response for `POST /api/auth/send-otp`. This is safe for local demos but MUST NOT be enabled in production.
- `USE_TWILIO=true` enables sending SMS if the API caller provides a `phone` parameter when requesting OTP. The current app uses only `aadhar`; to send real SMS you must provide a phone number mapping for the user.

## Install and run (development)

Open a terminal in `backend/` and run:

```powershell
cd c:\Users\Lenovo\Documents\shreya\Prabhav\backend
npm install
# start with nodemon for dev
$env:DEBUG_OTP='true'; npm run dev
```

Or (Windows PowerShell) set env from `.env` using `setx` or use a `.env` loader (dotenv is used by the project). If you use a `.env` file, the server will load it automatically.

## Test OTP endpoints (quick curl)

1) Send OTP (returns OTP in JSON when `DEBUG_OTP=true`):

```powershell
curl -X POST http://localhost:4000/api/auth/send-otp -H "Content-Type: application/json" -d "{\"aadhar\":\"123456789012\"}"
```

If you want SMS delivery (Twilio), provide `phone` field and enable `USE_TWILIO=true`:

```powershell
curl -X POST http://localhost:4000/api/auth/send-otp -H "Content-Type: application/json" -d "{\"aadhar\":\"123456789012\", \"phone\": \"+919876543210\"}"
```

The response (with DEBUG_OTP) will include `otp` in the JSON.

2) Verify OTP:

```powershell
curl -X POST http://localhost:4000/api/auth/verify-otp -H "Content-Type: application/json" -d "{\"aadhar\":\"123456789012\",\"otp\":\"<6-digit-otp>\"}"
```

If verification succeeds you will receive a `token` in the JSON.

## Logging

The backend logs via Winston to console. Set `LOG_LEVEL=debug` to get verbose logs during debugging.

## Security notes

- Do NOT enable `DEBUG_OTP=true` in production.
- If enabling Twilio, ensure the `TWILIO` credentials are stored securely and not committed into source control.

## Flutter app: base URL and testing

In the Flutter app, update `lib/core/app_config.dart`'s `baseUrl` to point to your machine where backend runs. Examples:

- Android emulator (Android Studio): `http://10.0.2.2:4000/api`
- iOS simulator: `http://127.0.0.1:4000/api`
- Physical device on same LAN: `http://<your_pc_lan_ip>:4000/api` (ensure firewall allows incoming)

## Release build instructions (Flutter)

### Android (on Windows)

1. Prepare `android/app/build.gradle` for release signing (set `signingConfigs` and `release` block) or use `--no-shrink` for quick demo.
2. Build an APK:

```powershell
# from repo root
flutter clean
flutter pub get
# debug apk
flutter build apk --release
# or build app bundle for Play Store
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk` (APK) or `.aab` for bundle.

Install APK on device (USB debugging):

```powershell
# install
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

### iOS (requires macOS)

1. Open Xcode workspace: `ios/Runner.xcworkspace` and set signing in the Runner target.
2. From macOS terminal:

```bash
flutter clean
flutter pub get
flutter build ios --release
# then open Xcode to archive and export
open ios/Runner.xcworkspace
# Use Xcode -> Product -> Archive to create an exportable .ipa
```

Notes: Building for iOS (archive) and distributing requires valid Apple developer account and provisioning profiles.

## What I changed in backend code

- Added `logger.js` (Winston-based) for consistent logging.
- Made `otpService.sendOtp` asynchronous and able to send SMS via Twilio when `USE_TWILIO=true` and `phone` is provided. Otherwise logs OTP to console (safe for debug/demo).
- Added `twilio` dependency to `package.json`.
- `authController.sendOtp` now awaits `otpService.sendOtp`, accepts optional `phone` in request body, and logs more carefully. Improved error handling and avoids leaking stack traces to responses.

## Next backend improvements you can ask me to implement

- Map Aadhar to a verified phone number in user profiles so OTP can be sent reliably to the user's number.
- Persist OTP attempts to a DB table for audit and better rate-limiting.
- Integrate with a real SMS provider other than Twilio if preferred.
- Add health checks and Prometheus metrics for production.

---

If you want, I can now:
- generate Android release APK/AAB locally (I cannot run `flutter` here, but I can provide exact commands and walk you through), or
- continue implementing API bindings in the Flutter app to fetch real profile and complaint data and persist JWT, or
- implement Twilio sending example that maps Aadhar to phone by looking up user document (requires schema changes).

Which of these do you want me to do next?