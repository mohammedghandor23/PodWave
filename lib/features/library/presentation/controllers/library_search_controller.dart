import 'package:flutter_riverpod/flutter_riverpod.dart';

final librarySearchControllerProvider = StateNotifierProvider<LibrarySearchController, String>(
  (ref) => LibrarySearchController(),
);

class LibrarySearchController extends StateNotifier<String> {
  LibrarySearchController() : super('');

  void setSearch(String query) {
    state = query;
  }

  void clearSearch() {
    state = '';
  }
}
