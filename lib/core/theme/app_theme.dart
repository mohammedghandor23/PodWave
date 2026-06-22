import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:podwave/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          tertiary: AppColors.tertiary,
          surface: AppColors.surface,
          onPrimary: AppColors.background,
          onSecondary: AppColors.background,
          onError: AppColors.background,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: AppColors.border),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.disabled,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.surface,
          contentTextStyle: TextStyle(color: AppColors.textPrimary),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.border,
          thumbColor: AppColors.primary,
          overlayColor: Color(0x1ABB86FC),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.disabled;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary.withAlpha(77);
            }
            return AppColors.border;
          }),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          tertiary: AppColors.tertiary,
          error: AppColors.error,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1A1A1A),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
        ),
      );
}
