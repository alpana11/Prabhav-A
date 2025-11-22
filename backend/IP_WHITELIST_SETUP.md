# 🌐 MongoDB Atlas Setup with Your IP

## Your IP Address
```
152.56.0.15/32
```

## Steps to Connect MongoDB Atlas

### 1. Add IP to MongoDB Atlas Whitelist

1. Go to **https://www.mongodb.com/cloud/atlas**
2. Log in to your account
3. Go to your **Cluster** → **Network Access**
4. Click **"Add IP Address"**
5. Enter: `152.56.0.15/32`
6. Click **"Add IP Address"**
7. Wait for status to be **"Active"** ✅

### 2. Get Your Connection String

1. Go to your **Cluster** → **Connect**
2. Choose **"Drivers"** → **"Node.js"**
3. Copy the connection string (example):
   ```
   mongodb+srv://username:password@cluster-name.mongodb.net/prabhav?retryWrites=true&w=majority
   ```

### 3. Update .env File

Open: `c:\Users\Lenovo\Documents\shreya\Prabhav\backend\.env`

Replace the `MONGO_URI` line with your actual connection string:
```
MONGO_URI=mongodb+srv://your_username:your_password@your-cluster.mongodb.net/prabhav?retryWrites=true&w=majority
```

**Example:**
```
MONGO_URI=mongodb+srv://shreya:MyPassword123@prabhav-db.mongodb.net/prabhav?retryWrites=true&w=majority
```

### 4. Restart Backend Server

```powershell
cd 'c:\Users\Lenovo\Documents\shreya\Prabhav\backend'
npm start
```

### 5. Verify Connection

Check server output for:
```
✅ MongoDB connected successfully
```

---

## ⚠️ Important Security Notes

1. **Never commit `.env` file** (it contains passwords)
2. **Change default passwords** in MongoDB Atlas
3. **Use strong passwords** (mix of letters, numbers, special chars)
4. **IP Whitelist**: Only your IP (152.56.0.15/32) can connect
5. **Connection String**: Keep it secret

---

## 🔧 Troubleshooting

**Error: "IP address is not whitelisted"**
- Make sure your IP (152.56.0.15/32) is in Network Access
- Wait for status to turn "Active" ✅
- Restart your backend

**Error: "Authentication failed"**
- Check username and password in connection string
- Make sure special characters are URL encoded
  - Example: `@` becomes `%40`, `:` becomes `%3A`

**Connection timeout**
- Verify IP is whitelisted
- Check MONGO_URI syntax
- Ensure cluster is "Active" in Atlas

---

## 📝 .env Configuration Reference

```
PORT=4000
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/prabhav?retryWrites=true&w=majority
JWT_SECRET=your_secret_key_change_this
JWT_EXPIRES_IN=7d
ADMIN_USER=admin
ADMIN_PASS=admin123
NODE_ENV=development
```

---

## ✅ Ready to Go!

Once MongoDB is connected:
1. Your backend will store data persistently
2. Complaints, users, officers data will be saved
3. You can test with your Flutter frontend
4. Ready for production deployment

---

**Need help? Let me know your MongoDB Atlas username/cluster name, and I can help configure it!**
