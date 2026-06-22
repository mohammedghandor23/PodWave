import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

class SongListItem extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const SongListItem({
    super.key,
    required this.song,
    this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    song.accentColor ?? AppColors.primary,
                    (song.accentColor ?? AppColors.primary).withAlpha(100),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.music_note,
                  color: Colors.white.withAlpha(200),
                  size: 24.w,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    song.artist,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onMorePressed,
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 20.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
