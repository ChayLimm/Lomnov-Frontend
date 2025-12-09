import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:app/Presentation/provider/settings/room_type_provider.dart';
import 'widgets/room_type_card.dart';

class RoomTypeScreen extends StatelessWidget {
  const RoomTypeScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final state = context.read<RoomTypeState>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Add Room Type',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: _inputDecoration('Room Type Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
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
              await state.add(
                nameCtrl.text.trim(),
                descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
              );
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
    final state = context.watch<RoomTypeState>();

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
          'Room Types',
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
                'Add Room Type',
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
              'Room Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your room type presets',
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
                  return RoomTypeCard(
                    title: item.roomTypeName,
                    description: item.description ?? '-',
                    onTap: () async {
                      final nameCtrl = TextEditingController(
                        text: item.roomTypeName,
                      );
                      final descCtrl = TextEditingController(
                        text: item.description ?? '',
                      );
                      final formKey = GlobalKey<FormState>();
                      final prov = context.read<RoomTypeState>();
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Edit Room Type'),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Room Type Name',
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
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
                                  roomTypeName: nameCtrl.text.trim(),
                                  description: descCtrl.text.trim().isEmpty
                                      ? null
                                      : descCtrl.text.trim(),
                                );
                                await prov.update(updated);
                                Get.back();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                    onLongPress: () async {
                      final prov = context.read<RoomTypeState>();
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Delete room type?'),
                          content: Text('Delete "${item.roomTypeName}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Get.back(result: true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await prov.delete(item.id);
                      }
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
