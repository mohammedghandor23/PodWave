abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xSlow = Duration(milliseconds: 800);
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// Interval for saving playback position to persistent storage
  static const Duration positionSaveInterval = Duration(seconds: 10);
}
