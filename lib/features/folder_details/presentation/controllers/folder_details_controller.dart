import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwave/features/folder_details/data/models/folder_model.dart';
import 'package:podwave/features/folder_details/data/services/folder_details_service.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

final folderDetailsControllerProvider = StateNotifierProvider.family<FolderDetailsController, FolderDetailsState, String>(
  (ref, folderId) => FolderDetailsController(folderId: folderId),
);

class FolderDetailsState {
  final FolderModel? folder;
  final SongModel? currentlyPlayingSong;
  final bool isLoading;
  final String? error;

  const FolderDetailsState({
    this.folder,
    this.currentlyPlayingSong,
    this.isLoading = false,
    this.error,
  });

  FolderDetailsState copyWith({
    FolderModel? folder,
    SongModel? currentlyPlayingSong,
    bool? isLoading,
    String? error,
  }) {
    return FolderDetailsState(
      folder: folder ?? this.folder,
      currentlyPlayingSong: currentlyPlayingSong ?? this.currentlyPlayingSong,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FolderDetailsController extends StateNotifier<FolderDetailsState> {
  final String folderId;
  final FolderDetailsService _service = FolderDetailsService();

  FolderDetailsController({required this.folderId}) : super(const FolderDetailsState(isLoading: false)) {
    loadFolder();
  }

  void loadFolder() {
    final folder = _service.getFolderById(folderId);
    if (folder != null) {
      state = state.copyWith(folder: folder, isLoading: false);
    } else {
      state = state.copyWith(
        error: 'Folder not found',
        isLoading: false,
      );
    }
  }

  void playSong(SongModel song) {
    state = state.copyWith(currentlyPlayingSong: song);
  }

  void stopPlaying() {
    state = state.copyWith(currentlyPlayingSong: null);
  }

  bool get isPlaying => state.currentlyPlayingSong != null;

  SongModel? get currentlyPlayingSong => state.currentlyPlayingSong;
}
