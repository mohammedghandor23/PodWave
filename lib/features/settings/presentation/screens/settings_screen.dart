import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/localization/locale_controller.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/core/widgets/nova_app_bar.dart';
import 'package:podwave/features/settings/presentation/controllers/settings_controller.dart';
import 'package:podwave/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            NovaAppBar(title: l10n.settings),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settings,
                      style: AppTextStyles.headlineSmall,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.customizeYourAuditoryExperience,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    _PlaybackSection(),
                    SizedBox(height: AppSpacing.xl),
                    _SystemSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaybackSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.playback,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.play_arrow_rounded,
                title: l10n.resumePlayback,
                subtitle: settings.resumeMode == ResumeMode.auto
                    ? l10n.resumeModeAuto
                    : l10n.resumeModePrompt,
                onTap: () => _showResumeModeSelector(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showResumeModeSelector(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(settingsControllerProvider.notifier);
    final currentMode = ref.read(settingsControllerProvider).resumeMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.disabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.resumePlayback,
                  style: AppTextStyles.titleLarge,
                ),
                SizedBox(height: AppSpacing.xl),
                _ResumeModeOption(
                  title: l10n.resumeModePrompt,
                  subtitle: l10n.resumeModePromptDesc,
                  isSelected: currentMode == ResumeMode.prompt,
                  onTap: () {
                    controller.setResumeMode(ResumeMode.prompt);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: AppSpacing.sm),
                _ResumeModeOption(
                  title: l10n.resumeModeAuto,
                  subtitle: l10n.resumeModeAutoDesc,
                  isSelected: currentMode == ResumeMode.auto,
                  onTap: () {
                    controller.setResumeMode(ResumeMode.auto);
                    Navigator.pop(context);
                  },
                ),
                 SizedBox(height: 74.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SystemSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.system,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _LanguageSelector(
                currentLocale: currentLocale,
                onLanguageSelected: (locale) {
                  ref.read(localeControllerProvider.notifier).setLocale(locale);
                },
              ),
              Divider(
                color: AppColors.border,
                height: 1,
                indent: AppSpacing.xxl,
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: l10n.appVersion,
                subtitle: 'PodWave v1.1.0',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) onLanguageSelected;

  const _LanguageSelector({
    required this.currentLocale,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SettingsTile(
      icon: Icons.language_rounded,
      title: l10n.language,
      subtitle: currentLocale.languageCode == 'ar' ? l10n.arabic : l10n.english,
      onTap: () => _showLanguageSelector(context),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.disabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.language,
                  style: AppTextStyles.titleLarge,
                ),
                SizedBox(height: AppSpacing.xl),
                _LanguageOption(
                  title: l10n.english,
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () {
                    onLanguageSelected(const Locale('en'));
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: AppSpacing.sm),
                _LanguageOption(
                  title: l10n.arabic,
                  isSelected: currentLocale.languageCode == 'ar',
                  onTap: () {
                    onLanguageSelected(const Locale('ar'));
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 20.w,
              ),
          ],
        ),
      ),
    );
  }
}

class _ResumeModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ResumeModeOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 20.w,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20.w,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

