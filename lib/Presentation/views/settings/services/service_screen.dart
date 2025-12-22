import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:app/Presentation/provider/settings/service_provider.dart';
import 'widgets/service_card.dart';
import 'package:app/Presentation/widgets/confirm_action_dialog.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final state = context.read<ServiceState>();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Add Service',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: _inputDecoration('Name'),
                maxLength: 255,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: priceCtrl,
                decoration: _inputDecoration('Unit Price (optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descCtrl,
                decoration: _inputDecoration('Description (optional)'),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameCtrl.text.trim();
              final price = priceCtrl.text.trim().isEmpty
                  ? null
                  : double.tryParse(priceCtrl.text.trim());
              final desc = descCtrl.text.trim().isEmpty
                  ? null
                  : descCtrl.text.trim();
              await state.add(name, price, desc);
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ServiceState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Services',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _showAddDialog(context),
              child: const Text(
                'Add Service',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set up your price charge here',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ServiceCard(
                    title: item.name,
                    subtitleLeft: item.unitPrice != null ? 'Price' : '',
                    subtitleRight: item.unitPrice != null
                        ? '\$${item.unitPrice!.toStringAsFixed(2)}'
                        : '-',
                    onTap: () async {
                      // simple edit flow
                      final nameCtrl = TextEditingController(text: item.name);
                      final priceCtrl = TextEditingController(
                        text: item.unitPrice?.toString() ?? '',
                      );
                      final descCtrl = TextEditingController(
                        text: item.description ?? '',
                      );
                      final formKey = GlobalKey<FormState>();
                      final state = context.read<ServiceState>();

                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Edit Service'),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                  ),
                                  maxLength: 255,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Name required'
                                      : null,
                                ),
                                TextFormField(
                                  controller: priceCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Unit Price (optional)',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                TextFormField(
                                  controller: descCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Description (optional)',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                final updated = item.copyWith(
                                  name: nameCtrl.text.trim(),
                                  unitPrice: priceCtrl.text.trim().isEmpty
                                      ? null
                                      : double.tryParse(priceCtrl.text.trim()),
                                  description: descCtrl.text.trim().isEmpty
                                      ? null
                                      : descCtrl.text.trim(),
                                );
                                await state.update(updated);
                                Get.back();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                    onLongPress: () async {
                      final prov = context.read<ServiceState>();
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => ConfirmActionDialog(
                          title: 'Delete service?',
                          content: Text('Are you sure you want to delete "${item.name}"?'),
                          cancelLabel: 'Cancel',
                          confirmLabel: 'Delete',
                          confirmDestructive: true,
                        ),
                      );
                      if (confirm == true) await prov.delete(item.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
    ),
  );
}
