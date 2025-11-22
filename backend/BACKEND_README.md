# PRABHAV Backend - Complete API Server

## Overview
Production-ready Node.js + Express + MongoDB backend for the PRABHAV citizen complaint management system with Aadhar-based OTP authentication.

## Features
✅ Aadhar + OTP-based authentication with Twilio SMS  
✅ Secure JWT token management  
✅ User location tracking with geospatial queries  
✅ Permission management system  
✅ Complaint filing and tracking  
✅ Officer assignment and response system  
✅ Rate limiting and security middleware  
✅ Comprehensive error handling  
✅ MongoDB with proper indexing  
✅ Production-ready deployment  

## Tech Stack
- **Runtime**: Node.js 16+
- **Framework**: Express.js
- **Database**: MongoDB
- **Authentication**: JWT + Twilio SMS OTP
- **Security**: bcryptjs, helmet, express-rate-limit
- **Logging**: Morgan + Winston
- **Validation**: Joi

## Quick Start

### Prerequisites
```bash
Node.js v16+ 
npm or yarn
MongoDB (Atlas or local)
Twilio Account
```

### Installation

```bash
# 1. Install dependencies
npm install

# 2. Create .env file
cp .env.sample .env

# 3. Configure environment variables (see below)

# 4. Start server
npm start
```

## Environment Variables

```env
# Server
NODE_ENV=development
PORT=4000
HOST=0.0.0.0
DISPLAY_IP=10.13.191.92


# Database
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/prabhav

# JWT
JWT_SECRET=your_super_secret_key_min_32_chars
JWT_EXPIRES_IN=30d

# Encryption
ENCRYPTION_KEY=your_32_char_key_for_aadhar

# Twilio SMS
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_token
TWILIO_FROM=+1234567890

# OTP
OTP_EXPIRY_MINUTES=10
DEBUG_OTP=false
```

## API Endpoints

### Authentication (Public)

#### Send OTP
```http
POST /api/auth/send-otp
Content-Type: application/json

{
  "aadhar": "123456789012",
  "phone": "9876543210"
}

Response:
{
  "success": true,
  "message": "OTP sent to your phone. Valid for 10 minutes."
}
```

#### Verify OTP
```http
POST /api/auth/verify-otp
Content-Type: application/json

{
  "aadhar": "123456789012",
  "otp": "123456"
}

Response:
{
  "success": true,
  "message": "OTP verified successfully",
  "tempToken": "eyJhbGc..."
}
```

#### Set Password
```http
POST /api/auth/set-password
Authorization: Bearer <temp_token>
Content-Type: application/json

{
  "aadhar": "123456789012",
  "password": "SecurePass@123",
  "confirmPassword": "SecurePass@123"
}

Response:
{
  "success": true,
  "message": "Password set successfully",
  "userId": "507f1f77bcf86cd799439011"
}
```

#### Set Username
```http
POST /api/auth/set-username
Content-Type: application/json

{
  "aadhar": "123456789012",
  "username": "john_doe"
}

Response:
{
  "success": true,
  "message": "Username set successfully"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "aadhar": "123456789012",
  "password": "SecurePass@123"
}

Response:
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGc...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "aadhar": "123456789012",
    "username": "john_doe"
  }
}
```

### User Management (Protected - Requires Auth Token)

#### Get Profile
```http
GET /api/user/profile
Authorization: Bearer <auth_token>

Response:
{
  "success": true,
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "aadhar": "123456789012",
    "username": "john_doe",
    "email": "john@example.com",
    "phone": "9876543210",
    "currentLocation": {
      "type": "Point",
      "coordinates": [72.8777, 19.0760],
      "address": "Mumbai, India",
      "updatedAt": "2025-11-18T10:30:00Z"
    }
  }
}
```

#### Update Location
```http
POST /api/user/location
Authorization: Bearer <auth_token>
Content-Type: application/json

{
  "latitude": 19.0760,
  "longitude": 72.8777,
  "address": "Mumbai, India",
  "accuracy": 10
}

Response:
{
  "success": true,
  "message": "Location updated successfully"
}
```

#### Get Location History
```http
GET /api/user/location-history
Authorization: Bearer <auth_token>

Response:
{
  "success": true,
  "totalLocations": 25,
  "currentLocation": {...},
  "history": [...]
}
```

#### Get Permissions
```http
GET /api/user/permissions
Authorization: Bearer <auth_token>

Response:
{
  "success": true,
  "permissions": {
    "location": "granted",
    "camera": "granted",
    "gallery": "granted",
    "microphone": "pending",
    "files": "denied"
  }
}
```

