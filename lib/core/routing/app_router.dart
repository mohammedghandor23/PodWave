import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/features/folder_details/presentation/screens/folder_details_screen.dart';
import 'package:podwave/features/navigation/presentation/screens/navigation_scaffold.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/now_playing/presentation/screens/now_playing_screen.dart';
import 'package:podwave/features/playlists/data/models/playlist_model.dart';
import 'package:podwave/features/playlists/presentation/screens/playlist_detail_screen.dart';
import 'package:podwave/features/queue/presentation/screens/queue_screen.dart';
import 'package:podwave/features/splash/presentation/screens/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String library = '/library';
  static const String settings = '/settings';
  static const String playlistDetail = '/playlist-detail';
  static const String nowPlaying = '/now-playing';
  static const String queue = '/queue';
  static const String folderDetails = '/folder-details';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  redirect: (context, state) {
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return const NavigationScaffold();
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRoutes.library,
          name: 'library',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: AppRoutes.playlistDetail,
      name: 'playlist-detail',
      builder: (context, state) => PlaylistDetailScreen(
        playlist: state.extra as PlaylistModel,
      ),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: AppRoutes.nowPlaying,
      name: 'now-playing',
      builder: (context, state) => NowPlayingScreen(song: state.extra as SongModel?),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: AppRoutes.queue,
      name: 'queue',
      builder: (context, state) => const QueueScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '${AppRoutes.folderDetails}/:id',
      name: 'folder-details',
      builder: (context, state) {
        final folderId = state.pathParameters['id']!;
        return FolderDetailsScreen(folderId: folderId);
      },
    ),
  ],
);
