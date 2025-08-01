@echo off
echo Fixing pubspec.lock issue...
echo.

echo Step 1: Removing existing pubspec.lock if it exists...
if exist pubspec.lock del pubspec.lock

echo Step 2: Running flutter clean...
flutter clean

echo Step 3: Running flutter pub get...
flutter pub get

echo.
echo Done! Check if pubspec.lock was created successfully.
pause 