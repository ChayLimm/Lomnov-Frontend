import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/data/services/setting_service.dart';
import 'package:app/data/dto/setting_dto.dart';
import 'package:app/data/services/auth_service/auth_service.dart';

// Editable Rules & Regulations form: supports create (POST) and update (PATCH)

class RulesRegulationsView extends StatefulWidget {
  const RulesRegulationsView({super.key});

  @override
  State<RulesRegulationsView> createState() => _RulesRegulationsViewState();
}

class _RulesRegulationsViewState extends State<RulesRegulationsView> {
  final SettingService _svc = ApiSettingService();
  SettingDto? _setting;
  bool _loading = true;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  final _generalCtrl = TextEditingController();
  final _contractCtrl = TextEditingController();
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
        _generalCtrl.text = s.generalRules ?? '';
        _contractCtrl.text = s.contractRules ?? '';
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
        title: const Text('Rules & Regulations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? Center(child: Text('Error: \$_error'))
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
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
                                  const Text('General Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _generalCtrl,
                                    maxLines: 5,
                                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'General rules'),
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
                                  const Text('Contract Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _contractCtrl,
                                    maxLines: 5,
                                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contract rules'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    try {
      final landlordId = await AuthService().getLandlordId();
      if (landlordId == null) throw Exception('No landlord id');

      final payload = <String, dynamic>{
        'general_rules': _generalCtrl.text.trim(),
        'contract_rules': _contractCtrl.text.trim(),
      };

      if (_setting == null) {
        payload['user_id'] = landlordId;
        final created = await _svc.createSettings(payload);
        setState(() => _setting = created);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rules created')));
      } else {
        final updated = await _svc.updateSettings(landlordId, payload);
        setState(() => _setting = updated);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rules updated')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _generalCtrl.dispose();
    _contractCtrl.dispose();
    super.dispose();
  }
}
