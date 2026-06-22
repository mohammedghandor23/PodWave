import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/library/presentation/controllers/library_filter_controller.dart';
import 'package:podwave/l10n/app_localizations.dart';

class LibraryFilterChips extends ConsumerWidget {
  const LibraryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentFilter = ref.watch(libraryFilterControllerProvider);

    final filters = [
      (LibraryFilter.recentlyPlayed, l10n.recentlyPlayed),
      (LibraryFilter.songs, l10n.songs),
      (LibraryFilter.mostPlayed, l10n.mostPlayed),
      (LibraryFilter.lastAdded, l10n.recentlyAdded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: filters.map((filter) {
          final isSelected = currentFilter == filter.$1;
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: _FilterChip(
              label: filter.$2,
              isSelected: isSelected,
              onTap: () {
                ref.read(libraryFilterControllerProvider.notifier).setFilter(filter.$1);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
