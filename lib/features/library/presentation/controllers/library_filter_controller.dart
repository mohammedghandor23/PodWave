import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LibraryFilter {
  recentlyPlayed,
  songs,
  mostPlayed,
  lastAdded,
}

final libraryFilterControllerProvider = StateNotifierProvider<LibraryFilterController, LibraryFilter>(
  (ref) => LibraryFilterController(),
);

class LibraryFilterController extends StateNotifier<LibraryFilter> {
  LibraryFilterController() : super(LibraryFilter.recentlyPlayed);

  void setFilter(LibraryFilter filter) {
    state = filter;
  }
}
