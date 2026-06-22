import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

class MiniPlayer extends StatelessWidget {
  final SongModel? currentSong;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onTap;

  const MiniPlayer({
    super.key,
    this.currentSong,
    this.isPlaying = false,
    this.onPlayPause,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              currentSong!.accentColor ?? AppColors.tertiary,
                              (currentSong!.accentColor ?? AppColors.tertiary).withAlpha(100),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong!.title,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentSong!.artist,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: onPlayPause,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppRadius.lg),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(30),
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.primary,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
