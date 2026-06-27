import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/l10n/app_localizations.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podwave/core/routing/app_router.dart';
import 'package:podwave/core/widgets/nova_app_bar.dart';
import 'package:podwave/core/widgets/song_list_item.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/core/widgets/resume_dialog.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/now_playing/presentation/controllers/audio_controller.dart';
import 'package:podwave/features/library/presentation/controllers/library_controller.dart';
import 'package:podwave/features/settings/presentation/controllers/settings_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryControllerProvider.notifier).loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final libraryState = ref.watch(libraryControllerProvider);

    void navigateToNowPlaying(SongModel song, List<SongModel> allSongs) async {
      final audioController = ref.read(audioControllerProvider.notifier);
      final settings = ref.read(settingsControllerProvider);

      // Check for saved position
      final savedPosition = audioController.getSavedPosition(song.id);
      Duration? startPosition;

      if (savedPosition != null && savedPosition.inSeconds > 10) {
        if (settings.resumeMode == ResumeMode.auto) {
          startPosition = savedPosition;
        } else {
          final shouldResume = await showResumeDialog(context, savedPosition);
          if (!context.mounted) return;
          if (shouldResume) {
            startPosition = savedPosition;
          }
        }
      }

      final queueIndex = allSongs.indexWhere((s) => s.id == song.id);
      unawaited(audioController.playSong(
        song,
        startPosition: startPosition,
        queue: allSongs,
        queueIndex: queueIndex >= 0 ? queueIndex : 0,
      ));
      if (!context.mounted) return;
      ref.read(libraryControllerProvider.notifier).updatePlayStats(song.id);
      context.push(AppRoutes.nowPlaying, extra: song);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(libraryControllerProvider.notifier).refreshLibrary();
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            slivers: [
              NovaAppBar(title: l10n.home),
              libraryState.when(
                data: (songs) => _HomeContent(
                  songs: songs,
                  onSongTap: (song) => navigateToNowPlaying(song, songs),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      '${l10n.error}: $error',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        title,
        style: AppTextStyles.titleLarge,
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final List<SongModel> songs;
  final Function(SongModel)? onSongTap;

  const _HomeContent({
    required this.songs,
    this.onSongTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: l10n.recentlyPlayed),
          SizedBox(height: AppSpacing.sm),
          _RecentlyPlayedSection(
            songs: songs,
            onSongTap: onSongTap,
          ),
          SizedBox(height: AppSpacing.xl),
          _SectionTitle(title: l10n.recentlyAdded),
          SizedBox(height: AppSpacing.sm),
          _RecentlyAddedSection(
            songs: songs,
            onSongTap: onSongTap,
          ),
          SizedBox(height: AppSpacing.xl),
          _SectionTitle(title: l10n.songs),
          SizedBox(height: AppSpacing.sm),
          _AllSongsSection(
            songs: songs,
            onSongTap: onSongTap,
          ),
        ],
      ),
    );
  }
}

class _RecentlyPlayedSection extends StatelessWidget {
  final List<SongModel> songs;
  final Function(SongModel)? onSongTap;

  const _RecentlyPlayedSection({
    required this.songs,
    this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (songs.isEmpty) {
      return _EmptySection(message: l10n.noSongsFound);
    }

    final displaySongs = songs.take(10).toList();

    return SizedBox(
      height: 210.w,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: displaySongs.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final song = displaySongs[index];
          return _AlbumCard(
            title: song.title,
            artist: song.artist,
            color: _getGradientColor(index),
            onTap: () => onSongTap?.call(song),
          );
        },
      ),
    );
  }

  Color _getGradientColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.primary.withAlpha(200),
      AppColors.secondary.withAlpha(200),
    ];
    return colors[index % colors.length];
  }
}

class _RecentlyAddedSection extends StatelessWidget {
  final List<SongModel> songs;
  final Function(SongModel)? onSongTap;

  const _RecentlyAddedSection({
    required this.songs,
    this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (songs.isEmpty) {
      return _EmptySection(message: l10n.noSongsFound);
    }

    final sortedSongs = List<SongModel>.from(songs)
      ..sort((a, b) => (b.dateAdded ?? DateTime(0)).compareTo(a.dateAdded ?? DateTime(0)));
    final displaySongs = sortedSongs.take(10).toList();

    return SizedBox(
      height: 170.w,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: displaySongs.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final song = displaySongs[index];
          return _AlbumCard(
            title: song.title,
            artist: song.artist,
            color: _getGradientColor(index),
            isCompact: true,
            onTap: () => onSongTap?.call(song),
          );
        },
      ),
    );
  }

  Color _getGradientColor(int index) {
    final colors = [
      AppColors.tertiary,
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary.withAlpha(200),
    ];
    return colors[index % colors.length];
  }
}

class _AlbumCard extends StatelessWidget {
  final String title;
  final String artist;
  final Color color;
  final bool isCompact;
  final VoidCallback? onTap;

  const _AlbumCard({
    required this.title,
    required this.artist,
    required this.color,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = isCompact ? 130.w : 150.w;
    final height = isCompact ? 120.w : 150.w;

    return GestureDetector(
      onTap: onTap,
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withAlpha(100),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WavePainter(color: Colors.white.withAlpha(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: width,
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: width,
          child: Text(
            artist,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
        ),
      ),
    );
  }
}

class _AllSongsSection extends StatelessWidget {
  final List<SongModel> songs;
  final Function(SongModel)? onSongTap;

  const _AllSongsSection({
    required this.songs,
    this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (songs.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            l10n.noSongsFound,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final displaySongs = songs.take(20).toList();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displaySongs.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final song = displaySongs[index];
        return SongListItem(
          song: song,
          onTap: () => onSongTap?.call(song),
        );
      },
    );
  }
}


class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.w,
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;

    for (var i = 0; i < 3; i++) {
      path.moveTo(0, height * 0.3 + i * 20);
      for (var x = 0; x < width; x += 10) {
        final y = height * 0.3 +
            i * 20 +
            10 * math.sin((x + i * 30) * 0.05);
        path.lineTo(x.toDouble(), y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
