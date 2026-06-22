import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/core/routing/app_router.dart';
import 'package:podwave/core/widgets/resume_dialog.dart';
import 'package:podwave/core/widgets/song_list_item.dart';
import 'package:podwave/features/folder_details/presentation/controllers/folder_details_controller.dart';
import 'package:podwave/features/folder_details/presentation/widgets/playing_song_list_item.dart';
import 'package:podwave/features/now_playing/presentation/controllers/audio_controller.dart';
import 'package:podwave/features/settings/presentation/controllers/settings_controller.dart';
import 'package:podwave/l10n/app_localizations.dart';

class FolderDetailsScreen extends StatelessWidget {
  final String folderId;

  const FolderDetailsScreen({
    super.key,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(folderDetailsControllerProvider(folderId));
        final controller = ref.read(folderDetailsControllerProvider(folderId).notifier);
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, state, l10n),
                _buildFolderHeader(context, state),
                _buildSongsList(context, state, controller, ref, l10n),
                SliverToBoxAdapter(
                  child: SizedBox(height: 120.h),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, FolderDetailsState state, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 20.w,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                state.folder?.name ?? l10n.albums,
                style: AppTextStyles.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderHeader(BuildContext context, FolderDetailsState state) {
    final folder = state.folder;
    final l10n = AppLocalizations.of(context)!;
    if (folder == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    folder.accentColor ?? AppColors.primary,
                    (folder.accentColor ?? AppColors.primary).withAlpha(80),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (folder.accentColor ?? AppColors.primary).withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.album,
                  color: Colors.white.withAlpha(200),
                  size: 64.w,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              folder.name,
              style: AppTextStyles.headlineSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              folder.artist ?? '',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              l10n.songCount(folder.songCount),
              style: AppTextStyles.bodySmall,
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList(BuildContext context, FolderDetailsState state, FolderDetailsController controller, WidgetRef ref, AppLocalizations l10n) {
    final folder = state.folder;

    if (folder == null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              l10n.folderNotFound,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    final songs = folder.songs;
    if (songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              l10n.noSongsInFolder,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
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
            final isPlaying = state.currentlyPlayingSong?.id == song.id;

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: isPlaying
                  ? PlayingSongListItem(
                      song: song,
                      isPlaying: true,
                      onTap: () => ref.read(audioControllerProvider.notifier).togglePlayPause(),
                      onStopPressed: () => controller.stopPlaying(),
                      onMorePressed: () {},
                    )
                  : SongListItem(
                      song: song,
                      onTap: () async {
                        controller.playSong(song);
                        final audioController = ref.read(audioControllerProvider.notifier);
                        final settings = ref.read(settingsControllerProvider);

                        // Check for saved position
                        final savedPosition = audioController.getSavedPosition(song.id);
                        Duration? startPosition;

                        if (savedPosition != null && savedPosition.inSeconds > 10) {
                          if (settings.resumeMode == ResumeMode.auto) {
                            // Auto-resume mode
                            startPosition = savedPosition;
                          } else {
                            // Prompt mode - show dialog
                            final shouldResume = await showResumeDialog(context, savedPosition);
                            if (!context.mounted) return;
                            if (shouldResume) {
                              startPosition = savedPosition;
                            }
                          }
                        }

                        unawaited(audioController.playSong(song, startPosition: startPosition));
                        if (!context.mounted) return;
                        context.push(AppRoutes.nowPlaying, extra: song);
                      },
                      onMorePressed: () {},
                    ),

            );
          },
          childCount: songs.length,
        ),
      ),
    );
  }
}
