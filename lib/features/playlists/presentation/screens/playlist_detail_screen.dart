import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/routing/app_router.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/core/widgets/resume_dialog.dart';
import 'package:podwave/core/widgets/song_list_item.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/library/presentation/controllers/library_controller.dart';
import 'package:podwave/features/now_playing/presentation/controllers/audio_controller.dart';
import 'package:podwave/features/playlists/data/models/playlist_model.dart';
import 'package:podwave/features/playlists/presentation/controllers/playlist_controller.dart';
import 'package:podwave/features/playlists/presentation/screens/add_songs_screen.dart';
import 'package:podwave/features/settings/presentation/controllers/settings_controller.dart';
import 'package:podwave/l10n/app_localizations.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final playlists = ref.watch(playlistControllerProvider);
    final current = playlists.firstWhere(
      (p) => p.id == playlist.id,
      orElse: () => playlist,
    );
    final libraryState = ref.watch(libraryControllerProvider);

    return libraryState.when(
      data: (allSongs) {
        final songMap = {for (final s in allSongs) s.id: s};
        final songs = current.songIds
            .map((id) => songMap[id])
            .whereType<SongModel>()
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20.sp),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(current.name, style: AppTextStyles.titleMedium),
            actions: [
              if (!current.isDefault)
                PopupMenuButton<_MenuAction>(
                  icon: Icon(Icons.more_vert,
                      color: AppColors.textPrimary, size: 24.sp),
                  color: AppColors.card,
                  onSelected: (action) =>
                      _handleMenuAction(context, ref, action, current, l10n),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _MenuAction.rename,
                      child: Text(l10n.rename,
                          style: AppTextStyles.bodyMedium),
                    ),
                    PopupMenuItem(
                      value: _MenuAction.delete,
                      child: Text(l10n.delete,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
            ],
          ),
          body: songs.isEmpty
              ? _EmptyPlaylistBody(
                  playlistId: current.id,
                  isDefault: current.isDefault,
                )
              : _SongsBody(
                  songs: songs,
                  playlistId: current.id,
                  isDefault: current.isDefault,
                  onSongTap: (song) =>
                      _playSong(context, ref, song, songs),
                ),
          floatingActionButton: current.isDefault
              ? null
              : FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: () => _openAddSongs(context, current),
                  child: Icon(Icons.add, color: Colors.white, size: 28.sp),
                ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('$e', style: AppTextStyles.bodyMedium)),
      ),
    );
  }

  void _openAddSongs(BuildContext context, PlaylistModel current) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddSongsScreen(
          playlistId: current.id,
          existingSongIds: current.songIds,
        ),
      ),
    );
  }

  Future<void> _playSong(
    BuildContext context,
    WidgetRef ref,
    SongModel song,
    List<SongModel> queue,
  ) async {
    final audioController = ref.read(audioControllerProvider.notifier);
    final settings = ref.read(settingsControllerProvider);
    final savedPosition = audioController.getSavedPosition(song.id);
    Duration? startPosition;

    if (savedPosition != null && savedPosition.inSeconds > 10) {
      if (settings.resumeMode == ResumeMode.auto) {
        startPosition = savedPosition;
      } else {
        final shouldResume = await showResumeDialog(context, savedPosition);
        if (!context.mounted) return;
        if (shouldResume) startPosition = savedPosition;
      }
    }

    final queueIndex = queue.indexWhere((s) => s.id == song.id);
    // ignore: unawaited_futures
    audioController.playSong(
      song,
      startPosition: startPosition,
      queue: queue,
      queueIndex: queueIndex >= 0 ? queueIndex : 0,
    );
    if (!context.mounted) return;
    context.push(AppRoutes.nowPlaying, extra: song);
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    _MenuAction action,
    PlaylistModel current,
    AppLocalizations l10n,
  ) {
    if (action == _MenuAction.rename) {
      _showRenameDialog(context, ref, current, l10n);
    } else if (action == _MenuAction.delete) {
      _showDeleteDialog(context, ref, current, l10n);
    }
  }

  void _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    PlaylistModel current,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: current.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(l10n.rename, style: AppTextStyles.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: l10n.playlistNameHint,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(playlistControllerProvider.notifier)
                    .renamePlaylist(current.id, name);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.rename,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    PlaylistModel current,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(l10n.deletePlaylistConfirm,
            style: AppTextStyles.titleMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(playlistControllerProvider.notifier)
                  .deletePlaylist(current.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(l10n.delete,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

enum _MenuAction { rename, delete }

class _EmptyPlaylistBody extends ConsumerWidget {
  final String playlistId;
  final bool isDefault;

  const _EmptyPlaylistBody({
    required this.playlistId,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.queue_music_rounded,
            size: 72.sp,
            color: AppColors.disabled,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            l10n.emptyPlaylist,
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          if (!isDefault) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              l10n.addSongsToPlaylist,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _SongsBody extends StatelessWidget {
  final List<SongModel> songs;
  final String playlistId;
  final bool isDefault;
  final void Function(SongModel) onSongTap;

  const _SongsBody({
    required this.songs,
    required this.playlistId,
    required this.isDefault,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: songs.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final song = songs[index];
        return isDefault
            ? SongListItem(
                song: song,
                onTap: () => onSongTap(song),
              )
            : _RemovableSongItem(
                song: song,
                playlistId: playlistId,
                onTap: () => onSongTap(song),
              );
      },
    );
  }
}

class _RemovableSongItem extends ConsumerWidget {
  final SongModel song;
  final String playlistId;
  final VoidCallback onTap;

  const _RemovableSongItem({
    required this.song,
    required this.playlistId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SongListItem(
      song: song,
      onTap: onTap,
      onMorePressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          builder: (_) => Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                ListTile(
                  leading: Icon(Icons.remove_circle_outline,
                      color: AppColors.error, size: 24.sp),
                  title: Text(l10n.delete,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error)),
                  onTap: () {
                    Navigator.of(context).pop();
                    ref
                        .read(playlistControllerProvider.notifier)
                        .removeSongFromPlaylist(playlistId, song.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