#### Update Permissions
```http
POST /api/user/permissions
Authorization: Bearer <auth_token>
Content-Type: application/json

{
  "location": "granted",
  "camera": "granted",
  "gallery": "granted",
  "microphone": "denied",
  "files": "pending"
}

Response:
{
  "success": true,
  "message": "Permissions updated successfully",
  "permissions": {...}
}
```

### Testing Endpoints (Development)

#### Health Check
```http
GET /api/test/status

Response:
{
  "success": true,
  "message": "API is running",
  "timestamp": "2025-11-18T10:30:00Z",
  "environment": "development"
}
```

#### Test OTP Service
```http
POST /api/test/check-otp-service
Content-Type: application/json

{
  "aadhar": "123456789012",
  "phone": "9876543210"
}
```

## Database Schema

### Users Collection
```javascript
{
  _id: ObjectId,
  aadhar: String (unique, encrypted),
  password: String (hashed),
  username: String (unique),
  email: String,
  phone: String,
  fullName: String,
  
  // Location
  currentLocation: {
    type: "Point",
    coordinates: [longitude, latitude],
    address: String,
    accuracy: Number,
    updatedAt: Date
  },
  locationHistory: Array,
  
  // Permissions
  permissions: {
    location: "granted|denied|pending",
    camera: "granted|denied|pending",
    gallery: "granted|denied|pending",
    microphone: "granted|denied|pending",
    files: "granted|denied|pending"
  },
  
  // Metadata
  createdAt: Date,
  updatedAt: Date,
  lastLogin: Date
}
```

## Security Features

1. **Password Hashing**: bcryptjs with salt rounds 10
2. **Aadhar Encryption**: AES-256-CBC encryption for sensitive data
3. **Rate Limiting**:
   - OTP: 5 requests/minute
   - Login: 10 requests/15 minutes
   - Global: 100 requests/15 minutes
4. **JWT Tokens**: 30-day expiry with secure storage
5. **CORS**: Configurable origin
6. **Helmet**: Security headers
7. **Input Validation**: Joi schema validation

## Error Handling

All endpoints return consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "error": "detailed_error_info"
}
```

## Deployment

### Using PM2 (Production)
```bash
npm install -g pm2
pm2 start server.js --name "prabhav-api"
pm2 save
pm2 startup
pm2 logs prabhav-api
```

### Using Docker
```bash
docker build -t prabhav-api .
docker run -p 4000:4000 --env-file .env prabhav-api
```

### Using Heroku
```bash
heroku create prabhav-api
heroku config:set NODE_ENV=production
git push heroku main
heroku logs --tail
```

## Testing

### Using Postman
- Import `POSTMAN_COLLECTION.json`
- Set base_url variable to your backend URL
- Test endpoints in sequence (auth flow)

### Using cURL
```bash
# Send OTP
curl -X POST http://localhost:4000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"aadhar":"123456789012","phone":"9876543210"}'

# Verify OTP
curl -X POST http://localhost:4000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"aadhar":"123456789012","otp":"123456"}'
```

## Troubleshooting

### OTP Not Sending
- Check Twilio credentials in .env
- Verify phone number format (+91XXXXXXXXXX)
- Check Twilio account balance
- Review Twilio logs

### Database Connection Failed
- Verify MONGO_URI
- Check IP whitelist in MongoDB Atlas
- Ensure network connectivity
- Test connection string separately

### Port Already in Use
```bash
lsof -i :4000
kill -9 <PID>
```

### JWT Token Invalid
- Token may be expired
- JWT_SECRET may have changed
- Token format may be incorrect

## Performance Optimization

1. **Database Indexes**: Created on frequently queried fields
2. **Geospatial Indexing**: 2dsphere index for location queries
3. **Query Optimization**: Lean queries for list endpoints
4. **Caching**: User profile caching recommendations
5. **Pagination**: Implement for large result sets

## Monitoring

```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs prabhav-api

# Monitor resources
pm2 monit
```

## Support

For issues, feature requests, or questions:
1. Check existing GitHub issues
2. Review deployment guide
3. Check logs for error details
4. Create detailed issue with:
   - Error message
   - Steps to reproduce
   - Environment details
   - API request/response

## License
Private - PRABHAV Project

## Version
1.0.0 - November 2025

---

**Ready for production!** Configure your .env file and deploy with confidence.
