import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';

class ProgressBar extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final ValueChanged<double>? onSeek;

  const ProgressBar({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    this.onSeek,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress {
    if (totalDuration.inMilliseconds == 0) return 0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4.h,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(20),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 6.w,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 14.w,
            ),
          ),
          child: Slider(
            value: _progress.clamp(0.0, 1.0),
            onChanged: onSeek,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(currentPosition),
                style: AppTextStyles.labelMedium,
              ),
              Text(
                _formatDuration(totalDuration),
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
