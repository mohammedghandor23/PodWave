import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/core/routing/app_router.dart';
import 'package:podwave/features/library/presentation/controllers/library_controller.dart';
import 'package:podwave/features/library/presentation/widgets/mini_player.dart';
import 'package:podwave/features/now_playing/presentation/controllers/audio_controller.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);

    return AnimatedBuilder(
      animation: router.routeInformationProvider,
      builder: (context, _) {
        final location = router.routerDelegate.currentConfiguration.uri.toString();
        final isOverlayRoute = location.startsWith(AppRoutes.nowPlaying) ||
            location.startsWith(AppRoutes.queue) ||
            location.startsWith(AppRoutes.folderDetails);

        if (isOverlayRoute) return const SizedBox.shrink();

        final currentSongAsync = ref.watch(currentSongProvider);
        final isPlayingAsync = ref.watch(isPlayingProvider);
        final allSongs = ref.watch(allSongsProvider);

        final currentSong = currentSongAsync.valueOrNull;
        final isPlaying = isPlayingAsync.valueOrNull ?? false;

        if (currentSong == null && allSongs.isEmpty) {
          return const SizedBox.shrink();
        }

        final songToShow = currentSong ?? (allSongs.isNotEmpty ? allSongs.first : null);
        if (songToShow == null) return const SizedBox.shrink();

        return MiniPlayer(
          currentSong: songToShow,
          isPlaying: isPlaying,
          onPlayPause: () => ref.read(audioControllerProvider.notifier).togglePlayPause(),
          onTap: () async {
            if (currentSong == null && allSongs.isNotEmpty) {
              await ref.read(audioControllerProvider.notifier).playSong(allSongs.first);
            }
            if (!context.mounted) return;
            context.push(AppRoutes.nowPlaying, extra: songToShow);
          },
        );
      },
    );
  }
}
