import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/payment_viewmode/payment_viewmodel.dart';
import 'package:app/Presentation/views/payment/payment_view.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'dart:convert';
import 'package:app/data/services/notifications/notification_service.dart';

class PaymentDetail extends StatefulWidget {
  final Map<String, dynamic>? payload;
  final int? notificationId;

  const PaymentDetail({Key? key, this.payload, this.notificationId}) : super(key: key);

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

      // Close this detail and then navigate to PaymentView so user can continue
      // Process payment immediately and open receipt if available
      try {
        final response = await provider.processPayment();
        // Try common shapes for receipt URL
        String? receipt;
        if (response['receipt_url'] != null) receipt = response['receipt_url']?.toString();
        if (receipt == null && response['data'] is Map && response['data']['receipt_url'] != null) {
          receipt = response['data']['receipt_url']?.toString();
        }
        if (receipt == null && response['original'] is Map) {
          final orig = response['original'] as Map<String, dynamic>;
          if (orig['payment'] is Map && orig['payment']['receipt_url'] != null) {
            receipt = orig['payment']['receipt_url']?.toString();
          }
        }
        if (receipt != null) {
          provider.setReceipt(receipt);
        }

        // Call notification approve-payment and update endpoints concurrently if notificationId present
        if (widget.notificationId != null) {
          final ns = NotificationService();
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
          addIf('room_id', roomId ?? provider.selectedRoom?.id ?? widget.payload?['room_id']);
          addIf('room_number', roomController.text);
          addIf('building_id', buildingId ?? provider.selectedBuilding?.id ?? widget.payload?['building_id']);

          // Log payload for debugging server errors
          try {
            print('approvePayload: ${jsonEncode(approvePayload)}');
          } catch (_) {}

          final futures = <Future>[];
          futures.add(ns.approvePayment(notificationId: widget.notificationId!, payload: approvePayload).catchError((e) {
            // log but don't throw
            print('approvePayment failed: $e');
          }));
          // Use markAsRead to avoid accidentally replacing notification fields
          futures.add(ns.markAsRead(widget.notificationId!).catchError((e) {
            print('mark-as-read failed: $e');
          }));

          await Future.wait(futures);
        }

        Get.back(result: result);
        Get.to(() => const PaymentView());
      } catch (e) {
        // If payment processing fails, still close and return result
        Get.back(result: result);
        Get.to(() => const PaymentView());
      }
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
                    Text(
                      "Payload",
                      style: LomTextStyles.captionText().copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        JsonEncoder.withIndent('  ').convert(payload),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      ),
                    ),
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
                                        onTap: () => Get.dialog(Center(
                                          child: InteractiveViewer(
                                            child: Image.network(waterImage, errorBuilder: (_, __, ___) => const SizedBox()),
                                          ),
                                        )),
                                        child: Image.network(
                                          waterImage,
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
                                        onTap: () => Get.dialog(Center(
                                          child: InteractiveViewer(
                                            child: Image.network(electricityImage, errorBuilder: (_, __, ___) => const SizedBox()),
                                          ),
                                        )),
                                        child: Image.network(
                                          electricityImage,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _accept();
                  }
                },
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}