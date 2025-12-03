import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:mobile_device_identifier/mobile_device_identifier.dart';


class DeviceIdService {
  DeviceIdService._();
  static final DeviceIdService _instance = DeviceIdService._();
  factory DeviceIdService() => _instance;

  String? _cached;

  /// Returns the device id, or `null` when unavailable (web / unsupported).
  Future<String?> getDeviceId() async {
    if (_cached != null) return _cached;

    // On web the native plugin is not available — return null early.
    if (kIsWeb) {
      debugPrint('[DeviceID] running on web — device id unavailable');
      return null;
    }

    try {
      final raw = MobileDeviceIdentifier().getDeviceId();
      // Support both synchronous String and Future<String?> results from the plugin.
      final dynamic awaited = raw is Future ? await raw : raw;
      final String? id = (awaited is String) ? awaited : (awaited?.toString());
      _cached = id;
      debugPrint('[DeviceID] $id'); // Logged once.
      return id;
    } on MissingPluginException catch (e) {
      // Plugin not implemented on this platform or not registered (hot-reload issue).
      debugPrint('[DeviceID] MissingPluginException: $e');
      return null;
    } catch (e) {
      debugPrint('[DeviceID] Error getting device id: $e');
      return null;
    }
  }
}

// Optional convenience top-level function.
Future<String?> fetchDeviceId() => DeviceIdService().getDeviceId();