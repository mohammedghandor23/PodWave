import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/now_playing/presentation/controllers/audio_controller.dart';
import 'package:podwave/features/now_playing/presentation/widgets/album_art_widget.dart';
import 'package:podwave/features/now_playing/presentation/widgets/now_playing_app_bar.dart';
import 'package:podwave/features/now_playing/presentation/widgets/playback_controls.dart';
import 'package:podwave/features/now_playing/presentation/widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  final SongModel? song;

  const NowPlayingScreen({
    super.key,
    this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final currentSongAsync = ref.watch(currentSongProvider);
            final isPlayingAsync = ref.watch(isPlayingProvider);
            final positionAsync = ref.watch(positionProvider);
            final durationAsync = ref.watch(durationProvider);
            final hasNext = ref.watch(hasNextProvider);
            final hasPrevious = ref.watch(hasPreviousProvider);
            final audioController = ref.read(audioControllerProvider.notifier);

            final audioService = ref.read(audioServiceProvider);
            final currentSong = currentSongAsync.valueOrNull
                ?? song
                ?? audioService.currentSong;
            final isPlaying = isPlayingAsync.valueOrNull
                ?? audioService.isPlaying;
            final position = positionAsync.valueOrNull
                ?? audioService.position;
            final duration = durationAsync.valueOrNull
                ?? audioService.duration;

            if (currentSong == null) {
              return const Center(
                child: Text('No song playing'),
              );
            }

            return Column(
              children: [
                const NowPlayingAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        children: [
                          SizedBox(height: AppSpacing.xxl),
                          AlbumArtWidget(
                            coverArtPath: currentSong.albumId,
                            accentColor: currentSong.accentColor ?? AppColors.primary,
                          ),
                          SizedBox(height: AppSpacing.xxxl),
                          Text(
                            currentSong.title,
                            style: AppTextStyles.headlineSmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            currentSong.artist,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.xxxl),
                          ProgressBar(
                            currentPosition: position,
                            totalDuration: duration,
                            onSeek: (progress) {
                              audioController.seek(progress);
                            },
                          ),
                          SizedBox(height: AppSpacing.lg),
                          PlaybackControls(
                            isPlaying: isPlaying,
                            onPlayPause: () {
                              audioController.togglePlayPause();
                            },
                            onSeekBackward: () {
                              audioController.seekBackward10Seconds();
                            },
                            onSeekForward: () {
                              audioController.seekForward10Seconds();
                            },
                            onPrevious: hasPrevious
                                ? () => audioController.playPrevious()
                                : null,
                            onNext: hasNext
                                ? () => audioController.playNext()
                                : null,
                            onShuffle: () {},
                            onRepeat: () {},
                          ),
                          SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
