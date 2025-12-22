// ignore_for_file: unused_field, deprecated_member_use

import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/data/implementations/building/building_implementation.dart';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/Presentation/widgets/error1.dart';
import 'package:app/Presentation/widgets/empty1.dart';
import 'package:app/Presentation/widgets/confirm_action_dialog.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/views/home/home_parts/home_shimmer.dart';
import 'package:app/Presentation/widgets/inline_shimmer.dart';
import 'package:app/Presentation/views/buildings/building_detail_shimmer.dart';
import 'package:app/data/services/rooms_service/fetch_service.dart';
import 'package:app/Presentation/views/rooms/add_room_view.dart';
import 'package:app/Presentation/views/rooms/edit_room_view.dart';
import 'package:app/Presentation/views/rooms/room_detail_view.dart';

// Layout constants
const double headerHeight = 230; // Top image height
const double topRadius = 20; // Match the large rounded top design

class BuildingDetailView extends StatefulWidget {
  final int buildingId;
  const BuildingDetailView({super.key, required this.buildingId});

  @override
  State<BuildingDetailView> createState() => _BuildingDetailViewState();
}

class _BuildingDetailViewState extends State<BuildingDetailView> {
  final _repository = BuildingRepositoryImpl();
  bool _loading = true;
  String? _error;
  BuildingModel? _building;
  List<dynamic> _rooms = [];
  int _currentPage = 1;
  final int _perPage = 5;
  final _roomSearchCtrl = TextEditingController();
  String _activeFilter = 'All'; // All, Available, Unpaid, Pending, Paid

