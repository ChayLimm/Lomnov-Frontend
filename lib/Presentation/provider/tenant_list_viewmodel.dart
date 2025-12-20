import 'package:flutter/material.dart';
import 'package:app/domain/models/contract/tenant_model.dart';
import 'package:app/data/dto/tenant_mapper.dart';
import 'package:app/data/services/tenant_service.dart';

class TenantListViewModel extends ChangeNotifier {
  final int landlordId;
  List<TenantModel> tenants = [];
  bool isLoading = false;
  String? error;

  TenantListViewModel({required this.landlordId});

  Future<void> fetchTenants() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final service = TenantService();
      final dtos = await service.fetchTenants(landlordId);
      tenants = dtos.map(TenantMapper.fromDto).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
