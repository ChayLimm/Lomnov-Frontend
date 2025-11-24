import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/data/implementations/building/building_implementation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/presentation/widgets/error1.dart';
import 'package:app/presentation/widgets/empty1.dart';
import 'package:app/presentation/themes/app_colors.dart';

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
    extendBodyBehindAppBar: true, // image can go behind the status bar
    body: _loading
        ? const Center(child: CircularProgressIndicator())
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
    final filtered = _filteredRooms(b.rooms);
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
                        Text(
                          'Room list',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
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
                                onPressed: () {
                                  Get.snackbar(
                                    'Coming soon',
                                    'Add Room form not implemented yet',
                                  );
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
                    final statusLabel = _deriveStatusLabel(r.status);
                    final pillColor = _statusColor(statusLabel);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.bed_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Room : ${r.name}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Floor  : ${b.floor.toString().padLeft(2, '0')}',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: pillColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(statusLabel),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
                  backgroundColor: Colors.black.withValues(alpha: 0.35),
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
      final name = (r.name ?? '').toString().toLowerCase();
      final status = (r.status ?? '').toString().toLowerCase();
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

  Color _statusColor(String label) {
    switch (label) {
      case 'Available':
        return Colors.blue.shade100;
      case 'Unpaid':
        return Colors.red.shade100;
      case 'Pending':
        return Colors.orange.shade100;
      case 'Paid':
      default:
        return Colors.green.shade200;
    }
  }

  Widget _imgPlaceholder() => Container(
    color: Colors.grey.shade300,
    child: const Center(child: Icon(Icons.image_not_supported_outlined)),
  );
}
