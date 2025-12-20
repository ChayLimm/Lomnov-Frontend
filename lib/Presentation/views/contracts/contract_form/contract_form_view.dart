import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:app/Presentation/themes/app_colors.dart';

import 'package:app/data/services/contract_service/contract_service.dart';
import 'package:app/Presentation/provider/tenant_list_viewmodel.dart';
import 'package:app/domain/models/contract/tenant_model.dart';

class ContractFormView extends StatefulWidget {
  final int? roomId;
  final dynamic contract; // Can be ContractModel or Map<String, dynamic>

  const ContractFormView({super.key, this.roomId, this.contract});

  bool get isEdit => contract != null; // Edit if contract provided

  @override
  State<ContractFormView> createState() => _ContractFormViewState();
}

class _ContractFormViewState extends State<ContractFormView> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdCtrl = TextEditingController();
  final _tenantIdCtrl = TextEditingController();
  TenantListViewModel? _tenantListVM;
  TenantModel? _selectedTenant;
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();

  bool _submitting = false;
  bool _loadingActive = false;
  Map<String, dynamic>? _activeContractMap; // if fetched

  @override
  void initState() {
    super.initState();
    // For demo, landlordId is hardcoded as 1. Replace as needed.
    _tenantListVM = TenantListViewModel(landlordId: 1);
    _tenantListVM!.fetchTenants().then((_) {
      // If editing, preselect tenant
      if (widget.isEdit) {
        final c = widget.contract;
        int? tid;
        if (c is Map<String, dynamic>) {
          tid = int.tryParse((c['tenant_id'] ?? c['tenantId'] ?? c['user_id'] ?? '').toString());
        } else {
          try { tid = c.tenantId ?? c.userId; } catch (_) {}
        }
        if (tid != null) {
          TenantModel? found;
          if (_tenantListVM!.tenants.isNotEmpty) {
            found = _tenantListVM!.tenants.firstWhere(
              (t) => t.id == tid,
              orElse: () => _tenantListVM!.tenants.first,
            );
          } else {
            found = null;
          }
          if (found != null) {
            setState(() {
              _selectedTenant = found;
              _tenantIdCtrl.text = found?.id.toString() ?? '';
            });
          }
        }
      }
    });
    if (widget.isEdit) {
      final c = widget.contract;
      if (c is Map<String, dynamic>) {
        _roomIdCtrl.text = (c['room_id'] ?? c['roomId'] ?? '').toString();
        _startDateCtrl.text = (c['start_date'] ?? c['startDate'] ?? '').toString();
        _endDateCtrl.text = (c['end_date'] ?? c['endDate'] ?? '').toString();
        _depositCtrl.text = (c['deposit_amount'] ?? c['depositAmount'] ?? '').toString();
        _statusCtrl.text = (c['status'] ?? '').toString();
      } else {
        try {
          _roomIdCtrl.text = (c.roomId ?? '').toString();
          _startDateCtrl.text = (c.startDate ?? '').toString();
          _endDateCtrl.text = (c.endDate ?? '').toString();
          _depositCtrl.text = (c.depositAmount ?? '').toString();
          _statusCtrl.text = (c.status ?? '').toString();
        } catch (_) {}
      }
    } else {
      if (widget.roomId != null) {
        _roomIdCtrl.text = widget.roomId!.toString();
        _fetchActiveContract(widget.roomId!);
      }
    }
  }

  Future<void> _fetchActiveContract(int roomId) async {
    setState(() => _loadingActive = true);
    try {
      final svc = ContractService();
      final dto = await svc.fetchActiveContract(roomId);
      if (dto != null) {
        // Save a minimal map to reuse id in submit
        _activeContractMap = {'id': dto.id};
        // Prefill controllers and switch to edit-like state using DTO fields
        _roomIdCtrl.text = dto.roomId.toString();
        _tenantIdCtrl.text = dto.tenantId.toString();
        _startDateCtrl.text = dto.startDate;
        _endDateCtrl.text = dto.endDate ?? '';
        _depositCtrl.text = dto.depositAmount.toString();
        _statusCtrl.text = dto.status;
      }
    } catch (e) {
      dev.log('[ContractForm] fetchActive failed: $e');
    } finally {
      if (mounted) setState(() => _loadingActive = false);
    }
  }

  @override
  void dispose() {
    _roomIdCtrl.dispose();
    _tenantIdCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _depositCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryColor) : null,
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

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final initial = controller.text.isNotEmpty ? DateTime.tryParse(controller.text) ?? now : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().substring(0, 10);
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final payload = <String, dynamic>{
      'room_id': int.tryParse(_roomIdCtrl.text.trim()),
      'tenant_id': int.tryParse(_tenantIdCtrl.text.trim()),
      'start_date': _startDateCtrl.text.trim(),
      'end_date': _endDateCtrl.text.trim().isEmpty ? null : _endDateCtrl.text.trim(),
      'deposit_amount': _depositCtrl.text.trim().isEmpty ? null : double.tryParse(_depositCtrl.text.trim()),
      'status': _statusCtrl.text.trim(),
    };

    try {
      final svc = ContractService();
      final bool editing = widget.isEdit || _activeContractMap != null;
      if (editing) {
        int? id;
        if (widget.contract is Map<String, dynamic>) {
          id = int.tryParse(((widget.contract as Map<String, dynamic>)['id'] ?? '').toString());
        } else if (widget.contract != null) {
          try { id = widget.contract.id as int?; } catch (_) {}
        }
        id ??= int.tryParse((_activeContractMap?['id'] ?? '').toString());
        if (id == null) throw Exception('Missing contract id');
        await svc.updateContract(id, payload);
        if (!mounted) return;
        Get.back(result: true);
        Get.snackbar('Updated', 'Contract updated');
      } else {
        final created = await svc.createContract(payload);
        dev.log('[Contract] created id=${created?['id']}');
        if (!mounted) return;
        Get.back(result: true);
        Get.snackbar('Created', 'Contract created', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      dev.log('[Contract] submit failed: $e');
      if (mounted) Get.snackbar('Error', 'Failed to submit: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text((widget.isEdit || _activeContractMap != null) ? 'Edit Contract' : 'Add Contract'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_loadingActive)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
                TextFormField(
                  controller: _roomIdCtrl,
                  decoration: _fieldDecoration('Room ID', icon: Icons.meeting_room_outlined),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null) return 'Required numeric';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _tenantListVM!,
                  builder: (context, _) {
                    if (_tenantListVM!.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(),
                      );
                    }
                    if (_tenantListVM!.tenants.isEmpty) {
                      return Text('No tenants found', style: TextStyle(color: Colors.red));
                    }
                    return DropdownButtonFormField<TenantModel>(
                      value: _selectedTenant,
                      items: _tenantListVM!.tenants
                          .map((t) => DropdownMenuItem<TenantModel>(
                                value: t,
                                child: Text(t.name),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedTenant = val;
                          _tenantIdCtrl.text = val?.id.toString() ?? '';
                        });
                      },
                      decoration: _fieldDecoration('Tenant', icon: Icons.person_outline),
                      validator: (v) {
                        if (_tenantIdCtrl.text.isEmpty) return 'Select tenant';
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _pickDate(_startDateCtrl),
                    child: InputDecorator(
                      decoration: _fieldDecoration('Start Date', icon: Icons.event_outlined),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _startDateCtrl.text.isEmpty ? 'Select date' : _startDateCtrl.text,
                              style: TextStyle(color: _startDateCtrl.text.isEmpty ? Colors.grey : Colors.black87),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryColor),
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
                    onTap: () => _pickDate(_endDateCtrl),
                    child: InputDecorator(
                      decoration: _fieldDecoration('End Date', icon: Icons.event_available_outlined),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _endDateCtrl.text.isEmpty ? 'Select date (optional)' : _endDateCtrl.text,
                              style: TextStyle(color: _endDateCtrl.text.isEmpty ? Colors.grey : Colors.black87),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _depositCtrl,
                  decoration: _fieldDecoration('Deposit Amount', icon: Icons.attach_money_outlined),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final d = double.tryParse(v.trim());
                    if (d == null) return 'Invalid number';
                    if (d < 0) return 'Must be >= 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      const statuses = ['active', 'pending', 'completed', 'cancelled'];
                      int initialIndex = 0;
                      if (_statusCtrl.text.isNotEmpty) {
                        final idx = statuses.indexOf(_statusCtrl.text);
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(tempIndex),
                                          child: Text('Done', style: TextStyle(color: AppColors.primaryColor)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 0),
                                  Expanded(
                                    child: CupertinoPicker(
                                      scrollController: FixedExtentScrollController(initialItem: initialIndex),
                                      itemExtent: 40,
                                      onSelectedItemChanged: (i) => tempIndex = i,
                                      children: statuses.map((s) => Center(child: Text(s))).toList(),
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
                    },
                    child: InputDecorator(
                      decoration: _fieldDecoration('Status', icon: Icons.info_outline),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _statusCtrl.text.isEmpty ? 'Select Status' : _statusCtrl.text,
                              style: TextStyle(color: _statusCtrl.text.isEmpty ? Colors.grey : Colors.black87),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primaryColor),
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
