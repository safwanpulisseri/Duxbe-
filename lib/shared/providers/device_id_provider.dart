import 'package:duxbe/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _deviceIdKey = 'device_id';

final deviceIdProvider = StateProvider<String>((ref) {
  final sharedPrefs = ref.watch(sharedPrefsProvider).value;
  if (sharedPrefs == null) return '';

  // Get existing device ID or generate a new one
  var deviceId = sharedPrefs.getString(_deviceIdKey) ?? '';
  if (deviceId.isEmpty) {
    deviceId = const Uuid().v4();
    sharedPrefs.setString(_deviceIdKey, deviceId);
  }

  return deviceId;
});
