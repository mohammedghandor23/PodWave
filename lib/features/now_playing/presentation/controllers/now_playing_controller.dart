import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

final nowPlayingControllerProvider = StateNotifierProvider<NowPlayingController, SongModel?>(
  (ref) => NowPlayingController(),
);

class NowPlayingController extends StateNotifier<SongModel?> {
  NowPlayingController() : super(null);

  void playSong(SongModel song) {
    state = song;
  }

  void clear() {
    state = null;
  }
}
