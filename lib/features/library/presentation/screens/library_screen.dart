import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/routing/app_router.dart';
import 'package:podwave/core/widgets/resume_dialog.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/widgets/nova_app_bar.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/library/presentation/controllers/library_controller.dart';
import 'package:podwave/features/library/presentation/controllers/library_filter_controller.dart';
import 'package:podwave/features/library/presentation/controllers/library_search_controller.dart';import 'package:podwave/features/library/presentation/widgets/library_filter_chips.dart';
import 'package:podwave/features/library/presentation/widgets/library_search_bar.dart';
import 'package:podwave/core/widgets/song_list_item.dart';
import 'package:podwave/features/now_playing/presentation/controllers/audio_controller.dart';
import 'package:podwave/features/settings/presentation/controllers/settings_controller.dart';
import 'package:podwave/l10n/app_localizations.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryControllerProvider.notifier).loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await ref.read(libraryControllerProvider.notifier).refreshLibrary();
              },
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                slivers: [
                  const NovaAppBar(),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSpacing.md),
                        const LibrarySearchBar(),
                        SizedBox(height: AppSpacing.md),
                        const LibraryFilterChips(),
                        SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                  const _LibraryContent(),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 120.h),
                  ),
                ],
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}


class _LibraryContent extends ConsumerWidget {
  const _LibraryContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(libraryFilterControllerProvider);
    final searchQuery = ref.watch(librarySearchControllerProvider);
    final libraryState = ref.watch(libraryControllerProvider);
    final repository = ref.watch(libraryRepositoryProvider);

    void onSongTapped(SongModel song, List<SongModel> songList) async {
      final audioController = ref.read(audioControllerProvider.notifier);
      final settings = ref.read(settingsControllerProvider);

      // Check for saved position
      final savedPosition = audioController.getSavedPosition(song.id);
      Duration? startPosition;

      if (savedPosition != null && savedPosition.inSeconds > 10) {
        if (settings.resumeMode == ResumeMode.auto) {
          startPosition = savedPosition;
        } else {
          final shouldResume = await showResumeDialog(context, savedPosition);
          if (!context.mounted) return;
          if (shouldResume) {
            startPosition = savedPosition;
          }
        }
      }

      final queueIndex = songList.indexWhere((s) => s.id == song.id);
      unawaited(audioController.playSong(
        song,
        startPosition: startPosition,
        queue: songList,
        queueIndex: queueIndex >= 0 ? queueIndex : 0,
      ));
      if (!context.mounted) return;
      ref.read(libraryControllerProvider.notifier).updatePlayStats(song.id);
      context.push(AppRoutes.nowPlaying, extra: song);
    }


    return libraryState.when(
      data: (songs) {
        if (songs.isEmpty && searchQuery.isEmpty) {
          return SliverFillRemaining(
            child: _EmptyLibraryState(
              onRefresh: () => ref.read(libraryControllerProvider.notifier).refreshLibrary(),
            ),
          );
        }

        if (searchQuery.isNotEmpty) {
          final searchResults = repository.searchSongs(searchQuery);
          if (searchResults.isEmpty) {
            return const SliverFillRemaining(
              child: _NoResultsState(),
            );
          }
          final searchList = searchResults;
          return _SongList(
            songs: searchList,
            onSongTap: (song, list) => onSongTapped(song, list),
          );
        }

        switch (filter) {
          case LibraryFilter.recentlyPlayed:
            final recentSongs = repository.getRecentlyPlayedSongs();
            final recentList = recentSongs.isEmpty ? songs.take(10).toList() : recentSongs;
            return _SongList(
              songs: recentList,
              onSongTap: (song, list) => onSongTapped(song, list),
            );
          case LibraryFilter.songs:
            return _SongList(
              songs: songs,
              onSongTap: (song, list) => onSongTapped(song, list),
            );
          case LibraryFilter.mostPlayed:
            final mostPlayedSongs = repository.getMostPlayedSongs();
            final mostPlayedList = mostPlayedSongs.isEmpty
                ? (List<SongModel>.from(songs)..sort((a, b) => b.playCount.compareTo(a.playCount))).take(20).toList()
                : mostPlayedSongs;
            return _SongList(
              songs: mostPlayedList,
              onSongTap: (song, list) => onSongTapped(song, list),
            );
          case LibraryFilter.lastAdded:
            final lastAddedSongs = repository.getRecentlyAddedSongs(limit: songs.length);
            final lastAddedList = lastAddedSongs.isEmpty ? songs : lastAddedSongs;
            return _SongList(
              songs: lastAddedList,
              onSongTap: (song, list) => onSongTapped(song, list),
            );
        }
      },
      loading: () => const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => SliverFillRemaining(
        child: Center(
          child: Text(
            'Error: $error',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ),
    );
  }
}


class _SongList extends StatelessWidget {
  final List<SongModel> songs;
  final void Function(SongModel, List<SongModel>)? onSongTap;

  const _SongList({
    required this.songs,
    this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              l10n.noSongsFound,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final song = songs[index];
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: SongListItem(
                song: song,
                onTap: () => onSongTap?.call(song, songs),
              ),
            );
          },
          childCount: songs.length,
        ),
      ),
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyLibraryState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            l10n.noSongsFound,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.refresh),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          l10n.noResultsFound,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
