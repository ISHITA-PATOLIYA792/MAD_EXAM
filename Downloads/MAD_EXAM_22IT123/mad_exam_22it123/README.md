# Loyalty Card Storage App

A Flutter application that enables users to store and manage their loyalty cards digitally, with offline access and cloud synchronization.

## Features

- **Card Management**
  - Add loyalty cards with card name, number, and barcode
  - Support for scanning barcodes
  - Add card images from camera or gallery
  - Display stored card details and expiration dates

- **Offline Storage & Access**
  - All cards are stored locally using Hive for persistence
  - Access and display cards without internet connection
  - Present barcodes/QR codes at checkout even when offline

- **Cloud Synchronization**
  - Sync data with cloud when online
  - Automatic reconciliation of offline changes
  - Status indicators for synced/unsynced cards

- **Security**
  - AES encryption for sensitive card data (card number, barcode)
  - Secure storage of all loyalty information

- **Notifications**
  - Alert when cards are nearing expiration
  - Push notifications for promotions (simulated)

## Project Structure

```
/lib
├── main.dart                  # App entry point
├── models/
│   └── loyalty_card.dart      # Card data model
├── screens/
│   ├── home_screen.dart       # List of loyalty cards
│   ├── add_card_screen.dart   # Form to add a new card
│   ├── card_detail_screen.dart # Card details and barcode view
│   └── settings_screen.dart   # App settings
├── services/
│   ├── notification_service.dart # Handle notifications
│   ├── sync_service.dart      # Cloud synchronization
│   └── encryption_service.dart # Data encryption/decryption
├── providers/
│   └── card_provider.dart     # State management for cards
└── utils/
    └── validators.dart        # Form validation utilities
```

## Technical Details

- **State Management**: Provider pattern
- **Local Database**: Hive for high-performance local storage
- **Encryption**: AES encryption via the encrypt package
- **Notifications**: Firebase Cloud Messaging (FCM) and flutter_local_notifications
- **Network**: Connectivity monitoring with connectivity_plus
- **UI Components**: Material Design implementation

## Getting Started

### Prerequisites

- Flutter SDK (2.0.0 or later)
- Android Studio / VS Code with Flutter extensions
- An emulator or physical device for testing

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Future Scope

- Add support for multiple categories of loyalty cards
- Implement card sharing functionality
- Add location-based reminders when near a store
- Support for digital wallet integration
- Analytics to track rewards and points accumulated

## Screenshots

(Screenshots will be added here)

## Author

- 22IT123 - Mobile Application Development Exam

## License

This project is licensed under the MIT License - see the LICENSE file for details.
