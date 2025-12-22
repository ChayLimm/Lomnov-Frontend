// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/domain/models/home_model/notification_model.dart';
import 'package:app/data/services/buildings/fetch_service.dart';
import 'package:app/data/services/rooms_service/fetch_service.dart';
import 'package:app/data/dto/building_dto.dart';
import 'package:app/data/dto/room_dto.dart';
import 'package:app/data/services/notifications/notification_service.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/widgets/gradient_button.dart';
import 'package:app/Presentation/widgets/confirm_action_dialog.dart';

class RegistrationDetail extends StatefulWidget {
  final AppNotification notification;

  const RegistrationDetail({super.key, required this.notification});

  @override
  State<RegistrationDetail> createState() => _RegistrationDetailState();
}

class _RegistrationDetailState extends State<RegistrationDetail> {
  final _buildingSvc = BuildingFetchService();
  final _roomSvc = RoomFetchService();
  final _notifSvc = NotificationService();

  List<BuildingDto> _buildings = [];
  List<RoomDto> _rooms = [];
  BuildingDto? _selectedBuilding;
  RoomDto? _selectedRoom;
  final _depositCtrl = TextEditingController();
  DateTime? _startDate;
  bool _loading = false;

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryColor) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    try {
      final list = await _buildingSvc.fetchBuildingsForLandlord();
      setState(() => _buildings = list);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _onBuildingChanged(BuildingDto? b) async {
    setState(() {
      _selectedBuilding = b;
      _rooms = [];
      _selectedRoom = null;
    });
    if (b == null) return;
    try {
      final res = await _roomSvc.fetchRooms(buildingId: b.id, perPage: 100);
      setState(() => _rooms = res.items);
    } catch (e) {
      // ignore
    }
  }

  Future<void> _approve() async {
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a room')));
      return;
    }
    final deposit = double.tryParse(_depositCtrl.text) ?? 0.0;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a start date')));
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await _notifSvc.approveRegistration(
        notificationId: widget.notification.id,
        roomId: _selectedRoom!.id,
        deposit: deposit,
        startDate: _startDate!.toIso8601String().split('T').first,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration approved')));
      Get.back(result: res.toDomain());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: 'Reject registration',
        content: const Text('Are you sure you want to reject this registration?'),
        cancelLabel: 'Cancel',
        confirmLabel: 'Reject',
        confirmDestructive: true,
        avatarIcon: Icons.block,
      ),
    );
    if (ok != true) return;

    setState(() => _loading = true);
    try {
      final res = await _notifSvc.rejectRegistration(notificationId: widget.notification.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration rejected')));
      Get.back(result: res.toDomain());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Registration'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Applicant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(widget.notification.message, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<BuildingDto>(
                          items: _buildings.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                          initialValue: _selectedBuilding,
                          onChanged: (v) => _onBuildingChanged(v),
                          decoration: _fieldDecoration('Building', icon: Icons.apartment),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<RoomDto>(
                          items: _rooms.map((r) => DropdownMenuItem(value: r, child: Text(r.roomNumber.isNotEmpty ? r.roomNumber : (r.barcode.isNotEmpty ? r.barcode : 'Room')))).toList(),
                          initialValue: _selectedRoom,
                          onChanged: (v) => setState(() => _selectedRoom = v),
                          decoration: _fieldDecoration('Room', icon: Icons.meeting_room_outlined),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _depositCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: _fieldDecoration('Deposit', icon: Icons.payments_outlined),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(_startDate != null ? _startDate!.toIso8601String().split('T').first : 'Select start date'),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(const Duration(days: 0)),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                );
                                if (d != null) setState(() => _startDate = d);
                              },
                              child: const Text('Pick date'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_loading) const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reject,
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: _loading ? 'Please wait…' : 'Approve',
                        loading: _loading,
                        onPressed: _loading ? null : _approve,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
