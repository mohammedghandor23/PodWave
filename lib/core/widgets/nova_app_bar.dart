import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/l10n/app_localizations.dart';

class NovaAppBar extends StatelessWidget {
  const NovaAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.appName,
              style: AppTextStyles.headlineSmall,
            ),
            
          ],
        ),
      ),
    );
  }
}
