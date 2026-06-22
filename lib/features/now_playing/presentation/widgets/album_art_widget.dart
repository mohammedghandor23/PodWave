import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';

class AlbumArtWidget extends StatelessWidget {
  final String? coverArtPath;
  final Color accentColor;
  final double size;

  const AlbumArtWidget({
    super.key,
    this.coverArtPath,
    required this.accentColor,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            accentColor.withAlpha(60),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(40),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: coverArtPath != null && File(coverArtPath!).existsSync()
            ? Image.file(
                File(coverArtPath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _AlbumArtPlaceholder(color: accentColor);
                },
              )
            : _AlbumArtPlaceholder(color: accentColor),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withAlpha(80),
            AppColors.card,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          color: AppColors.textPrimary.withAlpha(100),
          size: 80.w,
        ),
      ),
    );
  }
}
