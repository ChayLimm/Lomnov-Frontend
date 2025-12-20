import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'package:app/Presentation/views/auth/bakong_setup_view.dart';
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
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;
  bool _agree = false;
  String? _lastVmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    // Show a friendly SnackBar when AuthViewModel reports an error.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final err = vm.error;
      if (err != null && err != _lastVmError) {
        _lastVmError = err;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(err)),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

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
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          suffixIcon: Icon(Icons.phone_outlined),
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
                      TextField(
                        controller: _tokenCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: ' Telegram Token',
                          suffixIcon: Icon(Icons.vpn_key_outlined),
                        ),
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
                label: vm.loading ? 'Please wait…' : ' Next',
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
    // Client-side validations for better user feedback
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    final token = _tokenCtrl.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your full name');
      return;
    }
    if (email.isEmpty || !_isValidEmail(email)) {
      _showMessage('Please enter a valid email address');
      return;
    }
    if (phone.isEmpty || phone.length < 8) {
      _showMessage('Please enter a valid phone number');
      return;
    }
    if (pass.length < 6) {
      _showMessage('Password must be at least 6 characters');
      return;
    }
    if (pass != confirm) {
      _showMessage('Passwords do not match');
      return;
    }
    if (token.isEmpty) {
      _showMessage('Please enter your token');
      return;
    }
    if (!_agree) {
      _showMessage('You must agree to the Terms and Conditions');
      return;
    }

    // Proceed to Bakong step without posting yet
    _lastVmError = null;

    Get.to(
      () => const BakongSetupView(),
      arguments: {
        'name': name,
        'email': email,
        'phonenumber': phone,
        'password': pass,
        'token': token,
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  bool _isValidEmail(String email) {
    final re = RegExp(r"^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}");
    return re.hasMatch(email);
  }

  String _friendlyError(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('email') && l.contains('already')) return 'An account with this email already exists.';
    if (l.contains('email')) return 'There was a problem with the email you provided.';
    if (l.contains('password')) return 'There was a problem with the password you provided.';
    if (l.contains('network') || l.contains('socket') || l.contains('timeout')) return 'Network error. Check your connection and try again.';
    if (l.contains('401') || l.contains('unauthor')) return 'Authentication failed. Please check your credentials.';
    if (l.contains('500') || l.contains('server')) return 'Server error. Please try again later.';
    return raw; // fallback to raw message
  }
}

// Bakong setup page moved to its own file and route: /bakong-setup

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
