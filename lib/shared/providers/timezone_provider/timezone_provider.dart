import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timezone_provider.g.dart';

@Riverpod(keepAlive: true)
Future<String> currentTimeZone(CurrentTimeZoneRef ref) async {
  try {
    return await FlutterTimezone.getLocalTimezone();
  } catch (e) {
    return 'Asia/Qatar';
  }
}
