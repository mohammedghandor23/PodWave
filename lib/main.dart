import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/localization/app_localizations.dart';
import 'package:podwave/core/localization/locale_controller.dart';
import 'package:podwave/core/responsive/responsive_config.dart';
import 'package:podwave/core/routing/app_router.dart';
import 'package:podwave/core/audio/audio_player_service.dart';
import 'package:podwave/core/storage/hive_initializer.dart';
import 'package:podwave/core/theme/app_theme.dart';
import 'package:podwave/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveInitializer.initialize();
  await AudioPlayerService().initialize();

  runApp(
    const ProviderScope(
      child: NovaPlayerApp(),
    ),
  );
}

class NovaPlayerApp extends ConsumerWidget {
  const NovaPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);

    return ScreenUtilInit(
      designSize: const Size(
        ResponsiveConfig.designWidth,
        ResponsiveConfig.designHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'PodWave',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          locale: locale,
          supportedLocales: AppLocalizationsDelegate.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: appRouter,
        );
      },
    );
  }
}
