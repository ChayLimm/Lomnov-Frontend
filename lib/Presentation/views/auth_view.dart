import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLogin = true;
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isLogin)
                TextField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Passwords'),
                obscureText: true,
                onSubmitted: (_) => _submit(vm),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: vm.loading ? null : () => _submit(vm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    vm.loading
                        ? 'Please wait...'
                        : (isLogin ? 'Login' : 'Create account'),
                  ),
                ),
              ),
              TextButton(
                onPressed: vm.loading
                    ? null
                    : () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login",
                ),
              ),
              const SizedBox(height: 12),
              if (vm.error != null)
                Text(vm.error!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(AuthViewModel vm) {
    if (isLogin) {
      vm.login(emailCtrl.text.trim(), passCtrl.text);
    } else {
      vm.register(nameCtrl.text.trim(), emailCtrl.text.trim(), passCtrl.text);
    }
  }
}
