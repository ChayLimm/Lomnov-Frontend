import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'water_meter_price_view.dart';

class RegisterTelegramTokenView extends StatefulWidget {
  const RegisterTelegramTokenView({super.key});

  @override
  State<RegisterTelegramTokenView> createState() => _RegisterTelegramTokenViewState();
}

class _RegisterTelegramTokenViewState extends State<RegisterTelegramTokenView> {
  final _tokenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    // No-op; args will be forwarded after token input
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
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
                            'lib/assets/images/Telegram_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Register Telegram Bot Token', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenCtrl,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Telegram Token', suffixIcon: Icon(Icons.vpn_key_outlined)),
                onSubmitted: (_) => _next(),
              ),
              const SizedBox(height: 12),
              GradientButton(label: vm.loading ? 'Please wait…' : 'Next', loading: vm.loading, onPressed: vm.loading ? null : _next),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter the Telegram token'), behavior: SnackBarBehavior.floating));
      return;
    }

    final args = Map<String, dynamic>.from(Get.arguments as Map<String, dynamic>? ?? {});
    args['token'] = token;

    Get.to(() => const WaterAndMeterPriceView(), arguments: args);
  }
}
