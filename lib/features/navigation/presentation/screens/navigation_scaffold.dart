import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/widgets/mini_player_bar.dart';
import 'package:podwave/features/home/presentation/screens/home_screen.dart';
import 'package:podwave/features/library/presentation/screens/library_screen.dart';
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
    _tabController = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tabs = [
      PersistentTabConfig(
        screen: const HomeScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.home_rounded, color: AppColors.primary),
          title: l10n.home,
          activeColorSecondary: AppColors.primary.withValues(alpha: 0.2),
          activeForegroundColor: AppColors.primary,
        ),
      ),
      PersistentTabConfig(
        screen: const LibraryScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.library_music_rounded, color: AppColors.primary),
          title: l10n.library,
          activeColorSecondary: AppColors.primary.withValues(alpha: 0.2),
          activeForegroundColor: AppColors.primary,
        ),
      ),
      PersistentTabConfig(
        screen: const SettingsScreen(),
        item: ItemConfig(
          icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
          title: l10n.settings,
          activeColorSecondary: AppColors.primary.withValues(alpha: 0.2),
          activeForegroundColor: AppColors.primary,
        ),
      ),
    ];

    return Stack(
      children: [
        PersistentTabView(
          tabs: tabs,
          controller: _tabController,
          navBarBuilder: (navBarConfig) => Style2BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: NavBarDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
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
          bottom: 50,
          child: const MiniPlayerBar(),
        ),
      ],
    );
  }
}
