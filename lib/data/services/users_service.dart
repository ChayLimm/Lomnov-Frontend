import 'dart:developer' as dev;
import 'dart:convert';
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/dto/bakong_account_dto.dart';

class UsersService extends ApiBase {
  Future<List<BakongAccountDto>> fetchBakongAccounts(int userId) async {
    final uri = buildUri('${Endpoints.users}/$userId');
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');

    final response = await HttpErrorHandler.executeRequest(() => httpClient.get(uri, headers: headers));

    final decoded = HttpErrorHandler.handleResponse(response, 'Failed to load user');

    List<dynamic>? list;
    if (decoded is Map<String, dynamic>) {
      if (decoded['bakong_accounts'] is List) {
        list = decoded['bakong_accounts'] as List;
      } else if (decoded['data'] is Map<String, dynamic> && decoded['data']['bakong_accounts'] is List) {
        list = decoded['data']['bakong_accounts'] as List;
      }
    } else if (decoded is List) {
      list = decoded;
    }

    list ??= const [];

    return BakongAccountDto.fromJsonList(list);
  }
}
