import 'package:app/data/services/rooms_service/fetch_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/views/rooms/edit_room_view.dart';
import 'package:app/Presentation/provider/room_services_viewmodel.dart';
import 'package:app/Presentation/provider/contract_viewmodel.dart';
import 'package:app/data/implementations/rooms/room_services_repository_impl.dart';
import 'package:app/data/implementations/contract/contract_repository_impl.dart';
import 'package:app/Presentation/views/contracts/add_contract_view.dart';
import 'package:app/Presentation/widgets/confirm_action_dialog.dart';

class RoomDetailView extends StatefulWidget {
  final dynamic room; // RoomModel or Map<String, dynamic>
  final int? roomId;

  // `room` or `roomId` may be provided. If neither is provided the view will
  // attempt to read `Get.arguments` or `Get.parameters` (for named routes).
  const RoomDetailView({super.key, this.room, this.roomId});

  @override
  State<RoomDetailView> createState() => _RoomDetailViewState();
}

class _RoomDetailViewState extends State<RoomDetailView> {
  late RoomServicesViewModel _servicesViewModel;
  late ContractViewModel _contractViewModel;
  String _apiStatus = '';
  bool _loadingRoom = false;

  @override
  void initState() {
    super.initState();
    _servicesViewModel = RoomServicesViewModel(RoomServicesRepositoryImpl());
    _contractViewModel = ContractViewModel(ContractRepositoryImpl());
    _loadRoom();
    _loadServices();
    _loadContract();
  }

  Future<void> _loadRoom() async {
    // Determine room id from widget/route
    final dynamic arg = widget.room ?? Get.arguments;
    final dynamic byParam = Get.parameters.isNotEmpty ? Get.parameters : null;
    final dynamic effectiveRoom =
        arg ??
        (byParam != null && byParam['id'] != null
            ? {'id': byParam['id']}
            : null) ??
        {};

    final isMap = effectiveRoom is Map<String, dynamic>;
    final int? roomId =
        widget.roomId ??
        (isMap ? (effectiveRoom['id'] as int?) : (effectiveRoom.id as int?));

    if (roomId == null) return;
    setState(() => _loadingRoom = true);
    try {
      final svc = RoomFetchService();
      final dto = await svc.fetchRoomById(roomId);
      // Prefer API-provided status
      _apiStatus = (dto.status).toString();
    } catch (_) {
      // keep existing fallback if API fails
    } finally {
      if (mounted) setState(() => _loadingRoom = false);
    }
  }

  void _loadServices() {
    // Determine the effective room object and extract roomId
    final dynamic arg = widget.room ?? Get.arguments;
    final dynamic byParam = Get.parameters.isNotEmpty ? Get.parameters : null;
    final dynamic effectiveRoom =
        arg ??
        (byParam != null && byParam['id'] != null
            ? {'id': byParam['id']}
            : null) ??
        {};

    final isMap = effectiveRoom is Map<String, dynamic>;
    final int? roomId =
        widget.roomId ??
        (isMap ? (effectiveRoom['id'] as int?) : (effectiveRoom.id as int?));

    if (roomId != null) {
      _servicesViewModel.loadRoomServices(roomId);
    }
  }

  void _loadContract() {
    final dynamic arg = widget.room ?? Get.arguments;
    final dynamic byParam = Get.parameters.isNotEmpty ? Get.parameters : null;
    final dynamic effectiveRoom =
        arg ??
        (byParam != null && byParam['id'] != null
            ? {'id': byParam['id']}
            : null) ??
        {};

    final isMap = effectiveRoom is Map<String, dynamic>;
    final int? roomId =
        widget.roomId ??
        (isMap ? (effectiveRoom['id'] as int?) : (effectiveRoom.id as int?));

    if (roomId != null) {
      _contractViewModel.loadActiveContract(roomId);
    }
  }

  @override
  void dispose() {
    _servicesViewModel.dispose();
    _contractViewModel.dispose();
    super.dispose();
  }

