import 'package:flutter/material.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/features/folder_details/data/models/folder_model.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

class FolderDetailsService {
  static final FolderDetailsService _instance = FolderDetailsService._internal();
  factory FolderDetailsService() => _instance;
  FolderDetailsService._internal();

  FolderModel? getFolderById(String folderId) {
    final allFolders = _getMockFolders();
    try {
      return allFolders.firstWhere((f) => f.id == folderId);
    } catch (_) {
      return null;
    }
  }

  List<SongModel> getSongsForFolder(String folderId) {
    final folder = getFolderById(folderId);
    return folder?.songs ?? [];
  }

  List<FolderModel> _getMockFolders() {
    return [
      FolderModel(
        id: '1',
        name: 'Midnight Echoes',
        artist: 'The Synthetics',
        accentColor: const Color(0xFF8B0000),
        lastPlayed: DateTime.now().subtract(const Duration(hours: 2)),
        playCount: 45,
        songs: [
          SongModel(
            id: '1-1',
            title: 'Resonance',
            artist: 'The Synthetics',
            album: 'Midnight Echoes',
            filePath: '/music/midnight_echoes/resonance.mp3',
            duration: const Duration(minutes: 3, seconds: 45),
            accentColor: const Color(0xFF8B0000),
            lastPlayed: DateTime.now().subtract(const Duration(minutes: 5)),
            playCount: 156,
          ),
          SongModel(
            id: '1-2',
            title: 'Echo Chamber',
            artist: 'The Synthetics',
            album: 'Midnight Echoes',
            filePath: '/music/midnight_echoes/echo_chamber.mp3',
            duration: const Duration(minutes: 4, seconds: 12),
            accentColor: const Color(0xFF8B0000),
            playCount: 89,
          ),
          SongModel(
            id: '1-3',
            title: 'Nightfall',
            artist: 'The Synthetics',
            album: 'Midnight Echoes',
            filePath: '/music/midnight_echoes/nightfall.mp3',
            duration: const Duration(minutes: 3, seconds: 28),
            accentColor: const Color(0xFF8B0000),
            lastPlayed: DateTime.now().subtract(const Duration(days: 1)),
            playCount: 45,
          ),
          SongModel(
            id: '1-4',
            title: 'Dark Matter',
            artist: 'The Synthetics',
            album: 'Midnight Echoes',
            filePath: '/music/midnight_echoes/dark_matter.mp3',
            duration: const Duration(minutes: 5, seconds: 0),
            accentColor: const Color(0xFF8B0000),
            playCount: 234,
          ),
        ],
      ),
      FolderModel(
        id: '2',
        name: 'Fluidity Vol. 1',
        artist: 'Various Artists',
        accentColor: const Color(0xFF00CED1),
        lastPlayed: DateTime.now().subtract(const Duration(days: 1)),
        playCount: 23,
        songs: [
          SongModel(
            id: '2-1',
            title: 'Liquid Flow',
            artist: 'Deep Blue',
            album: 'Fluidity Vol. 1',
            filePath: '/music/fluidity/liquid_flow.mp3',
            duration: const Duration(minutes: 3, seconds: 55),
            accentColor: const Color(0xFF00CED1),
            playCount: 78,
          ),
          SongModel(
            id: '2-2',
            title: 'Ocean Drift',
            artist: 'Wave Runner',
            album: 'Fluidity Vol. 1',
            filePath: '/music/fluidity/ocean_drift.mp3',
            duration: const Duration(minutes: 4, seconds: 20),
            accentColor: const Color(0xFF00CED1),
            lastPlayed: DateTime.now().subtract(const Duration(hours: 3)),
            playCount: 167,
          ),
          SongModel(
            id: '2-3',
            title: 'Tidal Wave',
            artist: 'Deep Blue',
            album: 'Fluidity Vol. 1',
            filePath: '/music/fluidity/tidal_wave.mp3',
            duration: const Duration(minutes: 3, seconds: 15),
            accentColor: const Color(0xFF00CED1),
            playCount: 45,
          ),
        ],
      ),
      FolderModel(
        id: '3',
        name: 'Neon Horizons',
        artist: 'Lumine',
        accentColor: const Color(0xFF4B0082),
        lastPlayed: DateTime.now().subtract(const Duration(days: 3)),
        playCount: 67,
        songs: [
          SongModel(
            id: '3-1',
            title: 'Horizon Line',
            artist: 'Lumine',
            album: 'Neon Horizons',
            filePath: '/music/neon_horizons/horizon_line.mp3',
            duration: const Duration(minutes: 4, seconds: 5),
            accentColor: const Color(0xFF4B0082),
            lastPlayed: DateTime.now().subtract(const Duration(hours: 12)),
            playCount: 123,
          ),
          SongModel(
            id: '3-2',
            title: 'Neon Dreams',
            artist: 'Lumine',
            album: 'Neon Horizons',
            filePath: '/music/neon_horizons/neon_dreams.mp3',
            duration: const Duration(minutes: 3, seconds: 50),
            accentColor: const Color(0xFF4B0082),
            playCount: 89,
          ),
        ],
      ),
      FolderModel(
        id: '4',
        name: 'Unknown Album',
        artist: 'Unknown Artist',
        accentColor: AppColors.disabled,
        songs: [],
      ),
      FolderModel(
        id: '5',
        name: 'Digital Dreams',
        artist: 'Synthwave Collective',
        accentColor: AppColors.primary,
        lastPlayed: DateTime.now().subtract(const Duration(hours: 5)),
        playCount: 89,
        songs: [
          SongModel(
            id: '5-1',
            title: 'Digital Sunrise',
            artist: 'Synthwave Collective',
            album: 'Digital Dreams',
            filePath: '/music/digital_dreams/digital_sunrise.mp3',
            duration: const Duration(minutes: 4, seconds: 30),
            accentColor: AppColors.primary,
            lastPlayed: DateTime.now().subtract(const Duration(hours: 5)),
            playCount: 200,
          ),
          SongModel(
            id: '5-2',
            title: 'Retro Future',
            artist: 'Synthwave Collective',
            album: 'Digital Dreams',
            filePath: '/music/digital_dreams/retro_future.mp3',
            duration: const Duration(minutes: 3, seconds: 45),
            accentColor: AppColors.primary,
            playCount: 150,
          ),
          SongModel(
            id: '5-3',
            title: 'Cyber Love',
            artist: 'Synthwave Collective',
            album: 'Digital Dreams',
            filePath: '/music/digital_dreams/cyber_love.mp3',
            duration: const Duration(minutes: 3, seconds: 55),
            accentColor: AppColors.primary,
            playCount: 120,
          ),
        ],
      ),
      FolderModel(
        id: '6',
        name: 'Analog Nights',
        artist: 'Retro Future',
        accentColor: AppColors.secondary,
        lastPlayed: DateTime.now().subtract(const Duration(days: 2)),
        playCount: 34,
        songs: [
          SongModel(
            id: '6-1',
            title: 'Analog Heart',
            artist: 'Retro Future',
            album: 'Analog Nights',
            filePath: '/music/analog_nights/analog_heart.mp3',
            duration: const Duration(minutes: 4, seconds: 15),
            accentColor: AppColors.secondary,
            lastPlayed: DateTime.now().subtract(const Duration(days: 2)),
            playCount: 56,
          ),
          SongModel(
            id: '6-2',
            title: 'Tape Rewind',
            artist: 'Retro Future',
            album: 'Analog Nights',
            filePath: '/music/analog_nights/tape_rewind.mp3',
            duration: const Duration(minutes: 3, seconds: 30),
            accentColor: AppColors.secondary,
            playCount: 34,
          ),
        ],
      ),
    ];
  }
}