  @override
  void initState() {
    super.initState();
    _load();
    _roomSearchCtrl.addListener(() => setState(() {}));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final b = await _repository.fetchBuildingById(widget.buildingId);
      // Use the building-specific data to ensure rooms match the building.
      // Endpoint: /api/buildings/{id}
      _rooms = b.rooms;
      _currentPage = 1;
      dev.log('[Rooms] using building-specific rooms count=${_rooms.length} for buildingId=${widget.buildingId}');
      if (!mounted) return;
      setState(() => _building = b);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _roomSearchCtrl.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    extendBodyBehindAppBar: true, 
    body: _loading
      ? const BuildingDetailShimmer()
      : _error != null
            ? RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  children: [
                    const SizedBox(height: 40),
                    ErrorState(message: _error),
                    const SizedBox(height: 16),
                    Center(
                      child: FilledButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            : _buildContent(context),
  );
}

  Widget _buildContent(BuildContext context) {
    final b = _building!;
    final hasImage = b.imageUrl.isNotEmpty;
    // Prefer rooms fetched from the rooms API; fall back to building.rooms
    final sourceRooms = _rooms.isNotEmpty ? _rooms : b.rooms;
    final filtered = _filteredRooms(sourceRooms);
    return Stack(
      children: [
        // Back layer: header image filling the top portion
        SizedBox(
          height: headerHeight,
          width: double.infinity,
          child: hasImage
              ? Image.network(
                  b.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _imgPlaceholder(),
                )
              : _imgPlaceholder(),
        ),
        // Foreground: scrollable content that starts after the header
        RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Spacer to push content below the header, letting the rounded
              // top overlap the image nicely by `topRadius`.
              SliverToBoxAdapter(
                child: SizedBox(height: headerHeight - topRadius),
              ),
              // Rounded body that sits on top of the image
              SliverToBoxAdapter(
                child: Material(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(topRadius)),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16),
                            const SizedBox(width: 6),
                            Expanded(child: Text(b.address)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.apartment, size: 16),
                            const SizedBox(width: 6),
                            Text('${b.floor} floors, ${b.unit} parking spaces'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _roomSearchCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Search Room',
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 48,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                onPressed: () async {
                                  // Open the Add Room form and always refresh on return
                                  await Get.to(() => AddRoomView(buildingId: b.id));
                                  await _load();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final label in const [
                              'All',
                              'Available',
                              'Unpaid',
                              'Pending',
                              'Paid',
                            ])
                              ChoiceChip(
                                label: Text(label),
                                selected: _activeFilter == label,
                                onSelected: (_) =>
                                    setState(() => _activeFilter = label),
                                showCheckmark: false,
                                selectedColor: AppColors.primaryColor,
                                labelStyle: TextStyle(
                                  color: _activeFilter == label
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                backgroundColor: Colors.grey[100],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              // Rooms
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No rooms found',
                    subtitle:
                        'Try adding a room or changing the search or filter above.',
                  ),
                )
              else
                SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final r = filtered[i];

                    // Extract fields in a way that works for both domain objects
                    // (`RoomModel`) and raw Map responses from the API.
                    String roomNumber;
                    String roomFloor;
                    String statusRaw;

                    if (r is Map<String, dynamic>) {
                      roomNumber = (r['room_number'] ?? r['roomNumber'] ?? r['name'] ?? '').toString();
                      roomFloor = (r['floor'] ?? '').toString();
                      statusRaw = (r['status'] ?? '').toString();
                    } else {
                      roomNumber = (r.roomNumber ?? r.name ?? '').toString();
                      roomFloor = (r.floor ?? '').toString();
                      statusRaw = (r.status ?? '').toString();
                    }

                    final statusLabel = _deriveStatusLabel(statusRaw);
                    // Normalise floor label to two digits (fallback to building floor)
                    final floorLabel = (roomFloor.isNotEmpty ? roomFloor : b.floor.toString()).padLeft(2, '0');

                    return _RoomCard(
                      roomName: roomNumber,
                      floorLabel: floorLabel,
                      status: statusLabel,
                      onTap: () async {
                        // Navigate to room detail view (supports Map or domain model) and always refresh when back
                        await Get.to(() => RoomDetailView(room: r));
                        await _load();
                      },
                      onMenuSelected: (value) async {
                        // Actions for menu.
                        if (value == 'edit') {
                          await Get.to(() => EditRoomView(room: r));
                          await _load();
                        } else if (value == 'delete') {
                          await _confirmAndDelete(r);
                        }
                      },
                    );
                  },
                ),
              // Pagination: numbered page buttons and fast-forward
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // compute a window of pages to show
                        Builder(builder: (ctx) {
                          // Hide pagination when using building-specific rooms
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Top-left back button overlayed above the image
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
                child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.35),
                ),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<dynamic> _filteredRooms(List<dynamic> rooms) {
    final q = _roomSearchCtrl.text.trim().toLowerCase();
    return rooms.where((r) {
      final String name;
      if (r is Map<String, dynamic>) {
        name = ((r['room_number'] ?? r['name'] ?? '')).toString().toLowerCase();
      } else {
        name = (r.roomNumber ?? '').toString().toLowerCase();
      }

      final String status;
      if (r is Map<String, dynamic>) {
        status = ((r['status'] ?? '')).toString().toLowerCase();
      } else {
        status = (r.status ?? '').toString().toLowerCase();
      }

      final matchesQuery = q.isEmpty || name.contains(q);
      final label = _deriveStatusLabel(status);
      final matchesFilter = _activeFilter == 'All' || label == _activeFilter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  String _deriveStatusLabel(String status) {
    final s = status.toLowerCase();
    if (s.contains('available')) return 'Available';
    if (s.contains('unpaid')) return 'Unpaid';
    if (s.contains('pending')) return 'Pending';
    if (s.contains('paid')) return 'Paid';
    // Default fallbacks: non-available seen as Paid for now
    return 'Paid';
  }

  Future<void> _confirmAndDelete(dynamic r) async {
    int? roomId;
    String roomName = '';

    if (r is Map<String, dynamic>) {
      final idVal = r['id'] ?? r['room_id'] ?? r['roomId'];
      roomId = idVal != null ? int.tryParse(idVal.toString()) : null;
      roomName = (r['room_number'] ?? r['roomNumber'] ?? r['name'] ?? '').toString();
    } else {
      roomId = r.id;
      roomName = (r.roomNumber ?? r.name ?? '').toString();
    }

    if (roomId == null) {
      Get.snackbar('Error', 'Unable to determine room id');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: 'Delete Room',
        content: Text('Delete room "$roomName"? This action cannot be undone.'),
        cancelLabel: 'Cancel',
        confirmLabel: 'Delete',
        confirmDestructive: true,
      ),
    );

    if (confirmed != true) return;

    try {
      final svc = RoomFetchService();
      await svc.deleteRoom(roomId);

      // Re-fetch the building so we get the authoritative rooms list
      // (this avoids falling back to a stale `building.rooms`).
      await _load();

      Get.snackbar('Deleted', 'Room deleted');
    } catch (e) {
      dev.log('[Rooms] delete failed: $e');
      Get.snackbar('Error', 'Failed to delete room: $e');
    } finally {
      if (mounted) {}
    }
  }
  Widget _imgPlaceholder() => Container(
    color: Colors.grey.shade300,
    child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.primaryColor)),
  );
}

// Reusable room card widget matching target design.
class _RoomCard extends StatelessWidget {
  final String roomName;
  final String floorLabel;
  final String status; // Normalized status label
  final VoidCallback? onTap;
  final ValueChanged<String>? onMenuSelected;

  const _RoomCard({
    required this.roomName,
    required this.floorLabel,
    required this.status,
    this.onTap,
    this.onMenuSelected,
  });

  Color get _statusBg {
    switch (status) {
      case 'Available':
        return const Color(0xFFE3F2FD);
      case 'Unpaid':
        return const Color(0xFFFDECEA);
      case 'Pending':
        return const Color(0xFFFFF4E5);
      case 'Paid':
        return AppColors.primaryColor.withOpacity(0.12);
      default:
        return AppColors.primaryColor.withOpacity(0.12);
    }
  }

  Color get _statusText {
    switch (status) {
      case 'Available':
        return const Color(0xFF0D47A1);
      case 'Unpaid':
        return const Color(0xFFB71C1C);
      case 'Pending':
        return const Color(0xFFEF6C00);
      case 'Paid':
        return AppColors.primaryColor;
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bed_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Room : $roomName',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Floor  : $floorLabel',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _statusText,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  onSelected: onMenuSelected,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  icon: const Icon(Icons.more_vert, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
