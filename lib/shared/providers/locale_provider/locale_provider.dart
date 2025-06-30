import 'package:duxbe/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) {
  ref.listenSelf((previous, next) {
    ref.read(sharedPrefsProvider).value?.setString('locale', next.languageCode);
  });
  return Locale(
    ref.watch(sharedPrefsProvider).value?.getString('locale') ?? 'en',
  );
});
