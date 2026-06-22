import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum NavigationTab { home, library, settings }

extension NavigationTabX on NavigationTab {
  String get path => switch (this) {
    NavigationTab.home => '/home',
    NavigationTab.library => '/library',
    NavigationTab.settings => '/settings',
  };
}

final navigationControllerProvider = StateNotifierProvider<NavigationController, NavigationTab>((ref) {
  return NavigationController();
});

class NavigationController extends StateNotifier<NavigationTab> {
  NavigationController() : super(NavigationTab.home);

  void navigateToTab(NavigationTab tab, BuildContext context) {
    if (state == tab) return;
    state = tab;
    context.go(tab.path);
  }

  void syncWithLocation(String location) {
    final tab = NavigationTab.values.firstWhere(
      (t) => location.startsWith(t.path),
      orElse: () => NavigationTab.home,
    );
    state = tab;
  }
}
