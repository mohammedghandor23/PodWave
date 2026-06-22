import 'package:flutter/material.dart';
import 'package:podwave/core/constants/app_durations.dart';

class AnimatedTabSwitcher extends StatelessWidget {
  final Widget child;
  final int tabIndex;

  const AnimatedTabSwitcher({
    super.key,
    required this.child,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.normal,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(tabIndex),
        child: child,
      ),
    );
  }
}
