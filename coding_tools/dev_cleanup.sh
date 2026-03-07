#!/bin/zsh

echo "Cleaning Xcode build cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "Removing old simulators..."
xcrun simctl delete unavailable

echo "Cleaning DeviceSupport..."
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*

echo "Cleaning macOS caches..."
rm -rf ~/Library/Caches/*

echo "Cleaning Flutter cache..."
flutter pub cache clean

echo "Done."xcrun simctl list runtimes