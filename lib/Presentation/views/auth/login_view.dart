import 'package:app/presentation/provider/auth_viewmodel.dart';
import 'package:app/presentation/themes/app_colors.dart';
import 'package:app/presentation/themes/text_styles.dart';
import 'package:app/presentation/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
                        title: 'LOMNOV',
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Enter your email',
                          suffixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onSubmitted: (_) => _submit(vm),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            onChanged: (v) => setState(() => _remember = v ?? false),
                            activeColor: AppColors.primaryColor,
                          ),
                          const Text('Remember me'),
                          const Spacer(),
                          TextButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Forgot password coming soon')),
                            ),
                            child: const Text('Forgot password?', style: TextStyle(color: AppColors.primaryColor)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (vm.error != null) ...[
                Text(vm.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              GradientButton(
                label: vm.loading ? 'Please wait…' : 'Login',
                loading: vm.loading,
                onPressed: vm.loading ? null : () => _submit(vm),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New member? '),
                  GestureDetector(
                    onTap: vm.loading ? null : () => Get.toNamed('/signup'),
                    child: Text(
                      'Register now',
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
    vm.login(_emailCtrl.text.trim(), _passCtrl.text);
  }
}

class _AuthHeader extends StatelessWidget {
  final String title;
  const _AuthHeader({required this.title});

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
        ],
      ),
    );
  }
}
