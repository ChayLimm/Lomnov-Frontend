import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/settings/bakong_provider.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/domain/models/bakong_account/bakong_account.dart';

class BakongView extends StatefulWidget {
  final int userId;

  const BakongView({Key? key, required this.userId}) : super(key: key);

  @override
  State<BakongView> createState() => _BakongViewState();
}

class _BakongViewState extends State<BakongView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BakongProvider()..load(userId: widget.userId),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          foregroundColor: AppColors.textPrimary,
          title: const Text('Bakong Accounts', style: TextStyle(color: Colors.black)),
          elevation: 0,
        ),
        body: Consumer<BakongProvider>(builder: (context, prov, _) {
          if (prov.isLoading) return const Center(child: CircularProgressIndicator());
          if (prov.error != null) {
            return RefreshIndicator(
              onRefresh: () => prov.load(userId: widget.userId),
              child: ListView(children: [Padding(padding: const EdgeInsets.all(16.0), child: Text('Failed to load: ${prov.error}'))]),
            );
          }

          final items = prov.items;
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => prov.load(userId: widget.userId),
              child: ListView(children: const [SizedBox(height: 40), Center(child: Text('No Bakong accounts found'))]),
            );
          }

          return RefreshIndicator(
            onRefresh: () => prov.load(userId: widget.userId),
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final acc = items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _BakongAccountForm(
                    account: acc,
                    onSave: (updated) {
                      // update provider locally
                      prov.updateAccount(i, updated);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bakong account saved')));
                    },
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _BakongAccountForm extends StatefulWidget {
  final BakongAccount account;
  final void Function(BakongAccount updated) onSave;

  const _BakongAccountForm({Key? key, required this.account, required this.onSave}) : super(key: key);

  @override
  State<_BakongAccountForm> createState() => _BakongAccountFormState();
}

class _BakongAccountFormState extends State<_BakongAccountForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _locationCtrl;

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    _idCtrl = TextEditingController(text: acc.bakongId);
    _nameCtrl = TextEditingController(text: acc.bakongName);
    _locationCtrl = TextEditingController(text: acc.bakongLocation ?? '');
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    final acc = widget.account;
    final updated = acc.copyWith(
      bakongId: _idCtrl.text.trim(),
      bakongName: _nameCtrl.text.trim(),
      bakongLocation: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
    );
    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bakong Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', filled: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idCtrl,
                decoration: const InputDecoration(labelText: 'Bakong ID', filled: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location', filled: true),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _nameCtrl.text = widget.account.bakongName;
                        _idCtrl.text = widget.account.bakongId;
                        _locationCtrl.text = widget.account.bakongLocation ?? '';
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                      child: const Text('Save'),
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
}
