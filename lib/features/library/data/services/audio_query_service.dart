import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:podwave/features/library/data/models/song_model.dart' as app_models;
import 'package:podwave/features/library/data/models/album_model.dart' as app_models;
import 'package:path_provider/path_provider.dart';
import 'package:id3/id3.dart';

class AudioQueryService {
  static final AudioQueryService _instance = AudioQueryService._internal();
  factory AudioQueryService() => _instance;
  AudioQueryService._internal();

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getSdkInt();

      if (sdkInt >= 33) {
        // Android 13+ - granular permissions
        final audioStatus = await Permission.audio.request();
        return audioStatus.isGranted;
      } else if (sdkInt >= 30) {
        // Android 11-12 - MANAGE_EXTERNAL_STORAGE or storage
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          final manageStatus = await Permission.manageExternalStorage.request();
          return manageStatus.isGranted;
        }
        return true;
      } else {
        // Android 10 and below - simple storage permission
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
    } else if (Platform.isIOS) {
      final mediaStatus = await Permission.mediaLibrary.request();
      return mediaStatus.isGranted;
    }
    return false;
  }

  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getSdkInt();

      if (sdkInt >= 33) {
        final audioStatus = await Permission.audio.status;
        return audioStatus.isGranted;
      } else if (sdkInt >= 30) {
        final storageStatus = await Permission.storage.status;
        final manageStatus = await Permission.manageExternalStorage.status;
        return storageStatus.isGranted || manageStatus.isGranted;
      } else {
        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      }
    } else if (Platform.isIOS) {
      final mediaStatus = await Permission.mediaLibrary.status;
      return mediaStatus.isGranted;
    }
    return false;
  }

  Future<int> _getSdkInt() async {
    if (Platform.isAndroid) {
      // Get from platform
      return 33; // Default to assuming modern Android
    }
    return 0;
  }

  Future<List<app_models.SongModel>> querySongs() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) {
          return [];
        }
      }

      final List<File> audioFiles = await _scanForAudioFiles();
      final List<app_models.SongModel> songs = [];

      for (final file in audioFiles) {
        try {
          final song = await _extractMetadata(file);
          if (song != null) {
            songs.add(song);
          }
        } catch (e) {
          debugPrint('Error extracting metadata from ${file.path}: $e');
        }
      }

      // Sort by title
      songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return songs;
    } catch (e) {
      debugPrint('Error querying songs: $e');
      return [];
    }
  }

  Future<List<File>> _scanForAudioFiles() async {
    final List<File> audioFiles = [];
    final List<String> searchPaths = await _getSearchPaths();

    for (final path in searchPaths) {
      final dir = Directory(path);
      if (dir.existsSync()) {
        try {
          await _scanDirectory(dir, audioFiles);
        } catch (e) {
          debugPrint('Error scanning directory $path: $e');
        }
      }
    }

    return audioFiles;
  }

  Future<List<String>> _getSearchPaths() async {
    final List<String> paths = [];

    if (Platform.isAndroid) {
      // Common Android music directories
      paths.add('/storage/emulated/0/Music');
      paths.add('/storage/emulated/0/Download');
      paths.add('/storage/emulated/0/Documents');
      paths.add('/storage/emulated/0/Audio');
      // SnapTube download folder
      paths.add('/storage/emulated/0/snaptube/download/SnapTube Audio');

      // External SD card paths (may vary by device)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        paths.add('${externalDir.path}/Music');
        paths.add('${externalDir.path}/Download');
      }
    } else if (Platform.isIOS) {
      // iOS - app documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      paths.add(docsDir.path);
    }

    return paths;
  }

  Future<void> _scanDirectory(Directory dir, List<File> files) async {
    final List<String> extensions = ['.mp3', '.aac', '.m4a', '.wav', '.ogg', '.flac', '.wma', '.opus'];

    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final lowerPath = entity.path.toLowerCase();
          if (extensions.any((ext) => lowerPath.endsWith(ext))) {
            files.add(entity);
          }
        }
      }
    } catch (e) {
      // Permission denied on some subdirectories - skip them
      debugPrint('Permission denied in subdirectory: $e');
    }
  }

  Future<app_models.SongModel?> _extractMetadata(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));

      // Try to parse artist - title format from filename
      String title = nameWithoutExt;
      String artist = 'Unknown Artist';
      String? album;
      String? albumArtPath;

      if (nameWithoutExt.contains(' - ')) {
        final parts = nameWithoutExt.split(' - ');
        if (parts.length >= 2) {
          artist = parts[0].trim();
          title = parts.sublist(1).join(' - ').trim();
        }
      }

      // Extract metadata from audio file using id3
      try {
        final mp3Bytes = await file.readAsBytes();
        final mp3Instance = MP3Instance(mp3Bytes);

        if (mp3Instance.parseTagsSync()) {
          final tags = mp3Instance.getMetaTags();
          if (tags != null) {
            if (tags['Title'] != null && tags['Title'].toString().isNotEmpty) {
              title = tags['Title'].toString();
            }
            if (tags['Artist'] != null && tags['Artist'].toString().isNotEmpty) {
              artist = tags['Artist'].toString();
            } else if (tags['Band'] != null && tags['Band'].toString().isNotEmpty) {
              artist = tags['Band'].toString();
            }
            if (tags['Album'] != null && tags['Album'].toString().isNotEmpty) {
              album = tags['Album'].toString();
            }

            // Extract embedded album art (APIC frame)
            if (tags['APIC'] != null) {
              final imageBytes = _extractImageFromApic(tags['APIC'] as List<int>);
              if (imageBytes != null) {
                final artwork = await _saveEmbeddedArtworkFromBytes(file.path, imageBytes);
                if (artwork != null) {
                  albumArtPath = artwork;
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error reading audio tags from ${file.path}: $e');
      }

      // If no embedded artwork, try folder-based artwork
      if (albumArtPath == null) {
        albumArtPath = await _findFolderArtwork(file.path);
      }

      // Get file duration
      final fileStat = await file.stat();
      final duration = await _estimateDuration(file);

      // Generate album ID from album name + artist
      final albumId = album != null ? '${album}_$artist'.hashCode.toString() : null;

      return app_models.SongModel(
        id: file.path.hashCode.toString(),
        title: title,
        artist: artist,
        album: album,
        albumId: albumId,
        filePath: file.path,
        duration: duration,
        accentColor: null,
        lastPlayed: null,
        playCount: 0,
        isFavorite: false,
        dateAdded: fileStat.modified,
        albumArtPath: albumArtPath,
      );
    } catch (e) {
      debugPrint('Error extracting metadata from ${file.path}: $e');
      return null;
    }
  }

  /// Extracts image bytes from APIC frame data
  /// APIC format: [text encoding 1byte][MIME type null-term][pic type 1byte][desc null-term][image data]
  List<int>? _extractImageFromApic(List<int> apicData) {
    try {
      if (apicData.length < 10) return null;

      int offset = 0;

      // Skip text encoding (1 byte)
      offset++;

      // Skip MIME type (null-terminated string)
      while (offset < apicData.length && apicData[offset] != 0) {
        offset++;
      }
      offset++; // Skip null terminator

      if (offset >= apicData.length) return null;

      // Skip picture type (1 byte)
      offset++;

      if (offset >= apicData.length) return null;

      // Skip description (null-terminated string)
      while (offset < apicData.length && apicData[offset] != 0) {
        offset++;
      }
      offset++; // Skip null terminator

      if (offset >= apicData.length) return null;

      // Remaining bytes are the image data
      return apicData.sublist(offset);
    } catch (e) {
      debugPrint('Error extracting image from APIC: $e');
      return null;
    }
  }

  Future<String?> _saveEmbeddedArtworkFromBytes(String filePath, List<int> imageBytes) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final artworkDir = Directory('${appDir.path}/artwork_cache');
      if (!await artworkDir.exists()) {
        await artworkDir.create(recursive: true);
      }

      // Detect image format from bytes
      String ext = 'jpg';
      if (imageBytes.length > 8) {
        // Check PNG signature (first 8 bytes: 89 50 4E 47 0D 0A 1A 0A)
        if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50 &&
            imageBytes[2] == 0x4E && imageBytes[3] == 0x47) {
          ext = 'png';
        }
      }

      // Create unique filename based on song path hash
      final fileHash = base64Url.encode(utf8.encode(filePath)).replaceAll('=', '').substring(0, 16);
      final artworkFile = File('${artworkDir.path}/$fileHash.$ext');

      await artworkFile.writeAsBytes(imageBytes);
      return artworkFile.path;
    } catch (e) {
      debugPrint('Error saving embedded artwork: $e');
      return null;
    }
  }

  Future<String?> _findFolderArtwork(String filePath) async {
    try {
      final dir = Directory(filePath.substring(0, filePath.lastIndexOf('/')));
      final artFiles = ['cover.jpg', 'cover.png', 'folder.jpg', 'folder.png', 'album.jpg', 'album.png', 'art.jpg', 'art.png'];

      for (final artFile in artFiles) {
        final file = File('${dir.path}/$artFile');
        if (await file.exists()) {
          return file.path;
        }
      }
    } catch (e) {
      debugPrint('Error finding folder artwork: $e');
    }
    return null;
  }

  Future<Duration> _estimateDuration(File file) async {
    // For now, return 0 - we'll need actual duration from audio player
    // This is a placeholder - real implementation would parse audio headers
    return Duration.zero;
  }

  Future<List<app_models.AlbumModel>> queryAlbums() async {
    // For now, return empty list - albums can be derived from songs
    return [];
  }

  Future<Uint8List?> queryArtwork(String filePath) async {
    // First, try to get saved embedded artwork
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileHash = base64Url.encode(utf8.encode(filePath)).replaceAll('=', '').substring(0, 16);

      // Check both jpg and png extensions
      for (final ext in ['jpg', 'png']) {
        final artworkFile = File('${appDir.path}/artwork_cache/$fileHash.$ext');
        if (await artworkFile.exists()) {
          return await artworkFile.readAsBytes();
        }
      }
    } catch (e) {
      debugPrint('Error reading cached artwork: $e');
    }

    // Fallback to folder-based artwork
    return await _getFolderArtworkBytes(filePath);
  }

  Future<Uint8List?> _getFolderArtworkBytes(String filePath) async {
    try {
      final dir = Directory(filePath.substring(0, filePath.lastIndexOf('/')));
      final artFiles = ['cover.jpg', 'cover.png', 'folder.jpg', 'folder.png', 'album.jpg', 'album.png', 'art.jpg', 'art.png'];

      for (final artFile in artFiles) {
        final file = File('${dir.path}/$artFile');
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    } catch (e) {
      debugPrint('Error reading folder artwork: $e');
    }
    return null;
  }
}
