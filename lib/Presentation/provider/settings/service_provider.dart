import 'package:flutter/foundation.dart';
import 'package:app/data/services/settings/services_service.dart';
import 'package:app/data/dto/service_dto.dart';
import 'package:app/domain/models/settings/service_model.dart';

class ServiceState extends ChangeNotifier {
  ServiceState({ServicesService? service}) : _service = service ?? ServicesService();

  final ServicesService _service;

  bool _loading = false;
  String? _error;
  List<ServiceModel> _items = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<ServiceModel> get items => _items;

  Future<void> load({int? landlordId}) async {
    _setLoading(true);
    _error = null;
    try {
      // Prefer landlord-scoped fetch when possible
      final List<ServiceDto> dtos = await _service.fetchByLandlord(landlordId: landlordId);
      _items = dtos.map((d) => d.toDomain()).toList(growable: false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> add(String name, double? unitPrice, String? description) async {
    _setLoading(true);
    try {
      final landlordId = await _service.auth.getLandlordId();
      final payload = {
        'name': name,
        if (unitPrice != null) 'unit_price': unitPrice,
        if (description != null) 'description': description,
        if (landlordId != null) 'landlord_id': landlordId,
      };
      final dto = await _service.store(payload);
      _items = [dto.toDomain(), ..._items];
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> update(ServiceModel m) async {
    _setLoading(true);
    try {
      final landlordId = await _service.auth.getLandlordId();
      final payload = {
        'name': m.name,
        'unit_price': m.unitPrice,
        'description': m.description,
        if (landlordId != null) 'landlord_id': landlordId,
      };
      final dto = await _service.update(m.id, payload);
      _items = _items.map((x) => x.id == m.id ? dto.toDomain() : x).toList(growable: false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> delete(int id) async {
    _setLoading(true);
    try {
      await _service.destroy(id);
      _items = _items.where((x) => x.id != id).toList(growable: false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
