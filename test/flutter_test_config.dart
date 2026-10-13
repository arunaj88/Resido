import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the app's bundled fonts so layout tests measure real text widths
/// instead of the square-glyph test font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await _loadFamily('Inter', [
    'assets/fonts/Inter-400.ttf',
    'assets/fonts/Inter-500.ttf',
    'assets/fonts/Inter-600.ttf',
    'assets/fonts/Inter-700.ttf',
  ]);
  await _loadFamily('InterExt', [
    'assets/fonts/InterExt-400.ttf',
    'assets/fonts/InterExt-500.ttf',
    'assets/fonts/InterExt-600.ttf',
    'assets/fonts/InterExt-700.ttf',
  ]);
  await _loadFamily('PlusJakartaSans', [
    'assets/fonts/PlusJakartaSans-600.ttf',
    'assets/fonts/PlusJakartaSans-700.ttf',
  ]);
  await testMain();
}

Future<void> _loadFamily(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
