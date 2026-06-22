/// ScreenUtil design reference dimensions.
///
/// Based on a standard Android phone reference size (360x800 dp).
/// All responsive values in the app are scaled relative to this baseline.
abstract final class ResponsiveConfig {
  static const double designWidth = 360;
  static const double designHeight = 800;

  /// Minimum text scale factor to prevent overly small text on large screens.
  static const double minTextAdapt = 0.8;

  /// Maximum text scale factor to prevent overly large text on small screens.
  static const double maxTextAdapt = 1.2;
}
