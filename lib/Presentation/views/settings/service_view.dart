import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/settings/service_provider.dart';

class ServiceView extends StatelessWidget {
  const ServiceView({Key? key}) : super(key: key);

  static const routeName = '/services';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceState()..load(),
      child: const _ServiceScreen(),
    );
  }
}

class _ServiceScreen extends StatelessWidget {
  const _ServiceScreen({Key? key}) : super(key: key);

  Future<void> _showAddDialog(BuildContext context) async {
    final state = context.read<ServiceState>();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Service'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                maxLength: 255,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              TextFormField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Unit Price (optional)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameCtrl.text.trim();
              final price = priceCtrl.text.trim().isEmpty ? null : double.tryParse(priceCtrl.text.trim());
              final desc = descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim();
              await state.add(name, price, desc);
              Navigator.of(ctx).pop();
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
          onPressed: () => Navigator.of(context).pop(),
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
              child: const Text('Add Service', style: TextStyle(color: Colors.black87)),
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
            const Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Set up your price charge here', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            if (state.isLoading) const LinearProgressIndicator(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(state.error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _ServiceCard(
                    title: item.name,
                    subtitleLeft: item.unitPrice != null ? 'Price' : '',
                    subtitleRight: item.unitPrice != null ? '\$${item.unitPrice!.toStringAsFixed(2)}' : '-',
                    onTap: () async {
                      // simple edit flow
                      final nameCtrl = TextEditingController(text: item.name);
                      final priceCtrl = TextEditingController(text: item.unitPrice?.toString() ?? '');
                      final descCtrl = TextEditingController(text: item.description ?? '');
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
                                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), maxLength: 255, validator: (v) => (v==null||v.trim().isEmpty)?'Name required':null),
                                TextFormField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Unit Price (optional)'), keyboardType: TextInputType.number),
                                TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (optional)')),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                            FilledButton(onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final updated = item.copyWith(
                                name: nameCtrl.text.trim(),
                                unitPrice: priceCtrl.text.trim().isEmpty?null:double.tryParse(priceCtrl.text.trim()),
                                description: descCtrl.text.trim().isEmpty?null:descCtrl.text.trim(),
                              );
                              await state.update(updated);
                              Navigator.of(ctx).pop();
                            }, child: const Text('Save')),
                          ],
                        ),
                      );
                    },
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Delete service?'),
                          content: Text('Are you sure you want to delete "${item.name}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirm == true) await context.read<ServiceState>().delete(item.id);
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

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitleLeft;
  final String subtitleRight;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ServiceCard({
    Key? key,
    required this.title,
    required this.subtitleLeft,
    required this.subtitleRight,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inbox_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(subtitleLeft, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(width: 12),
                        Text(subtitleRight, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
