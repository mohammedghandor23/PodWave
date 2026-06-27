import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/routing/app_router.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/core/widgets/nova_app_bar.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/library/presentation/controllers/library_controller.dart';
import 'package:podwave/features/playlists/data/models/playlist_model.dart';
import 'package:podwave/features/playlists/presentation/controllers/playlist_controller.dart';
import 'package:podwave/l10n/app_localizations.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(l10n.createPlaylist, style: AppTextStyles.titleMedium.copyWith(fontSize: 20.sp)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: l10n.playlistNameHint,
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, fontSize: 16.sp),
            labelText: l10n.playlistName,
            labelStyle: AppTextStyles.bodySmall,
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
                    .createPlaylist(name);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.create,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _openPlaylist(BuildContext context, PlaylistModel playlist) {
    context.push(AppRoutes.playlistDetail, extra: playlist);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final playlists = ref.watch(playlistControllerProvider);
    final libraryState = ref.watch(libraryControllerProvider);

    final defaultPlaylists = _buildDefaultPlaylists(l10n, libraryState);
    final userPlaylists =
        playlists.where((p) => !p.isDefault).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            NovaAppBar(title: l10n.playlists),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSpacing.sm),
                    _DefaultPlaylistsRow(
                      playlists: defaultPlaylists,
                      onTap: (p) => _openPlaylist(context, p),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    _UserPlaylistsSection(
                      playlists: userPlaylists,
                      onTap: (p) => _openPlaylist(context, p),
                    ),
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 70.h),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _showCreateDialog(context, ref, l10n),
          child: Icon(Icons.add, color: Colors.white, size: 28.sp),
        ),
      ),
    );
  }

  List<PlaylistModel> _buildDefaultPlaylists(
    AppLocalizations l10n,
    AsyncValue<List<SongModel>> libraryState,
  ) {
    final allSongs = libraryState.valueOrNull ?? [];

    final recentlyAdded = [...allSongs]
      ..sort((a, b) =>
          (b.dateAdded ?? DateTime(0)).compareTo(a.dateAdded ?? DateTime(0)));

    final mostPlayed = [...allSongs]
      ..sort((a, b) => b.playCount.compareTo(a.playCount));

    return [
      PlaylistModel(
        id: '__recently_added__',
        name: l10n.recentlyAdded,
        songIds: recentlyAdded.map((s) => s.id).toList(),
        createdAt: DateTime(0),
        isDefault: true,
      ),
      PlaylistModel(
        id: '__most_played__',
        name: l10n.mostPlayed,
        songIds: mostPlayed
            .where((s) => s.playCount > 0)
            .map((s) => s.id)
            .toList(),
        createdAt: DateTime(0),
        isDefault: true,
      ),
    ];
  }
}

class _DefaultPlaylistsRow extends StatelessWidget {
  final List<PlaylistModel> playlists;
  final void Function(PlaylistModel) onTap;

  const _DefaultPlaylistsRow({
    required this.playlists,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: playlists.map((playlist) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: playlist == playlists.last ? 0 : AppSpacing.md,
            ),
            child: _PlaylistCard(
              playlist: playlist,
              onTap: () => onTap(playlist),
              isDefault: true,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UserPlaylistsSection extends StatelessWidget {
  final List<PlaylistModel> playlists;
  final void Function(PlaylistModel) onTap;

  const _UserPlaylistsSection({
    required this.playlists,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (playlists.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.playlists, style: AppTextStyles.titleLarge),
          SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Icon(Icons.playlist_add, size: 64.sp, color: AppColors.disabled),
                SizedBox(height: AppSpacing.md),
                Text(
                  l10n.noPlaylists,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.playlists, style: AppTextStyles.titleLarge),
        SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.1,
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return _PlaylistCard(
              playlist: playlist,
              onTap: () => onTap(playlist),
              isDefault: false,
            );
          },
        ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final bool isDefault;

  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
    required this.isDefault,
  });

  Color get _cardColor {
    if (playlist.id == '__recently_added__') return AppColors.secondary;
    if (playlist.id == '__most_played__') return AppColors.tertiary;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.primary.withValues(alpha: 0.8),
    ];
    return colors[playlist.name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _cardColor;
    final songCount = playlist.songIds.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withValues(alpha: 0.5),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.queue_music_rounded,
                size: 100.sp,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    playlist.name,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '$songCount ${songCount == 1 ? 'song' : 'songs'}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white.withValues(alpha: 0.8)),
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
