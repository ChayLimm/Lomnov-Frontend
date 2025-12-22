import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:app/Presentation/provider/settings/role_provider.dart';
import '../services/widgets/service_card.dart';
import 'package:app/Presentation/widgets/confirm_action_dialog.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final state = context.read<RoleState>();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Role'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Role Name'),
            maxLength: 255,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await state.add(nameCtrl.text.trim());
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
    final state = context.watch<RoleState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text('Roles', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _showAddDialog(context),
              child: const Text('Add Role', style: TextStyle(color: Colors.black87)),
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
            const Text('Roles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Manage user roles and assignments', style: TextStyle(color: Colors.black54)),
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
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ServiceCard(
                    title: item.roleName,
                    subtitleLeft: 'Users',
                    subtitleRight: item.users.length.toString(),
                    onTap: () async {
                      final nameCtrl = TextEditingController(text: item.roleName);
                      final formKey = GlobalKey<FormState>();
                      final state = context.read<RoleState>();

                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Edit Role'),
                          content: Form(
                            key: formKey,
                            child: TextFormField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(labelText: 'Role Name'),
                              maxLength: 255,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                            FilledButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                await state.update(item, nameCtrl.text.trim());
                                Get.back();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                    onLongPress: () async {
                      final prov = context.read<RoleState>();
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => ConfirmActionDialog(
                          title: 'Delete role?',
                          content: Text('Are you sure you want to delete "${item.roleName}"?'),
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
