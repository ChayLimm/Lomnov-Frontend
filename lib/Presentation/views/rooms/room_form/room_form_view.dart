import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:app/data/services/rooms_service/fetch_service.dart';
import 'package:app/data/services/settings/services_service.dart';
import 'package:app/data/services/settings/room_types_service.dart';
import 'package:app/domain/models/settings/room_type_model.dart';
import 'package:app/data/services/rooms_service/room_services_service.dart';
import 'package:app/domain/models/settings/service_model.dart';
import 'package:app/data/services/buildings/fetch_service.dart';

class RoomFormView extends StatefulWidget {
  final int? buildingId;
  final dynamic room; // RoomModel or Map for edit

  const RoomFormView({super.key, this.buildingId, this.room});

  bool get isEdit => room != null;

  @override
  State<RoomFormView> createState() => _RoomFormViewState();
}

class _RoomFormViewState extends State<RoomFormView> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  bool _submitting = false;

  int? _roomId;
  late int _buildingId;

  List<ServiceModel> _availableServices = [];
  Set<int> _selectedServiceIds = {};
  Set<int> _initialServiceIds = {};
  bool _loadingServices = true;

  // Room types
  List<RoomTypeModel> _roomTypes = [];
  bool _loadingRoomTypes = true;
  int? _selectedRoomTypeId;

  // Building floor limit
  int? _maxBuildingFloor;
  bool _loadingBuildingFloor = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      final r = widget.room;
      if (r is Map<String, dynamic>) {
        _roomId = (r['id'] ?? r['room_id'] ?? r['roomId']) is int
            ? (r['id'] ?? r['room_id'] ?? r['roomId']) as int
            : int.tryParse((r['id'] ?? r['room_id'] ?? r['roomId']).toString());
        _buildingId =
            (r['building_id'] ?? r['buildingId'] ?? r['building']?['id']) is int
            ? (r['building_id'] ?? r['buildingId'] ?? r['building']?['id'])
                  as int
            : int.tryParse(
                    (r['building_id'] ??
                            r['buildingId'] ??
                            r['building']?['id'])
                        .toString(),
                  ) ??
                  0;
        final dynamic rtIdRaw =
            r['room_type_id'] ?? r['roomTypeId'] ?? r['room_type']?['id'];
        _selectedRoomTypeId = rtIdRaw is int
            ? rtIdRaw
            : int.tryParse(rtIdRaw?.toString() ?? '');
        _roomNumberCtrl.text =
            (r['room_number'] ?? r['roomNumber'] ?? r['name'])?.toString() ??
            '';
        _priceCtrl.text = (r['price'] ?? '')?.toString() ?? '';
        _barcodeCtrl.text = (r['barcode'] ?? '')?.toString() ?? '';
        _floorCtrl.text = (r['floor'] ?? '')?.toString() ?? '';
        _statusCtrl.text = (r['status'] ?? '')?.toString() ?? '';
      } else {
        _roomId = r.id;
        _buildingId = r.buildingId ?? 0;
        _selectedRoomTypeId = r.roomTypeId;
        _roomNumberCtrl.text = (r.roomNumber ?? r.name ?? '').toString();
        _priceCtrl.text = (r.price != null) ? r.price.toString() : '';
        _barcodeCtrl.text = (r.barcode ?? '').toString();
        _floorCtrl.text = (r.floor ?? '').toString();
        _statusCtrl.text = (r.status ?? '').toString();
      }
    } else {
      _buildingId = widget.buildingId ?? 0;
    }
    _loadServices();
    _loadRoomTypes();
    _loadBuildingFloorLimit();
  }

  Future<void> _loadBuildingFloorLimit() async {
    if (_buildingId == 0) return; // nothing to load
    setState(() => _loadingBuildingFloor = true);
    try {
      final svc = BuildingFetchService();
      final dto = await svc.fetchBuildingById(_buildingId);
      final maxFloor = dto.floor; // dto has int floor
      setState(() {
        // ignore: unnecessary_type_check
        _maxBuildingFloor = (maxFloor is int && maxFloor > 0) ? maxFloor : null;
        _loadingBuildingFloor = false;
      });
      // Clamp current floor selection if it exceeds the limit
      final current = int.tryParse(_floorCtrl.text);
      if (_maxBuildingFloor != null &&
          current != null &&
          current > _maxBuildingFloor!) {
        setState(() => _floorCtrl.text = _maxBuildingFloor!.toString());
      }
    } catch (e) {
      dev.log('[RoomForm] Failed to load building floor limit: $e');
      setState(() => _loadingBuildingFloor = false);
    }
  }

  Future<void> _loadRoomTypes() async {
    try {
      final svc = RoomTypesService();
      final dtos = await svc.fetchAll();
      setState(() {
        _roomTypes = dtos.map((d) => d.toDomain()).toList();
        _loadingRoomTypes = false;
      });
    } catch (e) {
      dev.log('[RoomForm] Failed to load room types: $e');
      setState(() => _loadingRoomTypes = false);
    }
  }

  Future<void> _loadServices() async {
    try {
      final servicesSvc = ServicesService();
      final allServiceDtos = await servicesSvc.fetchByLandlord();

      if (widget.isEdit && _roomId != null) {
        final roomServicesSvc = RoomServicesService();
        final roomServiceDtos = await roomServicesSvc.fetchRoomServices(
          _roomId!,
        );
        setState(() {
          _availableServices = allServiceDtos
              .map((dto) => dto.toDomain())
              .toList();
          _initialServiceIds = roomServiceDtos
              .map((dto) => dto.toDomain().id)
              .toSet();
          _selectedServiceIds = Set.from(_initialServiceIds);
          _loadingServices = false;
        });
      } else {
        setState(() {
          _availableServices = allServiceDtos
              .map((dto) => dto.toDomain())
              .toList();
          _loadingServices = false;
        });
      }
    } catch (e) {
      dev.log('[RoomForm] Failed to load services: $e');
      setState(() => _loadingServices = false);
    }
  }

  @override
  void dispose() {
    _roomNumberCtrl.dispose();
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
      'room_type_id': _selectedRoomTypeId,
      'room_number': _roomNumberCtrl.text.trim(),
      'price': _priceCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_priceCtrl.text.trim()),
      'barcode': _barcodeCtrl.text.trim().isEmpty
          ? null
          : _barcodeCtrl.text.trim(),
      'floor': _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
      'status': _statusCtrl.text.trim().isEmpty
          ? null
          : _statusCtrl.text.trim(),
    };

    try {
      final svc = RoomFetchService();
      if (widget.isEdit) {
        final updated = await svc.updateRoom(_roomId!, payload);
        dev.log('[Rooms] updated room id=${updated.id}');

        final servicesToAdd = _selectedServiceIds.difference(
          _initialServiceIds,
        );
        final servicesToRemove = _initialServiceIds.difference(
          _selectedServiceIds,
        );
        final roomServicesSvc = RoomServicesService();
        for (final serviceId in servicesToAdd) {
          try {
            await roomServicesSvc.attachService(_roomId!, serviceId);
            dev.log('[Rooms] attached service $serviceId to room $_roomId');
          } catch (e) {
            dev.log('[Rooms] Failed to attach service $serviceId: $e');
          }
        }
        for (final serviceId in servicesToRemove) {
          try {
            await roomServicesSvc.detachService(_roomId!, serviceId);
            dev.log('[Rooms] detached service $serviceId from room $_roomId');
          } catch (e) {
            dev.log('[Rooms] Failed to detach service $serviceId: $e');
          }
        }

        if (!mounted) return;
        Get.back(result: true);
        Get.snackbar('Updated', 'Room updated');
      } else {
        final created = await svc.createRoom(payload);
        dev.log('[Rooms] created room id=${created.id}');

        if (_selectedServiceIds.isNotEmpty) {
          final roomServicesSvc = RoomServicesService();
          for (final serviceId in _selectedServiceIds) {
            try {
              await roomServicesSvc.attachService(created.id, serviceId);
              dev.log(
                '[Rooms] attached service $serviceId to room ${created.id}',
              );
            } catch (e) {
              dev.log('[Rooms] Failed to attach service $serviceId: $e');
            }
          }
        }

        if (!mounted) return;
        // Navigate to the room detail view and, when returning,
        // signal the previous screen (e.g., building detail) to refresh.
        final _ = await Get.toNamed('/rooms/${created.id}', arguments: created);
        if (!mounted) return;
        Get.back(result: true);
        Get.snackbar(
          'Created',
          'Room created',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      dev.log('[Rooms] submit failed: $e');
      if (mounted) Get.snackbar('Error', 'Failed to submit: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _roomTypeNameById(int? id) {
    if (id == null) return null;
    try {
      return _roomTypes.firstWhere((e) => e.id == id).roomTypeName;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openRoomTypePicker() async {
    if (_roomTypes.isEmpty) return;
    int initialIndex = 0;
    if (_selectedRoomTypeId != null) {
      final idx = _roomTypes.indexWhere((e) => e.id == _selectedRoomTypeId);
      if (idx >= 0) initialIndex = idx;
    }

    int tempIndex = initialIndex;

    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(tempIndex),
                        child: Text(
                          'Done',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (i) => tempIndex = i,
                    children: _roomTypes
                        .map(
                          (rt) => Center(
                            child: Text(
                              rt.roomTypeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && picked >= 0 && picked < _roomTypes.length) {
      setState(() {
        _selectedRoomTypeId = _roomTypes[picked].id;
      });
    }
  }

  Future<void> _openFloorPicker() async {
    final max = (_maxBuildingFloor ?? 20);
    final values = List.generate(max.clamp(1, 999), (i) => i + 1);
    int initialIndex = 0;
    final current = int.tryParse(_floorCtrl.text);
    if (current != null) {
      final idx = values.indexOf(current);
      if (idx >= 0) initialIndex = idx;
    }
    int tempIndex = initialIndex;

    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(tempIndex),
                        child: Text(
                          'Done',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (i) => tempIndex = i,
                    children: values
                        .map((n) => Center(child: Text('Floor $n')))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && picked >= 0 && picked < values.length) {
      setState(() => _floorCtrl.text = values[picked].toString());
    }
  }

  Future<void> _openStatusPicker() async {
    const statuses = ['Available', 'Unpaid', 'Pending', 'Paid'];
    int initialIndex = 0;
    if (_statusCtrl.text.isNotEmpty) {
      final current =
          _statusCtrl.text[0].toUpperCase() +
          _statusCtrl.text.substring(1).toLowerCase();
      final idx = statuses.indexOf(current);
      if (idx >= 0) initialIndex = idx;
    }
    int tempIndex = initialIndex;

    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(tempIndex),
                        child: Text(
                          'Done',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (i) => tempIndex = i,
                    children: statuses
                        .map((s) => Center(child: Text(s)))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && picked >= 0 && picked < statuses.length) {
      setState(() => _statusCtrl.text = statuses[picked]);
    }
  }

  Future<void> _openServicesPicker() async {
    if (_availableServices.isEmpty) return;
    // Use a temporary set to avoid updating selection until Done is pressed
    final tempSelected = Set<int>.from(_selectedServiceIds);

    final picked = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, modalSetState) {
          return SafeArea(
            top: false,
            child: SizedBox(
              height: 460,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            'Done',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _availableServices.length,
                      itemBuilder: (context, index) {
                        final service = _availableServices[index];
                        final checked = tempSelected.contains(service.id);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: checked,
                                onChanged: (v) {
                                  modalSetState(() {
                                    if (v == true) {
                                      tempSelected.add(service.id);
                                    } else {
                                      tempSelected.remove(service.id);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(service.name)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );

    if (picked == true) {
      setState(() {
        _selectedServiceIds = tempSelected;
      });
    }
  }

  InputDecoration _fieldDecoration(
    String label, {
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.primaryColor)
          : null,
      suffixIcon: suffixIcon,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(widget.isEdit ? 'Edit Room' : 'Add Room', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Room Type dropdown moved below Status field
                TextFormField(
                  controller: _roomNumberCtrl,
                  decoration: _fieldDecoration(
                    'Room Number',
                    icon: Icons.tag_outlined,
                  ),
                  maxLength: 50,
                  buildCounter:
                      (
                        _, {
                        required int currentLength,
                        required bool isFocused,
                        required int? maxLength,
                      }) => null,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim().length > 50) return 'Max 50 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: _fieldDecoration(
                    'Price',
                    icon: Icons.attach_money_outlined,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                  decoration: _fieldDecoration(
                    'Barcode',
                    icon: Icons.qr_code_2,
                  ),
                  maxLength: 255,
                  buildCounter:
                      (
                        _, {
                        required int currentLength,
                        required bool isFocused,
                        required int? maxLength,
                      }) => null,
                ),
                const SizedBox(height: 12),
                if (_loadingBuildingFloor)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _openFloorPicker,
                      child: InputDecorator(
                        decoration: _fieldDecoration(
                          'Floor',
                          icon: Icons.layers_outlined,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _floorCtrl.text.isEmpty
                                    ? 'Select Floor'
                                    : 'Floor ${_floorCtrl.text}',
                                style: TextStyle(
                                  color: _floorCtrl.text.isEmpty
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _openStatusPicker,
                    child: InputDecorator(
                      decoration: _fieldDecoration(
                        'Status',
                        icon: Icons.info_outline,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _statusCtrl.text.isEmpty
                                  ? 'Select Status'
                                  : _statusCtrl.text,
                              style: TextStyle(
                                color: _statusCtrl.text.isEmpty
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_loadingRoomTypes)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  FormField<int>(
                    validator: (_) =>
                        _selectedRoomTypeId == null ? 'Required' : null,
                    builder: (state) {
                      final selectedName = _roomTypeNameById(
                        _selectedRoomTypeId,
                      );
                      return SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _openRoomTypePicker,
                          child: InputDecorator(
                            decoration: _fieldDecoration(
                              'Room Type',
                              icon: Icons.meeting_room_outlined,
                            ).copyWith(errorText: state.errorText),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedName ?? 'Select Room Type',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: selectedName == null
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                ),
                
                if (_loadingServices)
                  const Center(child: CircularProgressIndicator())
                else if (_availableServices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No services available'),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _openServicesPicker,
                      child: InputDecorator(
                        decoration: _fieldDecoration(
                          'Services',
                          icon: Icons.miscellaneous_services_outlined,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Builder(builder: (ctx) {
                                if (_selectedServiceIds.isEmpty) {
                                  return Text('Select Services',
                                      style:
                                          TextStyle(color: Colors.grey));
                                }
                                final names = _availableServices
                                    .where((s) => _selectedServiceIds.contains(s.id))
                                    .map((s) => s.name)
                                    .toList();
                                final display = names.length <= 3
                                    ? names.join(', ')
                                    : '${names.length} selected';
                                return Text(
                                  display,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black87),
                                );
                              }),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Image picker placeholder styled like Add Building form
                const SizedBox(height: 8),
                _ImagePickerPlaceholderRoom(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: widget.isEdit
                          ? AppColors.secondaryColor
                          : null,
                    ),
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEdit ? 'Save' : 'Create'),
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

/// A lightweight image picker placeholder copied/adapted from the Add Building
/// view. This shows a tappable preview box and lets the user pick a local
/// image for visual preview only; it does not upload or post anything.
class _ImagePickerPlaceholderRoom extends StatefulWidget {
  final void Function(Uint8List bytes, String filename)? onFileSelected;
  const _ImagePickerPlaceholderRoom({this.onFileSelected});

  @override
  State<_ImagePickerPlaceholderRoom> createState() => _ImagePickerPlaceholderRoomState();
}

class _ImagePickerPlaceholderRoomState extends State<_ImagePickerPlaceholderRoom> {
  Uint8List? _previewBytes;
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    setState(() {
      _previewBytes = file.bytes;
      _fileName = file.name;
    });
    if (file.bytes != null && file.bytes!.isNotEmpty && widget.onFileSelected != null) {
      widget.onFileSelected!(file.bytes!, file.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.solid),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickFile,
            child: Stack(
              children: [
                Center(
                  child: _previewBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _previewBytes!,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, color: Colors.grey.shade600),
                            const SizedBox(height: 6),
                            Text('Tap to select image', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        if (_fileName != null && _fileName!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _fileName!,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ]
      ],
    );
  }
}
