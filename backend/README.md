# PRABHAV Backend

Node.js + Express + MongoDB backend for PRABHAV - Transparent Governance Platform.

## Setup

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit .env with your settings:**
   - `MONGO_URI`: MongoDB connection string (local or cloud)
   - `JWT_SECRET`: Change to a strong secret
   - `ADMIN_USER` and `ADMIN_PASS`: Admin credentials

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Ensure MongoDB is running:**
   - Local: `mongod` running on port 27017
   - Or update `MONGO_URI` to your MongoDB URL

## Run

**Development (with auto-reload):**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

Server starts on http://localhost:4000 (or set PORT in .env)

## Key APIs

Base URL: `/api`

### Authentication
- `POST /api/auth/send-otp` — Send OTP (mocked, printed to console)
- `POST /api/auth/verify-otp` — Verify OTP and login
- `POST /api/auth/officer-login` — Officer login
- `POST /api/auth/admin-login` — Admin login

### User (Citizen)
- `GET /api/users/me` — Get profile
- `PUT /api/users/me` — Update profile
- `GET /api/users/me/complaints` — List my complaints
- `GET /api/users/track/:id` — Track complaint by ID

### Complaints
- `POST /api/complaints` — Create complaint (multipart/form-data with images)
- `GET /api/complaints/:id` — Get complaint by ID
- `GET /api/complaints/department/:department` — Get complaints by department
- `POST /api/complaints/:id/images` — Upload images to complaint

### Officer
- `GET /api/officers/department/complaints` — Get department complaints
- `POST /api/officers/complaint/:complaintId/update` — Update complaint status
- `GET /api/officers/dashboard` — Department dashboard stats

### Admin
- `POST /api/admin/create-officer` — Create new officer
- `GET /api/admin/analytics` — System-wide analytics
- `GET /api/admin/blockchain` — View blockchain logs

### Blockchain
- `GET /api/blockchain/trail` — Get full audit trail

## Features

✅ Aadhar + OTP login (mocked to console)
✅ JWT authentication
✅ Role-based access (user, officer, admin)
✅ Complaint management
✅ Image upload (Multer)
✅ Officer department workflow
✅ Blockchain audit trail
✅ Analytics dashboard
✅ Rate limiting on OTP
✅ CORS enabled
✅ Winston logging

## Project Structure

```
backend/
├── config/
│   └── db.js                 # MongoDB connection
├── models/
│   ├── User.js               # Citizen schema
│   ├── Officer.js            # Officer schema
│   ├── Complaint.js          # Complaint with remarks
│   └── Block.js              # Blockchain block
├── controllers/              # Business logic
├── routes/                   # API routes
├── middleware/               # Auth, roles, error handling
├── services/                 # OTP, blockchain logic
├── uploads/                  # User-uploaded images
├── server.js                 # Entry point
├── package.json
├── .env.example
└── README.md
```

## Notes

- **OTP**: Printed to server console for testing. Implement real SMS later.
- **Images**: Saved to `uploads/` folder and served at `/uploads/<filename>`
- **Admin**: Uses hardcoded credentials from `.env` (upgrade to DB later)
- **MongoDB**: Local or cloud Atlas
- **Frontend**: APIs are frontend-agnostic; no changes needed to your Flutter app

## Troubleshooting

**Port already in use:**
- Change `PORT` in `.env`

**MongoDB connection error:**
- Ensure MongoDB is running
- Check `MONGO_URI` is correct

**OTP not appearing:**
- Check server console output (not request logs)

**Images not saving:**
- Ensure `uploads/` folder exists (auto-created on first request)

## Future Enhancements

- Replace OTP mock with Twilio SMS
- Add email notifications
- Add push notifications
- Implement real admin user DB
- Add pagination to complaint lists
- Add search/filter endpoints
- Implement refresh token strategy
- Add request logging to file