  String _safeString(dynamic v) => v == null ? '' : v.toString();

  double? _safeDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Map<String, dynamic>? _buildingMap() {
    if (widget.room is Map<String, dynamic>) {
      return (widget.room['building'] is Map)
          ? Map<String, dynamic>.from(widget.room['building'])
          : null;
    }
    try {
      final b = widget.room.building;
      if (b == null) return null;
      return {
        'id': b.id,
        'name': b.name,
        'address': b.address,
        'image_url': b.imageUrl,
        'floor': b.floor,
        'unit': b.unit,
      };
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _currentContractMap() {
    if (widget.room is Map<String, dynamic>) {
      return (widget.room['current_contract'] is Map)
          ? Map<String, dynamic>.from(widget.room['current_contract'])
          : null;
    }
    try {
      final c = widget.room.currentContract;
      if (c == null) return null;
      return {
        'id': c.id,
        'identify_id': c.identifyId ?? c.identify_id ?? '',
        'name': c.name ?? '',
        'phone': c.phone ?? '',
        'move_in_date': c.moveInDate ?? c.move_in_date ?? '',
        'monthly': c.monthly ?? c.monthly_price,
        'payment_status': c.paymentStatus ?? c.payment_status ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the effective room object: prefer constructor `room`, then
    // `Get.arguments`, then attempt to read from route parameters.
    final dynamic arg = widget.room ?? Get.arguments;
    final dynamic byParam = Get.parameters.isNotEmpty ? Get.parameters : null;

    final dynamic effectiveRoom =
        arg ??
        (byParam != null && byParam['id'] != null
            ? {'id': byParam['id']}
            : null) ??
        {};

    final isMap = effectiveRoom is Map<String, dynamic>;
    final roomNumber = isMap
        ? _safeString(
            effectiveRoom['room_number'] ??
                effectiveRoom['roomNumber'] ??
                effectiveRoom['name'],
          )
        : _safeString(effectiveRoom.roomNumber ?? effectiveRoom.name);
    final floor = isMap
        ? _safeString(effectiveRoom['floor'])
        : _safeString(effectiveRoom.floor);
    final status = isMap
        ? _safeString(effectiveRoom['status'])
        : _safeString(effectiveRoom.status);
    final priceVal = isMap
        ? _safeDouble(effectiveRoom['price'])
        : _safeDouble(effectiveRoom.price);

    final building = _buildingMap();
    final currentContract = _currentContractMap();

    final headerImage = building != null
        ? (building['image_url'] ?? '') as String
        : '';
    final buildingName = building != null
        ? (building['name'] ?? '') as String
        : '';

    String paymentStatusLabel() {
      if (currentContract == null) return 'Unpaid';
      final ps = (currentContract['payment_status'] ?? '')
          .toString()
          .toLowerCase();
      if (ps.contains('paid')) return 'Paid';
      if (ps.contains('pending')) return 'Pending';
      if (ps.contains('unpaid')) return 'Unpaid';
      return 'Unpaid';
    }

    // Use API status if available; fall back to passed-in room status; default to Available
    final effectiveStatus = _apiStatus.isNotEmpty ? _apiStatus : status;
    final statusLabel =
        (effectiveStatus.isNotEmpty ? effectiveStatus : 'Available')
            .toLowerCase();

    Widget imgPlaceholder() => Container(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
    );

    Widget buildPaymentPill(String label) {
      final l = label.toLowerCase();
      Color bg;
      Color text;
      switch (l) {
        case 'paid':
          bg = const Color(0xFFE3F7E9);
          text = const Color(0xFF2E7D32);
          break;
        case 'pending':
          bg = const Color(0xFFFFF4E5);
          text = const Color(0xFFEF6C00);
          break;
        case 'unpaid':
        default:
          bg = const Color(0xFFFDECEA);
          text = const Color(0xFFB71C1C);
          break;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: text, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadRoom();
          _loadServices();
          _loadContract();
        },
        child: Stack(
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: headerImage.isNotEmpty
                  ? Image.network(
                      headerImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'lib/assets/images/test.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => imgPlaceholder(),
                      ),
                    )
                  : Image.asset(
                      'lib/assets/images/test.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => imgPlaceholder(),
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.35),
                    ),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: 230 - 20,
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              roomNumber,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_loadingRoom)
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              if (!_loadingRoom)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusLabel.contains('available')
                                        ? const Color(0xFFE3F2FD)
                                        : const Color(0xFFE3F7E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    statusLabel[0].toUpperCase() +
                                        statusLabel.substring(1),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: statusLabel.contains('available')
                                          ? const Color(0xFF0D47A1)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              // small edit icon beside the status
                              InkWell(
                                onTap: () async {
                                  final res = await Get.to(
                                    () => EditRoomView(room: effectiveRoom),
                                  );
                                  if (res == true) {
                                    await _loadRoom();
                                    _loadServices();
                                    _loadContract();
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // delete icon beside edit
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(buildingName),
                                const SizedBox(height: 4),
                                Text(
                                  'Floor ${floor.isNotEmpty ? floor : (building != null && building['floor'] != null ? building['floor'].toString() : '-')}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Room Facility',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ChangeNotifierProvider.value(
                        value: _servicesViewModel,
                        child: Consumer<RoomServicesViewModel>(
                          builder: (context, viewModel, child) {
                            if (viewModel.isLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (viewModel.error != null) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Error loading services',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }

                            if (!viewModel.hasServices) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No services available',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: viewModel.services
                                    .map(
                                      (service) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Chip(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          backgroundColor:
                                              AppColors.backgroundColor,
                                          side: BorderSide(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.18),
                                          ),
                                          label: Text(
                                            service.name,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Rental Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: Payment label on top, Monthly label below
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Status :',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Monthly :',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          // Right column: pill on top, amount below (kept right-aligned)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildPaymentPill(paymentStatusLabel()),
                              const SizedBox(height: 12),
                              Text(
                                priceVal != null
                                    ? '\$${priceVal.toStringAsFixed(0)}'
                                    : '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Tenant Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ChangeNotifierProvider.value(
                        value: _contractViewModel,
                        child: Consumer<ContractViewModel>(
                          builder: (context, viewModel, child) {
                            if (viewModel.isLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (viewModel.error != null) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Error loading tenant info',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }

                            if (!viewModel.hasContract) {
                              return const Text('No tenant');
                            }

                            final contract = viewModel.contract!;
                            final tenant = contract.tenant;
                            final startDate = contract.startDate
                                .toString()
                                .split(' ')[0];

                          return Column(
                            children: [
                              _buildTenantRow('Identify ID', tenant.identifyId ?? '-'),
                              _buildTenantRow('Name', tenant.name),
                              _buildTenantRow('Phone Number', tenant.phoneNumber ?? tenant.email ?? '-'),
                              _buildTenantRow('Move In date', startDate),
                              _buildTenantRow('Deposit', '\$${contract.depositAmount.toStringAsFixed(0)}'),
                              _buildTenantRow('Status', contract.status),
                            ],
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        onPressed: () async {
                          final dynamic arg = widget.room ?? Get.arguments;
                          final dynamic byParam = Get.parameters.isNotEmpty ? Get.parameters : null;
                          final dynamic effectiveRoom = arg ?? (byParam != null && byParam['id'] != null ? {'id': byParam['id']} : null) ?? {};
                          final isMap = effectiveRoom is Map<String, dynamic>;
                          final int? roomId = widget.roomId ?? (isMap ? (effectiveRoom['id'] as int?) : (effectiveRoom.id as int?));
                          if (roomId == null) {
                            Get.snackbar('Contract', 'Room ID not found');
                            return;
                          }
                          final res = await Get.to(() => AddContractView(roomId: roomId));
                          if (res == true) {
                            await _loadRoom();
                            _loadServices();
                            _loadContract();
                          }
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Contract'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTenantRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
