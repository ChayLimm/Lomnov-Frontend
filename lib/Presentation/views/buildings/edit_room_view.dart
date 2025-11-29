import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'package:app/data/services/rooms_service/fetch_service.dart';

class EditRoomView extends StatefulWidget {
  final dynamic room; // RoomModel or Map
  const EditRoomView({super.key, required this.room});

  @override
  State<EditRoomView> createState() => _EditRoomViewState();
}

class _EditRoomViewState extends State<EditRoomView> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberCtrl = TextEditingController();
  final _roomTypeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  bool _submitting = false;
  late int _roomId;
  late int _buildingId;

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    if (r is Map<String, dynamic>) {
      _roomId = (r['id'] ?? r['room_id'] ?? r['roomId']) is int
          ? (r['id'] ?? r['room_id'] ?? r['roomId']) as int
          : int.tryParse((r['id'] ?? r['room_id'] ?? r['roomId']).toString()) ?? 0;
      _buildingId = (r['building_id'] ?? r['buildingId'] ?? r['building']?['id']) is int
          ? (r['building_id'] ?? r['buildingId'] ?? r['building']?['id']) as int
          : int.tryParse((r['building_id'] ?? r['buildingId'] ?? r['building']?['id']).toString()) ?? 0;
      _roomTypeCtrl.text = (r['room_type_id'] ?? r['roomTypeId'] ?? r['room_type']?['id'])?.toString() ?? '';
      _roomNumberCtrl.text = (r['room_number'] ?? r['roomNumber'] ?? r['name'])?.toString() ?? '';
      _priceCtrl.text = (r['price'] ?? r['price'] ?? '')?.toString() ?? '';
      _barcodeCtrl.text = (r['barcode'] ?? '')?.toString() ?? '';
      _floorCtrl.text = (r['floor'] ?? '')?.toString() ?? '';
      _statusCtrl.text = (r['status'] ?? '')?.toString() ?? '';
    } else {
      // assume domain model
      _roomId = r.id ?? 0;
      _buildingId = r.buildingId ?? 0;
      _roomTypeCtrl.text = (r.roomTypeId ?? '').toString();
      _roomNumberCtrl.text = (r.roomNumber ?? r.name ?? '').toString();
      _priceCtrl.text = (r.price != null) ? r.price.toString() : '';
      _barcodeCtrl.text = (r.barcode ?? '').toString();
      _floorCtrl.text = (r.floor ?? '').toString();
      _statusCtrl.text = (r.status ?? '').toString();
    }
  }

  @override
  void dispose() {
    _roomNumberCtrl.dispose();
    _roomTypeCtrl.dispose();
    _priceCtrl.dispose();
    _barcodeCtrl.dispose();
    _floorCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final payload = <String, dynamic>{
      'building_id': _buildingId,
      'room_type_id': int.tryParse(_roomTypeCtrl.text.trim()),
      'room_number': _roomNumberCtrl.text.trim(),
      'price': _priceCtrl.text.trim().isEmpty ? null : double.tryParse(_priceCtrl.text.trim()),
      'barcode': _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
      'floor': _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
      'status': _statusCtrl.text.trim().isEmpty ? null : _statusCtrl.text.trim(),
    };

    try {
      final svc = RoomFetchService();
      final updated = await svc.updateRoom(_roomId, payload);
      dev.log('[Rooms] updated room id=${updated.id}');
      if (!mounted) return;
      Get.back(result: true);
      Get.snackbar('Updated', 'Room updated');
    } catch (e) {
      dev.log('[Rooms] update failed: $e');
      if (mounted) Get.snackbar('Error', 'Failed to update room: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _roomTypeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Room Type ID'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (int.tryParse(v.trim()) == null) return 'Must be an integer';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _roomNumberCtrl,
                  decoration: const InputDecoration(labelText: 'Room Number'),
                  maxLength: 50,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim().length > 50) return 'Max 50 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null) return 'Invalid number';
                    if (parsed < 0) return 'Must be >= 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _barcodeCtrl,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                  maxLength: 255,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _floorCtrl,
                  decoration: const InputDecoration(labelText: 'Floor'),
                  maxLength: 50,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _statusCtrl,
                  decoration: const InputDecoration(labelText: 'Status'),
                  maxLength: 50,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
