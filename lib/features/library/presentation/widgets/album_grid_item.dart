import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/library/data/models/album_model.dart';

class AlbumGridItem extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback? onTap;

  const AlbumGridItem({
    super.key,
    required this.album,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    album.accentColor,
                    album.accentColor.withAlpha(80),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: album.accentColor.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (album.coverArtPath != null && File(album.coverArtPath!).existsSync())
                      Image.file(
                        File(album.coverArtPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _AlbumArtPlaceholder(color: album.accentColor);
                        },
                      )
                    else
                      _AlbumArtPlaceholder(color: album.accentColor),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            album.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            album.artist,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AlbumArtPlaceholder extends StatelessWidget {
  final Color color;

  const _AlbumArtPlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      child: Center(
        child: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.disabled.withAlpha(100),
            border: Border.all(
              color: AppColors.disabled,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.album,
              color: AppColors.disabled,
              size: 24.w,
            ),
          ),
        ),
      ),
    );
  }
}
