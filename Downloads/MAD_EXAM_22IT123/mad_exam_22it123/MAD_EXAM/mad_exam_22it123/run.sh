#!/bin/bash

# Change to project directory
cd "$(dirname "$0")"

# Install dependencies
flutter pub get

# Generate necessary files
# flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

echo "App started successfully!" 