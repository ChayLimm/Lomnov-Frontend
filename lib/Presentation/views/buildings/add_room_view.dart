import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'package:app/data/services/rooms_service/fetch_service.dart';

class AddRoomView extends StatefulWidget {
  final int buildingId;
  const AddRoomView({super.key, required this.buildingId});

  @override
  State<AddRoomView> createState() => _AddRoomViewState();
}

class _AddRoomViewState extends State<AddRoomView> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberCtrl = TextEditingController();
  final _roomTypeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  bool _submitting = false;

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
      'building_id': widget.buildingId,
      'room_type_id': int.tryParse(_roomTypeCtrl.text.trim()),
      'room_number': _roomNumberCtrl.text.trim(),
      'price': _priceCtrl.text.trim().isEmpty ? null : double.tryParse(_priceCtrl.text.trim()),
      'barcode': _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
      'floor': _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
      'status': _statusCtrl.text.trim().isEmpty ? null : _statusCtrl.text.trim(),
    };

    try {
      final svc = RoomFetchService();
      final created = await svc.createRoom(payload);
      dev.log('[Rooms] created room id=${created.id}');
      if (!mounted) return;
      Get.back(result: true);
      Get.snackbar('Created', 'Room created');
    } catch (e) {
      dev.log('[Rooms] create failed: $e');
      if (mounted) Get.snackbar('Error', 'Failed to create room: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Room')),
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
                        : const Text('Create'),
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
