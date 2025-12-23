// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'package:app/Presentation/widgets/gradient_button.dart';
import 'dart:convert';
import 'package:app/data/services/notifications/notification_service.dart';

class PaymentDetail extends StatefulWidget {
  final Map<String, dynamic>? payload;
  final int? notificationId;

  const PaymentDetail({super.key, this.payload, this.notificationId});

  @override
  _PaymentDetailState createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController waterController;
  late TextEditingController electricityController;
  late TextEditingController buildingController;
  late TextEditingController roomController;
  dynamic buildingId;
  dynamic roomId;

  @override
  void initState() {
    super.initState();
    final p = widget.payload ?? <String, dynamic>{};
    // support both generic keys and the specific payload keys you provided
    waterController = TextEditingController(
      text: p['water_meter']?.toString() ?? p['water']?.toString() ?? '');
    electricityController = TextEditingController(
      text: p['electricity_meter']?.toString() ?? p['meter']?.toString() ?? '');
    // building and room — support multiple payload shapes
    String? bname;
    String? rname;
    // building id fallback
    buildingId = p['building_id'] ?? (p['building'] is Map ? p['building']['id'] : null);
    roomId = p['room_id'] ?? (p['room'] is Map ? p['room']['id'] : null);
    if (p['building'] is String) bname = p['building'];
    if (p['building'] is Map) bname = p['building']['name'] ?? p['building']['building_name']?.toString();
    bname = bname ?? p['building_name']?.toString();
    if (p['room'] is String) rname = p['room'];
    if (p['room'] is Map) rname = p['room']['room_number'] ?? p['room']['name']?.toString();
    rname = rname ?? p['room_number']?.toString() ?? p['room_name']?.toString();
    buildingController = TextEditingController(text: bname ?? '');
    roomController = TextEditingController(text: rname ?? '');
    // Ensure viewmodel has settings/buildings loaded so totals can be calculated
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final provider = context.read<PaymentViewModel>();
        if (provider.buildings.isEmpty) {
          await provider.loadData();
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    waterController.dispose();
    electricityController.dispose();
    buildingController.dispose();
    roomController.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    final result = {
      'water_meter': waterController.text,
      'electricity_meter': electricityController.text,
      if (buildingId != null) 'building_id': buildingId,
      'building': buildingController.text,
      if (roomId != null) 'room_id': roomId,
      'room': roomController.text,
    };

    // Try to populate PaymentViewModel and open PaymentView
    try {
      final provider = context.read<PaymentViewModel>();

      // Ensure buildings loaded
      if (provider.buildings.isEmpty) {
        await provider.loadData();
      }

      // If payload contains building_id, try to select that building (fetch if missing)
      if (buildingId != null) {
        BuildingModel? building;
        try {
          building = provider.buildings.firstWhere((b) => b.id == buildingId);
        } catch (_) {
          building = null;
        }
        if (building == null) {
          try {
            final dto = await provider.buildingService.fetchBuildingById(buildingId);
            building = dto.toDomain();
            // add to provider's buildings list if missing
            provider.buildings.add(building!);
            provider.selectBuilding(building);
          } catch (_) {
            // ignore fetch failures
          }
        } else {
          provider.selectBuilding(building);
        }
      }

      // Find building by id or name
            BuildingModel? building;
            try {
              building = provider.buildings.firstWhere(
                (b) => (buildingId != null && b.id == buildingId) || (b.name == buildingController.text),
              );
            } catch (_) {
              building = null;
            }

      if (building != null) {
        provider.selectBuilding(building);
        // Ensure rooms for building are loaded
        await provider.loadRoomFromBuilding(building.id);
      }

      // Find room by id or room number
      RoomModel? room;
      if (roomId != null) {
        try {
          room = provider.rooms.firstWhere((r) => r.id == roomId);
        } catch (_) {
          room = null;
        }
      }
      if (room == null) {
        try {
          room = provider.rooms.firstWhere((r) => r.roomNumber == roomController.text);
        } catch (_) {
          room = null;
        }
      }

      if (room != null) {
        provider.selectRoom(room);
        // ensure room services and consumptions are loaded (loadRoomService returns a Future)
        try {
          await provider.loadRoomService();
        } catch (_) {}
        // ensure consumptions loaded
        await provider.loadConumption();
      }

      // set images if available
      provider.waterImage = widget.payload?['water_image']?.toString();
      provider.electricityImage = widget.payload?['electricity_image']?.toString();

      // set meters (will calculate totals using latestConsumptions)
      final w = double.tryParse(waterController.text) ?? 0;
      final e = double.tryParse(electricityController.text) ?? 0;
      provider.setWater(w);
      provider.setElectricity(e);

      // Instead of processing the payment locally (which requires a selected room
      // and caused server errors when room was null), only update the notification
      // payload on the server, call approve-payment, then mark as read.
      if (widget.notificationId != null) {
        final ns = NotificationService();

        // Build a merged payload: start with existing notification payload
        final merged = <String, dynamic>{};
        if (widget.payload != null) {
          try {
            merged.addAll(Map<String, dynamic>.from(widget.payload!));
          } catch (_) {}
        }

        // Overwrite with values from the form / provider
        merged['water_meter'] = waterController.text;
        if (widget.payload?['water_accuracy'] != null) merged['water_accuracy'] = widget.payload?['water_accuracy'];
        merged['electricity_meter'] = electricityController.text;
        if (widget.payload?['electricity_accuracy'] != null) merged['electricity_accuracy'] = widget.payload?['electricity_accuracy'];
        merged['water_image'] = provider.waterImage ?? widget.payload?['water_image'];
        merged['electricity_image'] = provider.electricityImage ?? widget.payload?['electricity_image'];

                // Derive room/building ids from multiple sources safely
        final dynamic _bObj = widget.payload?['building'];
        final dynamic _rObj = widget.payload?['room'];
        final payloadBuildingId = _bObj is Map ? (_bObj['id'] ?? _bObj['building_id']) : widget.payload?['building_id'];
        final payloadRoomId = _rObj is Map ? (_rObj['id'] ?? _rObj['room_id']) : widget.payload?['room_id'];

        merged['room_number'] = roomController.text;
        // prefer explicit buildingId, then provider selection, then payload variants
        merged['building_id'] = buildingId ?? provider.selectedBuilding?.id ?? payloadBuildingId;
        // prefer explicit roomId, then provider selection, then payload variants
        if (roomId != null) {
          merged['room_id'] = roomId;
        } else if (provider.selectedRoom?.id != null) {
          merged['room_id'] = provider.selectedRoom!.id;
        } else if (payloadRoomId != null) {
          merged['room_id'] = payloadRoomId;
        }
        merged['building'] = buildingController.text;
        merged['landlord_id'] = provider.landlord_id ?? merged['landlord_id'];
        merged['chat_id'] = widget.payload?['chat_id'] ?? merged['chat_id'];

        // Debug log merged payload
        try {
          print('merged notification payload: ${jsonEncode(merged)}');
        } catch (_) {}

        // If room id is missing, abort approve to avoid backend errors
        if (merged['room_id'] == null) {
          Get.back(result: {'error': 'Missing room information'});
          // Show a user-facing message
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            Get.snackbar('Error', 'Cannot approve: missing room information', snackPosition: SnackPosition.BOTTOM);
          }
          return;
        }

        // include nested room/building objects to match backend expectations
        if (merged['room_id'] != null) {
          merged['room'] = {
            'id': merged['room_id'],
            'room_number': merged['room_number'] ?? roomController.text,
          };
        }
        if (merged['building_id'] != null) {
          merged['building'] = {
            'id': merged['building_id'],
            'name': buildingController.text,
          };
        }

        // First: send the normal update (PUT) to the notifications resource
        try {
          await ns.putPayload(notificationId: widget.notificationId!, payload: merged).catchError((e) {
            print('putPayload failed: $e');
          });
        } catch (e) {
          print('Error while putting notification payload: $e');
        }

        // Build approve payload (only include necessary fields)
        final approvePayload = <String, dynamic>{};
        void addIf(String key, dynamic value) {
          if (value == null) return;
          if (value is String && value.trim().isEmpty) return;
          approvePayload[key] = value;
        }

        addIf('landlord_id', provider.landlord_id);
        addIf('chat_id', widget.payload?['chat_id']);
        addIf('water_meter', waterController.text);
        addIf('water_accuracy', widget.payload?['water_accuracy']);
        addIf('electricity_meter', electricityController.text);
        addIf('electricity_accuracy', widget.payload?['electricity_accuracy']);
        addIf('water_image', provider.waterImage ?? widget.payload?['water_image']);
        addIf('electricity_image', provider.electricityImage ?? widget.payload?['electricity_image']);
        addIf('room_id', merged['room_id']);
        addIf('room_number', roomController.text);
        addIf('building_id', merged['building_id']);

        // Second: call approve-payment (must be after updating the notification)
        try {
          await ns.approvePayment(notificationId: widget.notificationId!, payload: approvePayload).catchError((e) {
            print('approvePayment failed: $e');
          });
        } catch (e) {
          print('Error while approving payment: $e');
        }

        // Finally mark notification as read
        try {
          await ns.markAsRead(widget.notificationId!).catchError((e) {
            print('mark-as-read failed: $e');
          });
        } catch (e) {
          print('Error while marking as read: $e');
        }
      }

      Get.back(result: result);
    } catch (_) {
      // ignore and just return result
    }
    // If anything failed above, still return the result and close
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Get.back(result: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload ?? <String, dynamic>{};
    final waterAccuracy = payload['water_accuracy']?.toString();
    final electricityAccuracy = payload['electricity_accuracy']?.toString();
    final waterImage = payload['water_image']?.toString();
    final electricityImage = payload['electricity_image']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Detail', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppColors.surfaceColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dividerColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment details",
                      style: LomTextStyles.captionText().copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Building and Room fields
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Building",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: buildingController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Building is required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Room",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: roomController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Room is required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Text(
                    //   "Payload",
                    //   style: LomTextStyles.captionText().copyWith(
                    //     color: AppColors.textPrimary,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    const SizedBox(height: 8),
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey[100],
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: SelectableText(
                    //     JsonEncoder.withIndent('  ').convert(payload),
                    //     style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    // Row with both images (water and electricity)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Water Image",
                                style: LomTextStyles.captionText().copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: waterImage != null
                                    ? GestureDetector(
                                        onTap: () => Get.dialog(
                                          Material(
                                            color: Colors.black.withOpacity(0.9),
                                            child: SafeArea(
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: InteractiveViewer(
                                                      child: Image.network(
                                                        waterImage,
                                                        headers: {'Accept': 'application/json', 'ngrok-skip-browser-warning': 'true'},
                                                        errorBuilder: (_, __, ___) => const SizedBox(),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                                                      onPressed: () => Get.back(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Image.network(
                                          waterImage,
                                          headers: {'Accept': 'application/json', 'ngrok-skip-browser-warning': 'true'},
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 120,
                                          loadingBuilder: (context, child, progress) =>
                                              progress == null
                                                  ? child
                                                  : Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null)),
                                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                                        ),
                                      )
                                    : Center(child: Icon(Icons.image_outlined, size: 36, color: Colors.grey[500])),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Electricity Image",
                                style: LomTextStyles.captionText().copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: electricityImage != null
                                    ? GestureDetector(
                                        onTap: () => Get.dialog(
                                          Material(
                                            color: Colors.black.withOpacity(0.9),
                                            child: SafeArea(
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: InteractiveViewer(
                                                      child: Image.network(
                                                        electricityImage,
                                                        headers: {'Accept': 'application/json', 'ngrok-skip-browser-warning': 'true'},
                                                        errorBuilder: (_, __, ___) => const SizedBox(),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: IconButton(
                                                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                                                      onPressed: () => Get.back(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Image.network(
                                          electricityImage,
                                          headers: {'Accept': 'application/json', 'ngrok-skip-browser-warning': 'true'},
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 120,
                                          loadingBuilder: (context, child, progress) =>
                                              progress == null
                                                  ? child
                                                  : Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null)),
                                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                                        ),
                                      )
                                    : Center(child: Icon(Icons.image_outlined, size: 36, color: Colors.grey[500])),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Water",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: waterController,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                onChanged: (v) {
                                  try {
                                    final vm = context.read<PaymentViewModel>();
                                    final val = double.tryParse(v) ?? 0;
                                    vm.setWater(val);
                                  } catch (_) {}
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Water is required' : null,
                              ),
                              if (waterAccuracy != null) ...[
                                const SizedBox(height: 6),
                                Text('Accuracy: $waterAccuracy', style: Theme.of(context).textTheme.bodySmall),
                              ],
                              // image shown above in the shared row
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Electricity",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: electricityController,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                onChanged: (v) {
                                  try {
                                    final vm = context.read<PaymentViewModel>();
                                    final val = double.tryParse(v) ?? 0;
                                    vm.setElectricity(val);
                                  } catch (_) {}
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 14.0,
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Electricity is required' : null,
                              ),
                              if (electricityAccuracy != null) ...[
                                const SizedBox(height: 6),
                                Text('Accuracy: $electricityAccuracy', style: Theme.of(context).textTheme.bodySmall),
                              ],
                              // image shown above in the shared row
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Live summary of calculated quantities and totals
                    Builder(
                      builder: (ctx) {
                        final vm = context.watch<PaymentViewModel>();
                        final roomPrice = (vm.selectedRoom?.price ?? 0);
                        final servicesTotal = vm.roomServices.fold<double>(0.0, (s, it) => s + (it.unitPrice ?? 0));
                        final grandTotal = (vm.water_total) + (vm.electricity_total) + roomPrice + servicesTotal;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment summary', style: LomTextStyles.captionText().copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (!vm.isLastPayment && vm.selectedRoom != null) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Room price'),
                                    Text(roomPrice.toStringAsFixed(2)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                              ],
                              if (vm.roomServices.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Services total'),
                                    Text(servicesTotal.toStringAsFixed(2)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Water qty'),
                                  Text(vm.water_qty.toStringAsFixed(2)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Water total'),
                                  Text(vm.water_total.toStringAsFixed(2)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Electricity qty'),
                                  Text(vm.electricity_qty.toStringAsFixed(2)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Electricity total'),
                                  Text(vm.electricity_total.toStringAsFixed(2)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: AppColors.dividerColor),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Grand total', style: LomTextStyles.captionText().copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                                  Text(grandTotal.toStringAsFixed(2), style: LomTextStyles.captionText().copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: 'Reject',
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _reject();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Approve',
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _accept();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reject() async {
    if (widget.notificationId == null) {
      // nothing to do
      if (ModalRoute.of(context)?.isCurrent ?? false) Get.back();
      return;
    }

    final provider = context.read<PaymentViewModel>();

    // Try to load provider data similar to approve flow so we can include useful fields
    try {
      if (provider.buildings.isEmpty) await provider.loadData();
    } catch (_) {}

    // Build payload similarly to approve
    final payload = <String, dynamic>{};
    void addIf(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      payload[key] = value;
    }

    addIf('landlord_id', provider.landlord_id);
    addIf('chat_id', widget.payload?['chat_id']);
    addIf('water_meter', waterController.text);
    addIf('water_accuracy', widget.payload?['water_accuracy']);
    addIf('electricity_meter', electricityController.text);
    addIf('electricity_accuracy', widget.payload?['electricity_accuracy']);
    addIf('water_image', provider.waterImage ?? widget.payload?['water_image']);
    addIf('electricity_image', provider.electricityImage ?? widget.payload?['electricity_image']);
    addIf('room_id', roomId ?? provider.selectedRoom?.id ?? widget.payload?['room_id']);
    addIf('room_number', roomController.text);
    addIf('building_id', buildingId ?? provider.selectedBuilding?.id ?? widget.payload?['building_id']);

    final ns = NotificationService();
    try {
      await ns.rejectPayment(notificationId: widget.notificationId!, payload: payload).catchError((e) {
        print('rejectPayment failed: $e');
      });
      await ns.markAsRead(widget.notificationId!).catchError((e) {
        print('mark-as-read failed after reject: $e');
      });
    } catch (e) {
      print('Reject flow error: $e');
    }

    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Get.back(result: {'rejected': true});
    }
  }
}