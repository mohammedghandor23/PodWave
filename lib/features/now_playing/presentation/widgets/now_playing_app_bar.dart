import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/l10n/app_localizations.dart';

class NowPlayingAppBar extends StatelessWidget {
  const NowPlayingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textPrimary,
              size: 28.w,
            ),
          ),
          Text(
            'PLAYING FROM LIBRARY',
            style: AppTextStyles.labelMedium.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 28.w),
        ],
      ),
    );
  }
}
