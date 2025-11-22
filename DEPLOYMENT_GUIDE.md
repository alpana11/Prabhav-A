# PRABHAV Production Deployment Guide

## Table of Contents
1. [Backend Setup](#backend-setup)
2. [Frontend Setup](#frontend-setup)
3. [Database Configuration](#database-configuration)
4. [SMS & Authentication](#sms--authentication)
5. [Deployment](#deployment)
6. [Troubleshooting](#troubleshooting)

---

## Backend Setup

### Prerequisites
- Node.js v16+ (LTS recommended)
- MongoDB Atlas or local MongoDB
- Twilio Account (for SMS)
- npm or yarn

### Installation Steps

```bash
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.sample .env

# Fill in your configuration in .env
# Edit these critical variables:
# - MONGO_URI: Your MongoDB connection string
# - JWT_SECRET: Strong random string (min 32 chars)
# - ENCRYPTION_KEY: 32-character random string for Aadhar encryption
# - TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM
```

### Environment Variables Setup

```env
# .env file
NODE_ENV=production
PORT=4000
HOST=0.0.0.0
DISPLAY_IP=your_ip_address

# MongoDB
MONGO_URI=mongodb+srv://user:password@cluster.mongodb.net/prabhav

# JWT
JWT_SECRET=your_random_secret_key_min_32_chars
JWT_EXPIRES_IN=30d

# Encryption
ENCRYPTION_KEY=your_32_char_encryption_key

# Twilio
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_token_here
TWILIO_FROM=+1234567890
```

### Start Backend

```bash
# Development
npm start

# Production with PM2
npm install -g pm2
pm2 start server.js --name "prabhav-api"
pm2 save
pm2 startup
```

The backend will be available at:
- Local: `http://localhost:4000/api`
- Network: `http://{YOUR_IP}:4000/api`

---

## Frontend Setup

### Prerequisites
- Flutter 3.0+
- Android SDK 28+ (for Android)
- Xcode 13+ (for iOS, if applicable)

### Installation Steps

```bash
# Get dependencies
flutter pub get

# Run app on device/emulator
flutter run -d <device_id>

# Build for release
flutter build apk --release
flutter build appbundle --release  # For Play Store
```

### Configuration

Update the API base URL in `lib/services/api_service.dart`:

```dart
static const String _baseUrl = 'http://YOUR_IP:4000/api';
```

---

## Database Configuration

### MongoDB Atlas Setup

1. Create a MongoDB Atlas account at https://www.mongodb.com/cloud/atlas
2. Create a new project and cluster
3. Get connection string: `mongodb+srv://user:password@cluster.mongodb.net/prabhav`
4. Whitelist your IP address in Network Access
5. Create a database named `prabhav`

### Required Collections

The application will automatically create these collections:

- **users**: User accounts with profiles, locations, permissions
- **complaints**: Citizen complaints
- **officers**: Officer accounts
- **otplogs**: OTP verification logs

### Indexes

Critical indexes for performance:

```javascript
db.users.createIndex({ "aadhar": 1 }, { unique: true })
db.users.createIndex({ "username": 1 }, { unique: true, sparse: true })
db.users.createIndex({ "currentLocation.coordinates": "2dsphere" })
db.users.createIndex({ "createdAt": -1 })
db.users.createIndex({ "lastLogin": -1 })

db.complaints.createIndex({ "aadhar": 1 })
db.complaints.createIndex({ "status": 1 })
db.complaints.createIndex({ "createdAt": -1 })
```

---

## SMS & Authentication

### Twilio Setup (10 minutes)

1. **Create Account**: Visit https://www.twilio.com/console
2. **Get Credentials**:
   - Account SID (find in Console dashboard)
   - Auth Token (find in Console dashboard)
3. **Get Phone Number**:
   - Go to Phone Numbers in Console
   - Click "Get Started"
   - Verify your number and get a Twilio number
   - Example: `+1234567890`
4. **Add to .env**:
   ```env
   TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxx
   TWILIO_AUTH_TOKEN=your_auth_token
   TWILIO_FROM=+1234567890
   ```

### Testing OTP Service

```bash
# Use Postman or curl
curl -X POST http://localhost:4000/api/test/check-otp-service \
  -H "Content-Type: application/json" \
  -d '{
    "aadhar": "123456789012",
    "phone": "9876543210"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "OTP sent to your phone. Valid for 10 minutes.",
  "note": "Check your console or phone for the OTP code"
}
```

---

## Deployment

### Option 1: Heroku Deployment

```bash
# Install Heroku CLI
brew install heroku/brew/heroku

# Login to Heroku
heroku login

# Create app
heroku create prabhav-api

# Add MongoDB addon
heroku addons:create mongolab:sandbox

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your_secret
heroku config:set ENCRYPTION_KEY=your_key
heroku config:set TWILIO_ACCOUNT_SID=your_sid
heroku config:set TWILIO_AUTH_TOKEN=your_token
heroku config:set TWILIO_FROM=+1234567890

# Deploy
git push heroku main
```

### Option 2: Digital Ocean / AWS / Azure

1. Create a Linux server (Ubuntu 20.04+)
2. Install Node.js and MongoDB
3. Clone repository
4. Set up environment variables
5. Start with PM2 (process manager)
6. Configure Nginx as reverse proxy
7. Set up SSL with Let's Encrypt

### Option 3: Docker Deployment

```dockerfile
# Dockerfile in backend/
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 4000
CMD ["node", "server.js"]
```

```bash
docker build -t prabhav-api .
docker run -p 4000:4000 --env-file .env prabhav-api
```

---

## API Endpoints

### Authentication
- `POST /api/auth/send-otp` - Send OTP to phone
- `POST /api/auth/verify-otp` - Verify OTP code
- `POST /api/auth/set-password` - Set password after OTP
- `POST /api/auth/set-username` - Set username
- `POST /api/auth/login` - Login with Aadhar & password

### User Management
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update profile
- `POST /api/user/location` - Update location
- `GET /api/user/location-history` - Get location history
- `GET /api/user/permissions` - Get permissions status
- `POST /api/user/permissions` - Update permissions

### Testing
- `GET /api/test/status` - Health check
- `POST /api/test/check-otp-service` - Test OTP service

---

## Troubleshooting

### Common Issues

#### 1. MongoDB Connection Error
```
Error: connect ECONNREFUSED 127.0.0.1:27017
```
**Solution**: 
- Ensure MongoDB is running
- Check MONGO_URI in .env
- Whitelist IP in MongoDB Atlas

#### 2. Twilio SMS Not Sending
```
Error: SMS Failed to send OTP
```
**Solution**:
- Verify Twilio credentials
- Check phone number format (+91XXXXXXXXXX)
- Ensure account has sufficient credits
- Check Twilio logs

#### 3. JWT Token Invalid
```
Error: Invalid or expired token
```
**Solution**:
- Token may be expired (default 30 days)
- User needs to login again
- Check JWT_SECRET matches between auth and verify

#### 4. CORS Error on Frontend
```
Error: Cross-Origin Request Blocked
```
**Solution**:
- Ensure CORS_ORIGIN in .env includes frontend URL
- Add wildcard: `CORS_ORIGIN=*` for development

#### 5. Port Already in Use
```
Error: listen EADDRINUSE :::4000
```
**Solution**:
```bash
# Find process using port 4000
lsof -i :4000

# Kill process
kill -9 <PID>

# Or change port in .env
PORT=4001
```

---

## Performance Optimization

### Database Indexes
```javascript
// Already created in models
db.users.createIndex({ "aadhar": 1 }, { unique: true })
db.users.createIndex({ "currentLocation.coordinates": "2dsphere" })
```

### API Rate Limiting
- OTP endpoint: 5 requests/minute
- Login endpoint: 10 requests/15 minutes
- Global limit: 100 requests/15 minutes

### Caching Strategy
- User profile: Cache 1 hour
- Location history: Cache 5 minutes
- Permissions: Cache until manual update

---

## Monitoring & Logging

### PM2 Monitoring
```bash
pm2 status
pm2 logs prabhav-api
pm2 monit
```

### Log Rotation
```bash
npm install pm2-logrotate -g
pm2 install pm2-logrotate
```

### Check Backend Health
```bash
curl http://localhost:4000/health

# Response:
# {"success": true, "message": "Backend is running"}
```

---

## Support & Documentation

For more information:
- API Documentation: `/backend/README.md`
- Flutter Setup: `/README.md`
- Database Schema: Database collections with Mongoose models
- Issues: Create GitHub issues with detailed information

---

**Last Updated**: November 18, 2025
**Version**: 1.0.0
