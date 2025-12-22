import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/data/services/setting_service.dart';
import 'package:app/data/dto/setting_dto.dart';
import 'package:app/data/services/auth_service/auth_service.dart';

// Editable meter prices form: supports create (POST) and update (PATCH)

class MeterPricesView extends StatefulWidget {
  const MeterPricesView({super.key});

  @override
  State<MeterPricesView> createState() => _MeterPricesViewState();
}

class _MeterPricesViewState extends State<MeterPricesView> {
  final SettingService _svc = ApiSettingService();
  SettingDto? _setting;
  bool _loading = true;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  final _waterCtrl = TextEditingController();
  final _electricityCtrl = TextEditingController();
  final _khrCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final landlordId = await AuthService().getLandlordId();
      if (landlordId == null) throw Exception('No landlord id');
      final s = await _svc.fetchSettings(landlordId);
      if (!mounted) return;
      setState(() {
        _setting = s;
        _waterCtrl.text = s.waterPrice?.toString() ?? '';
        _electricityCtrl.text = s.electricityPrice?.toString() ?? '';
        _khrCtrl.text = s.khrCurrency.toString();
        _taxCtrl.text = s.tax.toString();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Meter Prices', style: TextStyle(color: Colors.black)),
        actions: [
          if (_setting != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _submitting ? null : _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? Center(child: Text('Error: \$_error'))
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Meter Prices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _waterCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(labelText: 'Water price (per unit)'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _electricityCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(labelText: 'Electricity price (per unit)'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Meta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _khrCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(labelText: 'KHR currency rate'),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _taxCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(labelText: 'Tax'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _submitting ? null : _load,
                                child: const Text('Reload'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _save,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                                child: _submitting ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator()) : const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final landlordId = await AuthService().getLandlordId();
      if (landlordId == null) throw Exception('No landlord id');

      final payload = <String, dynamic>{
        'water_price': double.tryParse(_waterCtrl.text.trim()) ?? 0.0,
        'electricity_price': double.tryParse(_electricityCtrl.text.trim()) ?? 0.0,
        'khr_currency': double.tryParse(_khrCtrl.text.trim()) ?? 0.0,
        'tax': double.tryParse(_taxCtrl.text.trim()) ?? 0.0,
      };

      if (_setting == null) {
        // create
        payload['user_id'] = landlordId;
        final created = await _svc.createSettings(payload);
        setState(() => _setting = created);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings created')));
      } else {
        final updated = await _svc.updateSettings(landlordId, payload);
        setState(() => _setting = updated);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings updated')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _delete() async {
    final landlordId = await AuthService().getLandlordId();
    if (landlordId == null) return;
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Delete settings?'),
      content: const Text('This will remove meter prices and metadata.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
      ],
    ));
    if (ok != true) return;
    setState(() => _submitting = true);
    try {
      await _svc.deleteSettings(landlordId);
      setState(() {
        _setting = null;
        _waterCtrl.text = '';
        _electricityCtrl.text = '';
        _khrCtrl.text = '';
        _taxCtrl.text = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _waterCtrl.dispose();
    _electricityCtrl.dispose();
    _khrCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }
}
