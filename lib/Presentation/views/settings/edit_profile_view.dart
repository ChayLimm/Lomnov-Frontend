import 'package:app/presentation/provider/auth_viewmodel.dart';
import 'package:app/presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    final user = auth.user;
    _nameController = TextEditingController(text: user?.name ?? '');
  // Fallback: use email as placeholder if phone not available
  _phoneController = TextEditingController(text: user?.email ?? '');
    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() => _dirty = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.user;

    if (user == null) {
      // If not logged in, go back or to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text('Profile Picture', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person, color: AppColors.primaryColor, size: 36)
                        : ClipOval(
                            child: Image.network(
                              user.avatarUrl!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primaryColor, size: 36),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Material(
                      color: AppColors.primaryColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          // TODO: implement avatar picker
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Username', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 6),
            _InputBox(
              controller: _nameController,
              hint: 'Enter username',
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Phone Number', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 6),
            _InputBox(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              hint: 'Enter phone number',
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _dirty ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.textDisabled,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Change'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _save() {
    // TODO: integrate with backend update
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved')));
    setState(() => _dirty = false);
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  const _InputBox({required this.controller, this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.dividerColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}