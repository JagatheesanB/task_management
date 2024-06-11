import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedLocaleNotifier extends StateNotifier<Locale> {
  SelectedLocaleNotifier() : super(const Locale('en'));

  void changeLocale(Locale newLocale) {
    state = newLocale;
  }
}

final selectedLocaleProvider =
    StateNotifierProvider<SelectedLocaleNotifier, Locale>((ref) {
  return SelectedLocaleNotifier();
});
