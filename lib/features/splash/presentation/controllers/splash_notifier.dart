import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SplashStatus { loading, ready }

class SplashNotifier extends AsyncNotifier<SplashStatus> {
  @override
  Future<SplashStatus> build() async {
    await _initialize();
    return SplashStatus.ready;
  }

  Future<void> _initialize() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);
  }
}

final splashProvider =
    AsyncNotifierProvider<SplashNotifier, SplashStatus>(SplashNotifier.new);
