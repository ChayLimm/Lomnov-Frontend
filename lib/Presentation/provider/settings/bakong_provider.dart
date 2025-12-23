import 'package:flutter/foundation.dart';
import 'package:app/data/services/users_service.dart';
import 'package:app/data/dto/bakong_account_dto.dart';
import 'package:app/domain/models/bakong_account/bakong_account.dart';

class BakongProvider extends ChangeNotifier {
  BakongProvider({UsersService? service}) : _service = service ?? UsersService();

  final UsersService _service;

  bool _loading = false;
  String? _error;
  List<BakongAccount> _items = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<BakongAccount> get items => _items;

  Future<void> load({required int userId}) async {
    _setLoading(true);
    _error = null;
    try {
      final List<BakongAccountDto> dtos = await _service.fetchBakongAccounts(userId);
      _items = dtos.map((d) => d.toDomain()).toList(growable: false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Update an account locally and notify listeners. Network persistence
  /// can be implemented later in [UsersService].
  void updateAccount(int index, BakongAccount updated) {
    if (index < 0 || index >= _items.length) return;
    final newList = List<BakongAccount>.from(_items);
    newList[index] = updated;
    _items = List.unmodifiable(newList);
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
