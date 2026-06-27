# PodWave

A modern, offline-first music player built with Flutter. Designed for simplicity and performance, PodWave lets you enjoy your local music collection with a beautiful, responsive interface.

## Features

- **Offline Music Playback**: Play your local music files without an internet connection
- **Multi-Format Support**: MP3, AAC/M4A, WAV, OGG
- **Media Notifications**: Control playback from notification center(its not working on release mode now)
- **Queue Management**: Create and manage playback queues
- **Library Organization**: Browse and organize your music library
- **Folder Navigation**: Navigate through device folders to find music
- **Bilingual Support**: Arabic and English localization
- **Responsive Design**: Optimized for various screen sizes
- **Playback Position Memory**: Resume from where you left off

## Tech Stack

### Core Dependencies
- **Flutter**: ^3.12.0 (Dart SDK)
- **State Management**: flutter_riverpod ^2.6.1
- **Routing**: go_router ^14.8.1
- **Local Storage**: hive ^2.2.3 + hive_flutter ^1.1.0
- **Audio Playback**: just_audio ^0.9.42
- **Responsive Design**: flutter_screenutil ^5.9.3
- **Localization**: flutter_localizations + intl ^0.20.2
- **Permissions**: permission_handler ^11.3.1
- **Notifications**: flutter_local_notifications ^22.0.1
- **Metadata**: id3 ^1.0.2 (for reading audio file metadata)
- **Navigation**: persistent_bottom_nav_bar_v2 ^6.3.2
- **Typography**: google_fonts ^6.2.1 (Inter)

## Architecture

PodWave follows a **feature-first Clean Architecture** pattern without a domain layer. Each feature owns its own presentation and data layers.

### Project Structure

```
lib/
├── core/                          # Shared utilities and configurations
│   ├── audio/                     # Audio player & notification services
│   │   ├── audio_player_service.dart
│   │   └── media_notification_service.dart
│   ├── constants/                 # Design tokens (spacing, radius, durations)
│   ├── localization/              # Locale management
│   ├── responsive/                # Screen configuration (360x800 design size)
│   ├── routing/                   # App router configuration
│   ├── storage/                   # Hive initialization & management
│   ├── theme/                     # AppColors, AppTheme (dark+light), AppTextStyles
│   ├── utils/                     # Utility functions
│   └── widgets/                   # Reusable UI components
├── features/                      # Feature modules
│   ├── splash/                    # Splash screen
│   ├── home/                      # Home screen with music discovery
│   ├── library/                   # Music library management
│   ├── now_playing/               # Now playing screen with controls
│   ├── queue/                     # Playback queue management
│   ├── settings/                  # App settings
│   ├── folder_details/            # Folder browsing
│   └── navigation/                # Bottom navigation bar
├── l10n/                          # Localization files
│   ├── app_ar.arb                # Arabic translations
│   └── app_en.arb                # English translations
└── main.dart                      # App entry point
```

### Data Storage

Hive is used for local data persistence with the following boxes:
- `settings` - User preferences and app settings
- `playback_positions` - Remember playback position for each track
- `library` - Music library data
- `playlists` - User-created playlists
- `queue` - Current playback queue

### Routing

Routes are managed using go_router:
- `/` - Splash screen
- `/home` - Home screen
- `/library` - Music library
- `/settings` - Settings
- `/now-playing` - Now playing screen
- `/queue` - Queue management

### State Management

All state is managed using Riverpod providers. The app uses `ProviderScope` at the root level for dependency injection.

### Bootstrap Flow

```
main()
  ↓
WidgetsFlutterBinding.ensureInitialized()
  ↓
HiveInitializer.initialize()
  ↓
AudioPlayerService.initialize()
  ↓
ProviderScope
  ↓
PodWaveApp
  ↓
ScreenUtilInit (responsive configuration)
  ↓
MaterialApp.router
```

### Design Principles

- **StatelessWidget Only**: All screens are StatelessWidget for better performance
- **Clean Architecture**: Separation of concerns with presentation and data layers
- **Responsive Design**: All dimensions use centralized constants from `constants.dart`
- **Localization**: All UI strings use .arb files (no hardcoded strings)
- **Modular Code**: Files limited to 1000 lines with widget extraction for large screens
- **Dark-First Theme**: Default dark mode with light mode option

## Getting Started

### Prerequisites

- Flutter SDK ^3.12.0
- Dart SDK ^3.12.0
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd nova_player
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive type adapters (if needed):
```bash
flutter pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Permissions: `READ_EXTERNAL_STORAGE`, `READ_MEDIA_AUDIO`

#### iOS
- Minimum iOS: 12.0
- Permissions: Add usage descriptions in `Info.plist` for media library access

## Building

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

## Contributing

Contributions are welcome! Please follow these guidelines:
- Follow the existing Clean Architecture pattern
- Use Riverpod for state management
- Keep files under 1000 lines
- Extract widgets for complex UI
- Add localization for all new strings
- Follow the existing code style

## License

This project is licensed under the MIT License.

## Acknowledgments

- Flutter team for the amazing framework
- Riverpod community for the state management solution
- All open-source contributors whose packages make this project possible