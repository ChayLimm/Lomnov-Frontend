import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/data/implementations/building/building_implementation.dart';
import 'package:flutter/material.dart';
import 'package:app/Presentation/widgets/search_bar.dart';
import 'package:app/Presentation/views/buildings/widgets/building_card.dart';
import 'package:app/Presentation/widgets/error1.dart';
import 'package:app/Presentation/widgets/empty1.dart';
import 'package:get/get.dart';
import 'package:app/Presentation/views/buildings/add_building_view.dart';
import 'package:app/Presentation/views/buildings/building_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/widgets/confirm_action_dialog.dart';

class BuildingsView extends StatefulWidget {
  const BuildingsView({super.key});

  @override
  State<BuildingsView> createState() => _BuildingsViewState();
}

class _BuildingsViewState extends State<BuildingsView> {
  final _repository = BuildingRepositoryImpl();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<BuildingModel> _all = const [];
  bool _onlyAvailable = false;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Use signed-in user id (landlord) so the endpoint returns landlord-specific buildings
      final landlordId = context.read<AuthViewModel>().user?.id;
      final res = await _repository.fetchBuildings(landlordId: landlordId);
      setState(() {
        _all = res;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<BuildingModel> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _all.where((b) {
      final matchesQuery =
          q.isEmpty ||
          b.name.toLowerCase().contains(q) ||
          b.address.toLowerCase().contains(q) ||
          (b.landlord?.name.toLowerCase().contains(q) == true);
      final matchesAvail =
          !_onlyAvailable ||
          b.rooms.any((r) => r.status.toLowerCase() == 'available');
      return matchesQuery && matchesAvail;
    }).toList();
  }

  void _openFilterSheet() async {
    bool tempOnlyAvailable = _onlyAvailable;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Only buildings with available rooms'),
                      value: tempOnlyAvailable,
                      onChanged: (v) {
                        setModalState(() {
                          tempOnlyAvailable = v;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (mounted) {
                          setState(() => _onlyAvailable = tempOnlyAvailable);
                        }
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onAddBuilding() {
    // Get logged-in user id to prefill landlord field
    final landlordId = context.read<AuthViewModel>().user?.id;
    // Navigate to AddBuildingView; refresh list on success
    Get.to(() => AddBuildingView(initialLandlordId: landlordId))?.then((
      result,
    ) {
      if (result != null) {
        // If a building was created, reload list
        _load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();
    // Reserve extra scroll space at the bottom so the floating/bottom nav
    // doesn't cover the last card. This keeps the nav overlaying content
    // while allowing users to scroll the final item fully into view.
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final extraScrollPadding = kBottomNavigationBarHeight + bottomSafe ;
    return PopScope(
      canPop: canGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // If there is no back stack (e.g., web refresh), send user to home
        Get.offAllNamed('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFFFFFFF),
          scrolledUnderElevation: 0,
          leading: canGoBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).maybePop();
                    } else {
                      Get.offAllNamed('/home');
                    }
                  },
                  tooltip: 'Back',
                )
              : null,
          title: const Text('Buildings'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SearchBarWithFilter(
                      controller: _searchCtrl,
                      onFilterTap: _openFilterSheet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: AppColors.primaryGradient,
                      ),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        onPressed: _onAddBuilding,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search and Add moved into AppBar bottom
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(message: _error),
                )
              else if (_filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No buildings found',
                    subtitle: 'Try adjusting filters or add a building.',
                  ),
                )
              else
                ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final building = _filtered[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BuildingCard(
                            building: building,
                            onTap: () {
                              final id = building.id;
                              Get.to(() => BuildingDetailView(buildingId: id));
                            },
                            onEdit: () async {
                              final BuildingModel? updated =
                                  await Get.to<BuildingModel>(
                                    () => AddBuildingView(
                                      editingBuildingId: building.id,
                                      editingName: building.name,
                                      editingAddress: building.address,
                                      editingImageUrl: building.imageUrl.isEmpty
                                          ? null
                                          : building.imageUrl,
                                      editingFloor: building.floor,
                                      editingUnit: building.unit,
                                      initialLandlordId: building.landlord?.id,
                                    ),
                                  );
                              if (updated != null && mounted) {
                                setState(() {
                                  // Replace in _all by id so filters recompute
                                  _all = _all
                                      .map(
                                        (b) => b.id == updated.id ? updated : b,
                                      )
                                      .toList();
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Building updated'),
                                    ),
                                  );
                                }
                              }
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                barrierDismissible: true,
                                builder: (ctx) => ConfirmActionDialog(
                                  title: 'Delete building?',
                                  content: Text('Are you sure you want to delete "${building.name}"? This action cannot be undone.'),
                                  cancelLabel: 'Cancel',
                                  confirmLabel: 'Delete',
                                  confirmDestructive: true,
                                ),
                              );
                              if (confirm != true) return;

                              // show progress indicator
                              if (!context.mounted) return;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              try {
                                await _repository.deleteBuilding(building.id);
                                // remove from local list and refresh UI
                                if (mounted) {
                                  setState(() {
                                    _all = _all
                                        .where((b) => b.id != building.id)
                                        .toList();
                                  });
                                }
                                if (!context.mounted) return;
                                Navigator.of(context).pop(); // close progress
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Building deleted successfully',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                Navigator.of(context).pop(); // close progress
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }, childCount: _filtered.length),
                  ),
                  // Extra space so the floating/bottom nav doesn't cover
                  // the last item. Keeps UX consistent across devices.
                  SliverToBoxAdapter(
                    child: SizedBox(height: extraScrollPadding),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
