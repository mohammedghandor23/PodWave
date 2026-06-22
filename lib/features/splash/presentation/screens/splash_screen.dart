import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/core/routing/app_router.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/splash/presentation/controllers/splash_notifier.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<SplashStatus>>(splashProvider, (_, next) {
      if (next is AsyncData && next.value == SplashStatus.ready) {
        context.go(AppRoutes.home);
      }
    });

    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _BackgroundGif(),
          _BackgroundOverlay(),
          _SplashContent(),
        ],
      ),
    );
  }
}

class _BackgroundGif extends StatelessWidget {
  const _BackgroundGif();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeIn,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Image.asset(
        'assets/splachBackGround.gif',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _BackgroundOverlay extends StatelessWidget {
  const _BackgroundOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withAlpha(120),
            AppColors.background.withAlpha(200),
            AppColors.background,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedLogo(),
          SizedBox(height: 28.h),
          _AnimatedAppName(),
          SizedBox(height: 10.h),
          _AnimatedTagline(),
          SizedBox(height: 80.h),
          _AnimatedLoader(),
        ],
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeIn,
        builder: (context, opacity, child) {
          return Opacity(opacity: opacity, child: child);
        },
        child: Container(
          width: 110.w,
          height: 110.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(90),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedAppName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 30.0, end: 0.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, offset, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          builder: (context, opacity, _) {
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, offset),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      child: Text(
        'PodWave',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AnimatedTagline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: Text(
        'Your music, offline.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary.withAlpha(200),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AnimatedLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeIn,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: SizedBox(
        width: 28.w,
        height: 28.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary.withAlpha(180),
          ),
        ),
      ),
    );
  }
}
