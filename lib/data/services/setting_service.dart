import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/dto/setting_dto.dart';
import 'dart:convert';
import 'package:app/data/services/buildings_service/api_base.dart';

abstract class SettingService {
  Future<SettingDto> fetchSettings(int userId);
  Future<SettingDto> updateSettings(int userId, Map<String, dynamic> data);
}

class ApiSettingService extends ApiBase implements SettingService {
  @override
  Future<SettingDto> fetchSettings(int userId) async {
    final uri = buildUri(Endpoints.userSettings(userId)); // Use user-specific endpoint
    final headers = await buildHeaders();

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
    final uri = buildUri(Endpoints.userSettings(userId)); // Use user-specific endpoint
    final headers = await buildHeaders();

    final res = await HttpErrorHandler.executeRequest(
      () => httpClient.put(uri, headers: headers, body: json.encode(data)),
    );
    
    final dynamic decoded = HttpErrorHandler.handleResponse(
      res,
      'Failed to update settings',
    );
    
    final Map<String, dynamic> jsonMap = decoded is Map<String, dynamic>
        ? decoded
        : (res.body.isNotEmpty ? json.decode(res.body) as Map<String, dynamic> : {});
    
    return SettingDto.fromJson(jsonMap);
  }
}