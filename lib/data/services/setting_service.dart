import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/dto/setting_dto.dart';
import 'dart:convert';
import 'package:app/data/services/buildings_service/api_base.dart';

abstract class SettingService {
  Future<SettingDto> fetchSettings(int userId);
  Future<SettingDto> createSettings(Map<String, dynamic> data);
  Future<SettingDto> updateSettings(int userId, Map<String, dynamic> data);
  Future<void> deleteSettings(int userId);
}

class ApiSettingService extends ApiBase implements SettingService {
  @override
  Future<SettingDto> fetchSettings(int userId) async {
    final uri = buildUri(Endpoints.userSettings(userId)); // Use user-specific endpoint
    final headers = await buildHeaders();
    headers['Content-Type'] = 'application/json';

    final res = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );
    
    final dynamic decoded = HttpErrorHandler.handleResponse(
      res,
      'Failed to load settings',
    );
    
    final Map<String, dynamic> jsonMap = decoded is Map<String, dynamic>
        ? decoded
        : (res.body.isNotEmpty ? json.decode(res.body) as Map<String, dynamic> : {});
    
    return SettingDto.fromJson(jsonMap);
  }

  @override
  Future<SettingDto> updateSettings(int userId, Map<String, dynamic> data) async {
    // The user-specific endpoint (`/api/settings/user/:id/`) typically
    // supports GET only. To update the settings resource we must target
    // the settings resource by its numeric id (e.g. `/api/settings/{id}`).
    // Fetch the current settings for the user to obtain the resource id.
    final current = await fetchSettings(userId);
    final uri = buildUri(Endpoints.settingById(current.id));
    final headers = await buildHeaders();
    headers['Content-Type'] = 'application/json';

    // Try PUT first (common for full updates).
    var res = await HttpErrorHandler.executeRequest(
      () => httpClient.put(uri, headers: headers, body: json.encode(data)),
    );

    // If server returns 405 Method Not Allowed, retry using POST with
    // X-HTTP-Method-Override: PATCH which some proxies/backends accept.
    if (res.statusCode == 405) {
      final overrideHeaders = Map<String, String>.from(headers);
      overrideHeaders['X-HTTP-Method-Override'] = 'PATCH';
      res = await HttpErrorHandler.executeRequest(
        () => httpClient.post(uri, headers: overrideHeaders, body: json.encode(data)),
      );
    }

    final dynamic decoded = HttpErrorHandler.handleResponse(
      res,
      'Failed to update settings',
    );
    
    final Map<String, dynamic> jsonMap = decoded is Map<String, dynamic>
        ? decoded
        : (res.body.isNotEmpty ? json.decode(res.body) as Map<String, dynamic> : {});
    
    return SettingDto.fromJson(jsonMap);
  }

  @override
  Future<SettingDto> createSettings(Map<String, dynamic> data) async {
    final uri = buildUri(Endpoints.settings);
    final headers = await buildHeaders();
    headers['Content-Type'] = 'application/json';

    final res = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: json.encode(data)),
    );

    final dynamic decoded = HttpErrorHandler.handleResponse(
      res,
      'Failed to create settings',
    );

    final Map<String, dynamic> jsonMap = decoded is Map<String, dynamic>
        ? decoded
        : (res.body.isNotEmpty ? json.decode(res.body) as Map<String, dynamic> : {});

    return SettingDto.fromJson(jsonMap);
  }

  @override
  Future<void> deleteSettings(int userId) async {
    // Delete the settings resource by id. The user-specific route may only
    // support GET/HEAD, so fetch the settings first to get the resource id.
    final current = await fetchSettings(userId);
    final uri = buildUri(Endpoints.settingById(current.id));
    final headers = await buildHeaders();
    headers['Content-Type'] = 'application/json';

    final res = await HttpErrorHandler.executeRequest(
      () => httpClient.delete(uri, headers: headers),
    );

    HttpErrorHandler.handleResponse(res, 'Failed to delete settings');
  }
}