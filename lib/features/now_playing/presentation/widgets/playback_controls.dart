import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';

class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onShuffle;
  final VoidCallback? onRepeat;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onSeekForward;
  final bool isShuffleEnabled;
  final bool isRepeatEnabled;

  const PlaybackControls({
    super.key,
    this.isPlaying = false,
    this.onPrevious,
    this.onPlayPause,
    this.onNext,
    this.onShuffle,
    this.onRepeat,
    this.onSeekBackward,
    this.onSeekForward,
    this.isShuffleEnabled = false,
    this.isRepeatEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(
              icon: Icons.replay_10,
              onTap: onSeekBackward,
              size: 32.w,
              iconSize: 18.w,
            ),
            SizedBox(width: AppSpacing.md),
            _ControlButton(
              icon: Icons.skip_previous,
              onTap: onPrevious,
              size: 40.w,
              iconSize: 24.w,
            ),
            SizedBox(width: AppSpacing.md),
            _PlayPauseButton(
              isPlaying: isPlaying,
              onTap: onPlayPause,
            ),
            SizedBox(width: AppSpacing.md),
            _ControlButton(
              icon: Icons.skip_next,
              onTap: onNext,
              size: 40.w,
              iconSize: 24.w,
            ),
            SizedBox(width: AppSpacing.md),
            _ControlButton(
              icon: Icons.forward_10,
              onTap: onSeekForward,
              size: 32.w,
              iconSize: 18.w,
            ),
          ],
        ),
      
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppColors.background,
            size: 36.w,
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const _ControlButton({
    required this.icon,
    this.onTap,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.35 : 1.0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.card,
          ),
          child: Center(
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

