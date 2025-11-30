import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'package:app/Presentation/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;
  bool _agree = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const _AuthHeader(
                        title: 'Get Started',
                        subtitle: 'by creating a free account.',
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          suffixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Valid email',
                          suffixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmCtrl,
                        obscureText: _obscure2,
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure2 = !_obscure2),
                          ),
                        ),
                        onSubmitted: (_) => _submit(vm),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _agree,
                            onChanged: (v) => setState(() => _agree = v ?? false),
                            activeColor: AppColors.primaryColor,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: LomTextStyles.bodyText(color: AppColors.textSecondary),
                                children: [
                                  const TextSpan(text: 'By checking the box you agree to our '),
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (vm.error != null) ...[
                const SizedBox(height: 8),
                Text(vm.error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 8),
              GradientButton(
                label: vm.loading ? 'Please wait…' : 'Create Account',
                loading: vm.loading,
                onPressed: (!vm.loading && _agree) ? () => _submit(vm) : null,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already a member? '),
                  GestureDetector(
                    onTap: vm.loading ? null : () => Get.back(),
                    child: Text(
                      'Login in',
                      style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(AuthViewModel vm) {
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    vm.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
  }
}

class _AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _AuthHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Image.asset(
                  'lib/assets/images/lomnov-logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: LomTextStyles.headline1(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: LomTextStyles.bodyText(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            )
          ]
        ],
      ),
    );
  }
}
