import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:podwave/features/library/data/models/song_model.dart';

const int _kNotificationId = 888;
const String _kChannelId = 'podwave_media';
const String _kChannelName = 'PodWave';

const String _kActionRewind = 'REWIND';
const String _kActionStop = 'STOP';
const String _kActionForward = 'FORWARD';

@pragma('vm:entry-point')
void _notificationTapBackground(NotificationResponse response) {
  _handleAction(response.actionId);
}

void _handleAction(String? actionId) {
  switch (actionId) {
    case _kActionRewind:
      MediaNotificationService.instance._onRewind?.call();
      break;
    case _kActionStop:
      MediaNotificationService.instance._onStop?.call();
      break;
    case _kActionForward:
      MediaNotificationService.instance._onForward?.call();
      break;
  }
}

class MediaNotificationService {
  MediaNotificationService._();
  static final MediaNotificationService instance = MediaNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  VoidCallback? _onRewind;
  VoidCallback? _onStop;
  VoidCallback? _onForward;

  Future<void> initialize({
    required VoidCallback onRewind,
    required VoidCallback onStop,
    required VoidCallback onForward,
  }) async {
    _onRewind = onRewind;
    _onStop = onStop;
    _onForward = onForward;

    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) => _handleAction(response.actionId),
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> show(SongModel song, {required bool isPlaying}) async {
    final androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: 'Music playback controls',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true,
      silent: true,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      styleInformation: const MediaStyleInformation(),
      actions: [
        AndroidNotificationAction(
          _kActionRewind,
          'Rewind 10s',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_notification_rewind'),
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          _kActionStop,
          'Stop',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_notification_stop'),
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          _kActionForward,
          'Forward 10s',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_notification_forward'),
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    await _plugin.show(
      id: _kNotificationId,
      title: song.title,
      body: song.artist,
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancel() async {
    await _plugin.cancel(id: _kNotificationId);
  }
}
