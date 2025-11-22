# MongoDB Atlas Setup Guide

## Steps to Get Your Connection String:

1. Go to https://www.mongodb.com/cloud/atlas
2. Log in to your account
3. Go to your cluster → Click "Connect"
4. Choose "Drivers" → "Node.js"
5. Copy the connection string (looks like):
   ```
   mongodb+srv://username:password@cluster-name.mongodb.net/prabhav?retryWrites=true&w=majority
   ```

## Update .env:

Replace the MONGO_URI line in `.env` with your actual connection string:
```
MONGO_URI=mongodb+srv://your_username:your_password@your_cluster.mongodb.net/prabhav?retryWrites=true&w=majority
```

**Important**: 
- Replace `your_username` with your MongoDB Atlas username
- Replace `your_password` with your MongoDB Atlas password  
- Replace `your_cluster` with your actual cluster name

## Example:
```
MONGO_URI=mongodb+srv://shreya:xyz123abc@prabhav-cluster.mongodb.net/prabhav?retryWrites=true&w=majority
```

Then save and restart the server with `npm start`
