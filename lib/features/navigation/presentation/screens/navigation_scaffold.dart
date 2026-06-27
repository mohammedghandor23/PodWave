import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/widgets/mini_player_bar.dart';
import 'package:podwave/features/library/presentation/screens/library_screen.dart';
import 'package:podwave/features/playlists/presentation/screens/playlists_screen.dart';
import 'package:podwave/features/navigation/presentation/controllers/navigation_controller.dart';
import 'package:podwave/features/settings/presentation/screens/settings_screen.dart';
import 'package:podwave/l10n/app_localizations.dart';

class NavigationScaffold extends ConsumerStatefulWidget {
  const NavigationScaffold({super.key});

  @override
  ConsumerState<NavigationScaffold> createState() => _NavigationScaffoldState();
}

class _NavigationScaffoldState extends ConsumerState<NavigationScaffold> {
  late final PersistentTabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = PersistentTabController(initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tabIcons = [
      Icons.queue_music_rounded,
      Icons.library_music_rounded,
      Icons.settings_rounded,
    ];

    final tabs = [
      PersistentTabConfig(
        screen: const PlaylistsScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.queue_music_rounded),
          title: l10n.playlists,
          activeForegroundColor: AppColors.primary,
          inactiveForegroundColor: AppColors.disabled,
        ),
      ),
      PersistentTabConfig(
        screen: const LibraryScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.library_music_rounded),
          title: l10n.library,
          activeForegroundColor: AppColors.primary,
          inactiveForegroundColor: AppColors.disabled,
        ),
      ),
      PersistentTabConfig(
        screen: const SettingsScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.settings_rounded),
          title: l10n.settings,
          activeForegroundColor: AppColors.primary,
          inactiveForegroundColor: AppColors.disabled,
        ),
      ),
    ];

    return Stack(
      children: [
        PersistentTabView(
          tabs: tabs,
          controller: _tabController,
          navBarBuilder: (navBarConfig) => _IconOnlyNavBar(
            navBarConfig: navBarConfig,
            icons: tabIcons,
          ),
          backgroundColor: AppColors.background,
          onTabChanged: (index) {
            final tab = NavigationTab.values[index];
            ref.read(navigationControllerProvider.notifier).navigateToTab(tab, context);
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 80,
          child: const MiniPlayerBar(),
        ),
      ],
    );
  }
}

class _IconOnlyNavBar extends StatelessWidget {
  final NavBarConfig navBarConfig;
  final List<IconData> icons;

  const _IconOnlyNavBar({
    required this.navBarConfig,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navBarConfig.items.length, (index) {
          final isActive = index == navBarConfig.selectedIndex;
          return GestureDetector(
            onTap: () => navBarConfig.onItemSelected(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 56.w,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icons[index],
                    color: isActive ? AppColors.primary : AppColors.disabled,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
