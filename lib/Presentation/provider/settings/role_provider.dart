import 'package:flutter/foundation.dart';
import 'package:app/data/services/settings/roles_service.dart';
import 'package:app/data/dto/role_dto.dart';
import 'package:app/domain/models/settings/role_model.dart';

class RoleState extends ChangeNotifier {
  RoleState({RolesService? service}) : _service = service ?? RolesService();

  final RolesService _service;

  bool _loading = false;
  String? _error;
  List<RoleModel> _items = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<RoleModel> get items => _items;

  Future<void> load() async {
    _setLoading(true);
    _error = null;
    try {
      final List<RoleDto> dtos = await _service.fetchAll();
      _items = dtos.map((d) => d.toDomain()).toList(growable: false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> add(String roleName) async {
    _setLoading(true);
    try {
      final dto = await _service.store(roleName);
      _items = [dto.toDomain(), ..._items];
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> update(RoleModel m, String roleName) async {
    _setLoading(true);
    try {
      final dto = await _service.update(m.id, roleName);
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