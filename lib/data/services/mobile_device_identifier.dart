import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

class DeviceIdService {
  DeviceIdService._();
  static final DeviceIdService _instance = DeviceIdService._();
  factory DeviceIdService() => _instance;

  String? _cached;

  Future<String?> getDeviceId() async {
    // Return cached ID if already fetched
    if (_cached != null && _cached!.isNotEmpty) return _cached;

    // Web does not support native plugins
    if (kIsWeb) {
      debugPrint('[DeviceID] Web platform — device ID unavailable');
      return null;
    }

    try {
      // The plugin *always* returns Future<String?>
      final String? id = await MobileDeviceIdentifier().getDeviceId();
      _cached = id;

      debugPrint('[DeviceID] Device ID: $id');
      return id;
    } on MissingPluginException catch (e) {
      debugPrint('[DeviceID] MissingPluginException: $e');
      return null;
    } catch (e) {
      debugPrint('[DeviceID] Error getting device ID: $e');
      return null;
    }
  }
}

Future<String?> fetchDeviceId() => DeviceIdService().getDeviceId();
