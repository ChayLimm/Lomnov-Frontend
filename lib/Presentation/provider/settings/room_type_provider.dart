import 'package:flutter/foundation.dart';
import 'package:app/data/services/settings/room_types_service.dart';
import 'package:app/data/dto/room_type_dto.dart';
import 'package:app/domain/models/settings/room_type_model.dart';

class RoomTypeState extends ChangeNotifier {
  RoomTypeState({RoomTypesService? service}) : _service = service ?? RoomTypesService();

  final RoomTypesService _service;

  bool _loading = false;
  String? _error;
  List<RoomTypeModel> _items = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<RoomTypeModel> get items => _items;

  Future<void> load() async {
    _setLoading(true);
    _error = null;
    try {
      final List<RoomTypeDto> dtos = await _service.fetchAll();
      _items = dtos.map((d) => d.toDomain()).toList(growable: false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> add(String roomTypeName, String? description) async {
    _setLoading(true);
    try {
      final landlordId = await _service.auth.getLandlordId();
      final payload = {
        'room_type_name': roomTypeName,
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

  Future<void> update(RoomTypeModel m) async {
    _setLoading(true);
    try {
      final landlordId = await _service.auth.getLandlordId();
      final payload = {
        'room_type_name': m.roomTypeName,
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
