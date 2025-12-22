// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/settings/room_type_provider.dart';
import 'package:get/get.dart';
import 'package:app/Presentation/widgets/confirm_action_dialog.dart';

class RoomTypeView extends StatelessWidget {
  const RoomTypeView({super.key});

  static const routeName = '/room-types';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomTypeState()..load(),
      child: const _RoomTypeScreen(),
    );
  }
}

class _RoomTypeScreen extends StatelessWidget {
  const _RoomTypeScreen();

  Future<void> _showAddDialog(BuildContext context) async {
    final state = context.read<RoomTypeState>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Room Type'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Room Type Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await state.add(
                nameCtrl.text.trim(),
                descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
              );
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
    final state = context.watch<RoomTypeState>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Room Types'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () => _showAddDialog(context),
            child: const Text(
              'Add',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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
                // ignore: unnecessary_underscores
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final prov = context.read<RoomTypeState>();
                  return Card(
                    child: ListTile(
                      title: Text(item.roomTypeName),
                      subtitle: item.description != null
                          ? Text(item.description!)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final nameCtrl = TextEditingController(
                                text: item.roomTypeName,
                              );
                              final descCtrl = TextEditingController(
                                text: item.description ?? '',
                              );
                              final formKey = GlobalKey<FormState>();
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
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () async {
                                        if (!formKey.currentState!.validate())
                                          return;
                                        final updated = item.copyWith(
                                          roomTypeName: nameCtrl.text.trim(),
                                          description:
                                              descCtrl.text.trim().isEmpty
                                              ? null
                                              : descCtrl.text.trim(),
                                        );
                                        await prov.update(updated);
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => ConfirmActionDialog(
                                  title: 'Delete room type?',
                                  content: Text('Delete "${item.roomTypeName}"?'),
                                  cancelLabel: 'Cancel',
                                  confirmLabel: 'Delete',
                                  confirmDestructive: true,
                                ),
                              );
                              if (confirm == true) await prov.delete(item.id);
                            },
                          ),
                        ],
                      ),
                    ),
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
