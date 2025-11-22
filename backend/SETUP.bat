@echo off
REM Setup script for PRABHAV Backend with MongoDB Atlas

echo.
echo =====================================
echo   PRABHAV Backend Setup Guide
echo =====================================
echo.
echo Your IP Address: 152.56.0.15/32
echo.
echo STEPS:
echo =====================================
echo.
echo 1. Go to MongoDB Atlas: https://www.mongodb.com/cloud/atlas
echo.
echo 2. Add IP Whitelist:
echo    - Cluster ^> Network Access
echo    - Add IP Address: 152.56.0.15/32
echo    - Wait for "Active" status
echo.
echo 3. Get Connection String:
echo    - Cluster ^> Connect ^> Drivers ^> Node.js
echo    - Copy the connection string
echo.
echo 4. Update .env file:
echo    - Open: backend\.env
echo    - Paste connection string in MONGO_URI
echo    - Save file
echo.
echo 5. Restart Backend:
echo    - Run: npm start
echo.
echo =====================================
echo.
pause
