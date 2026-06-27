# Changelog

All notable changes to PodWave will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-27

### Added
- **Playlists Feature**: Complete playlist management system
  - Create, rename, and delete custom playlists
  - Add songs from library to playlists
  - Two default playlists: "Recently Added" and "Most Played" (dynamically sourced)
  - Hive-based persistence for playlists
  - Playlist detail screen showing songs in each playlist
  - Add songs screen with search functionality
- **Navigation**: Updated bottom navigation to icon-only design with active state highlighting
- **NovaAppBar**: Added app logo (circular) on left and feature title on right
- **Localization**: Added Arabic and English strings for all playlist-related features

### Changed
- **Home Screen**: Replaced with Playlists screen as the primary tab
- **Default Tab**: Library is now the default screen on app launch
- **PlaylistsScreen**: Converted to stateless ConsumerWidget
- **PlaylistDetailScreen**: Now opens as a sub-screen (like Now Playing) via router
- **Library Filters**: Songs tab is now the default/primary view
- **LibraryRepository**: Converted to singleton pattern to prevent Hive box conflicts

### Fixed
- **Hive Adapter**: Fixed SongModel duration field missing in generated adapter
- **Async Suspension**: Fixed platform channel suspension error when navigating from PlaylistsScreen
- **Play Stats**: Fixed play stats not updating when songs are played (centralized Hive box management)
- **Filter Logic**: Fixed library filters to properly return all matching songs
- **Empty States**: Recently Played and Most Played now show empty state when no data exists

### Technical
- **Hive Type IDs**: PlaylistModel uses typeId: 3
- **Router**: Added playlistDetail route as parentNavigatorKey route (sub-screen)
- **Version**: Updated to 1.1.0+2

## [0.1.0] - Initial Release

### Added
- Initial music player functionality
- Library screen with song browsing
- Now Playing screen
- Audio playback controls
- Settings screen
- Localization support (English/Arabic)
- Theme support (Light/Dark)
