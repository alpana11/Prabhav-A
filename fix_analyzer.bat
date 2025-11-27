@echo off
REM This script fixes Dart/Flutter analyzer issues on Windows

echo =========================================
echo Fixing Dart/Flutter Analyzer Issues
echo =========================================

echo.
echo 1. Cleaning Dart pub cache...
dart pub cache clean

echo.
echo 2. Cleaning Flutter build artifacts...
flutter clean

echo.
echo 3. Setting FLUTTER_ROOT environment variable...
setx FLUTTER_ROOT C:\flutter

echo.
echo 4. Reinstalling dependencies...
flutter pub get

echo.
echo 5. Running analyzer...
flutter analyze

echo.
echo =========================================
echo Fix complete! Please restart VS Code for changes to take effect.
echo =========================================
pause
