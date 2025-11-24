import 'package:flutter/foundation.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';


class DeviceIdService {
  DeviceIdService._();
  static final DeviceIdService _instance = DeviceIdService._();
  factory DeviceIdService() => _instance;

  String? _cached;

  Future<Object> getDeviceId() async {
    if (_cached != null) return _cached!;
    final raw = MobileDeviceIdentifier().getDeviceId();
    final id = raw is Future<String> ? await raw : raw;
    _cached = id as String?;
    debugPrint('[DeviceID] $id'); // Logged once.
    return id;
  }
}

// Optional convenience top-level function.
Future<Object> fetchDeviceId() => DeviceIdService().getDeviceId();