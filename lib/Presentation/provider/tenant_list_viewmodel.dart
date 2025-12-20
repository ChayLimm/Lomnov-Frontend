import 'package:flutter/material.dart';
import 'package:app/domain/models/contract/tenant_model.dart';
import 'package:app/data/dto/tenant_mapper.dart';
import 'package:app/data/services/tenant_service.dart';

class TenantListViewModel extends ChangeNotifier {
  final int landlordId;
  List<TenantModel> tenants = [];
  int currentPage = 1;
  int perPage = 15;
  int total = 0;
  int lastPage = 1;
  bool isLoading = false;
  String? error;

  TenantListViewModel({required this.landlordId});

  Future<void> fetchTenants({int page = 1}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final service = TenantService();
      final result = await service.fetchTenants(landlordId, page: page, perPage: perPage);
      tenants = result.items.map(TenantMapper.fromDto).toList();
      currentPage = result.pagination.currentPage;
      perPage = result.pagination.perPage;
      total = result.pagination.total;
      lastPage = result.pagination.lastPage;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
