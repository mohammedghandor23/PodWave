import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podwave/core/constants/app_radius.dart';
import 'package:podwave/core/constants/app_spacing.dart';
import 'package:podwave/core/theme/app_colors.dart';
import 'package:podwave/core/theme/app_text_styles.dart';
import 'package:podwave/features/library/data/models/song_model.dart';
import 'package:podwave/features/library/presentation/controllers/library_controller.dart';
import 'package:podwave/features/playlists/presentation/controllers/playlist_controller.dart';
import 'package:podwave/l10n/app_localizations.dart';

class AddSongsScreen extends ConsumerStatefulWidget {
  final String playlistId;
  final List<String> existingSongIds;

  const AddSongsScreen({
    super.key,
    required this.playlistId,
    required this.existingSongIds,
  });

  @override
  ConsumerState<AddSongsScreen> createState() => _AddSongsScreenState();
}

class _AddSongsScreenState extends ConsumerState<AddSongsScreen> {
  final Set<String> _selected = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.existingSongIds);
  }

  List<SongModel> _filteredSongs(List<SongModel> songs) {
    if (_searchQuery.isEmpty) return songs;
    final q = _searchQuery.toLowerCase();
    return songs.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.artist.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _confirm(BuildContext context) async {
    final newIds = _selected
        .where((id) => !widget.existingSongIds.contains(id))
        .toList();
    if (newIds.isNotEmpty) {
      await ref
          .read(playlistControllerProvider.notifier)
          .addSongsToPlaylist(widget.playlistId, newIds);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final libraryState = ref.watch(libraryControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(l10n.addSongs, style: AppTextStyles.titleMedium),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary, size: 24.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => _confirm(context),
            child: Text(
              l10n.done,
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            onChanged: (q) => setState(() => _searchQuery = q),
          ),
          Expanded(
            child: libraryState.when(
              data: (songs) {
                final filtered = _filteredSongs(songs);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noSongsFound,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final song = filtered[index];
                    final isSelected = _selected.contains(song.id);
                    return _SongPickerItem(
                      song: song,
                      isSelected: isSelected,
                      onToggle: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(song.id);
                          } else {
                            _selected.add(song.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text(
                  '${l10n.error}: $e',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchInLibrary,
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SongPickerItem extends StatelessWidget {
  final SongModel song;
  final bool isSelected;
  final VoidCallback onToggle;

  const _SongPickerItem({
    required this.song,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    song.accentColor ?? AppColors.primary,
                    (song.accentColor ?? AppColors.primary).withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20.w,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artist,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.disabled,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
