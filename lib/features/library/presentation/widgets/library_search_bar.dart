import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/library/presentation/controllers/library_search_controller.dart';
import 'package:podwave/l10n/app_localizations.dart';

class LibrarySearchBar extends ConsumerWidget {
  const LibrarySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final searchQuery = ref.watch(librarySearchControllerProvider);
    final controller = TextEditingController(text: searchQuery);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: controller,
          onChanged: (value) {
            ref.read(librarySearchControllerProvider.notifier).setSearch(value);
          },
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: l10n.searchInLibrary,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20.w,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      ref.read(librarySearchControllerProvider.notifier).clearSearch();
                      controller.clear();
                    },
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 18.w,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ),
    );
  }
}
