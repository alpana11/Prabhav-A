# 🚀 PRABHAV Backend - API Testing Guide

## ✅ Server Status
```
✅ Server running on port 4000
📝 Backend ready at http://localhost:4000
🔗 Base API URL: http://localhost:4000/api
```

---

## 🧪 Test Credentials

### 👤 User (Citizen) - Aadhar Login
Use any of these Aadhar numbers with OTP verification:
- **12345678901234** - Raj Kumar
- **98765432109876** - Priya Singh
- **11111111111111** - Amit Patel

(OTP: Will be printed to server console)

### 👮 Officer Login
```
Officer ID: OFF001 | Password: officer123 | Department: Road
Officer ID: OFF002 | Password: officer123 | Department: Water
Officer ID: OFF003 | Password: officer123 | Department: Electricity
Officer ID: OFF004 | Password: officer123 | Department: Sanitation
```

### 🔐 Admin Login
```
Username: admin
Password: admin123
```

---

## 📋 API Endpoints

### 1️⃣ AUTHENTICATION

#### Send OTP
```bash
POST http://localhost:4000/api/auth/send-otp
Content-Type: application/json

{
  "aadhar": "12345678901234"
}
```
**Response:** OTP printed to server console

#### Verify OTP & Login
```bash
POST http://localhost:4000/api/auth/verify-otp
Content-Type: application/json

{
  "aadhar": "12345678901234",
  "otp": "123456"
}
```
**Response:** JWT Token

#### Officer Login
```bash
POST http://localhost:4000/api/auth/officer-login
Content-Type: application/json

{
  "officerId": "OFF001",
  "password": "officer123"
}
```

#### Admin Login
```bash
POST http://localhost:4000/api/auth/admin-login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

---

### 2️⃣ USER (CITIZEN) ENDPOINTS

#### Get Profile
```bash
GET http://localhost:4000/api/users/me
Authorization: Bearer <JWT_TOKEN>
```

#### Update Profile
```bash
PUT http://localhost:4000/api/users/me
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "name": "Raj Kumar",
  "phone": "9876543210",
  "address": "Mumbai, Maharashtra",
  "email": "raj@example.com"
}
```

#### Get My Complaints
```bash
GET http://localhost:4000/api/users/me/complaints
Authorization: Bearer <JWT_TOKEN>
```

#### Track Complaint
```bash
GET http://localhost:4000/api/users/track/C-001
Authorization: Bearer <JWT_TOKEN>
```

---

### 3️⃣ COMPLAINT ENDPOINTS

#### Create Complaint
```bash
POST http://localhost:4000/api/complaints
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data

Fields:
- department: "road" | "water" | "electricity" | "sanitation"
- title: "Large pothole"
- description: "Dangerous pothole on main street"
- location: {"lat": 19.0760, "lng": 72.8777}
- images: <file> (optional, up to 5 files)
```

#### Get Complaint by ID
```bash
GET http://localhost:4000/api/complaints/C-001
```

#### Get Complaints by Department
```bash
GET http://localhost:4000/api/complaints/department/road
```

#### Upload Images to Complaint
```bash
POST http://localhost:4000/api/complaints/C-001/images
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data

Fields:
- images: <file> (up to 5 files)
```

---

### 4️⃣ OFFICER ENDPOINTS

#### Get Department Complaints
```bash
GET http://localhost:4000/api/officers/department/complaints
Authorization: Bearer <OFFICER_TOKEN>
```

#### Update Complaint Status
```bash
POST http://localhost:4000/api/officers/complaint/C-001/update
Authorization: Bearer <OFFICER_TOKEN>
Content-Type: multipart/form-data

Fields:
- status: "Pending" | "In Progress" | "Resolved"
- remark: "Working on it"
- images: <file> (optional proof images, up to 5 files)
```

#### Department Dashboard
```bash
GET http://localhost:4000/api/officers/dashboard
Authorization: Bearer <OFFICER_TOKEN>
```

---

### 5️⃣ ADMIN ENDPOINTS

#### Create Officer
```bash
POST http://localhost:4000/api/admin/create-officer
Authorization: Bearer <ADMIN_TOKEN>
Content-Type: application/json

{
  "officerId": "OFF005",
  "password": "officer123",
  "name": "New Officer",
  "department": "road"
}
```

#### Get Analytics
```bash
GET http://localhost:4000/api/admin/analytics
Authorization: Bearer <ADMIN_TOKEN>
```

#### Get Blockchain Logs
```bash
GET http://localhost:4000/api/admin/blockchain
Authorization: Bearer <ADMIN_TOKEN>
```

---

### 6️⃣ BLOCKCHAIN AUDIT TRAIL

#### Get Full Audit Trail
```bash
GET http://localhost:4000/api/blockchain/trail
Authorization: Bearer <JWT_TOKEN>
```

---

## 🧪 Quick Test Steps

### Step 1: Send OTP
```bash
curl -X POST http://localhost:4000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"aadhar":"12345678901234"}'
```
👉 **Check server console for OTP**

### Step 2: Verify OTP (get token)
```bash
curl -X POST http://localhost:4000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"aadhar":"12345678901234","otp":"<OTP_FROM_CONSOLE>"}'
```

### Step 3: Use token in requests
```bash
curl -X GET http://localhost:4000/api/users/me \
  -H "Authorization: Bearer <TOKEN_FROM_STEP_2>"
```

---

## 📁 Project Structure
```
backend/
├── config/db.js              # MongoDB connection
├── models/                   # User, Officer, Complaint, Block
├── controllers/              # Business logic
├── routes/                   # API routes
├── middleware/               # Auth, roles, error handling
├── services/                 # OTP, blockchain
├── uploads/                  # User-uploaded images
├── server.js                 # Entry point
├── seed.js                   # Database seeder
├── package.json
├── .env                      # Configuration
└── README.md
```

---

## 🔧 Features Included

✅ Aadhar + OTP login (mocked to console)
✅ JWT authentication with role-based access
✅ Citizen complaint management
✅ Officer department workflow
✅ Admin analytics and monitoring
✅ Blockchain audit trail for all actions
✅ Image upload with Multer
✅ MongoDB integration (offline mode available)
✅ Rate limiting on OTP endpoint
✅ CORS enabled
✅ Winston logging
✅ Joi input validation
✅ Error handling middleware

---

## 🐛 Troubleshooting

**Port 4000 already in use?**
- Change PORT in .env file

**Images not uploading?**
- Ensure `uploads/` folder exists (auto-created)

**OTP not showing?**
- Check server console output (not request logs)

**Database issues?**
- Use MongoDB Atlas connection string in MONGO_URI
- Or install MongoDB locally

---

## 📞 API Base URLs

**Local:** `http://localhost:4000/api`
**Production:** Update based on your deployment

---

## 🎯 Next Steps

1. ✅ Backend running
2. Connect your Flutter frontend to `http://localhost:4000/api`
3. Test each endpoint with provided credentials
4. Set up real MongoDB Atlas connection
5. Deploy to production server

---

**Your PRABHAV Backend is Ready! 🚀**
