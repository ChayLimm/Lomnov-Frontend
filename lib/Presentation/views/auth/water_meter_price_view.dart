import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class WaterAndMeterPriceView extends StatefulWidget {
  const WaterAndMeterPriceView({super.key});

  @override
  State<WaterAndMeterPriceView> createState() => _WaterAndMeterPriceViewState();
}

class _WaterAndMeterPriceViewState extends State<WaterAndMeterPriceView> {
  final _waterCtrl = TextEditingController();
  final _elecCtrl = TextEditingController();

  @override
  void dispose() {
    _waterCtrl.dispose();
    _elecCtrl.dispose();
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
              const SizedBox(height: 24),
              const Text('Utility Prices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _waterCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Water price', suffixIcon: Icon(Icons.water)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _elecCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Electricity price', suffixIcon: Icon(Icons.flash_on)),
                onSubmitted: (_) => _submit(vm, args),
              ),
              const SizedBox(height: 16),
              if (vm.error != null) Text(vm.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              GradientButton(label: vm.loading ? 'Please wait…' : 'Submit', loading: vm.loading, onPressed: vm.loading ? null : () => _submit(vm, args)),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(AuthViewModel vm, Map<String, dynamic> args) {
    final waterText = _waterCtrl.text.trim();
    final elecText = _elecCtrl.text.trim();

    if (waterText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter water price'), behavior: SnackBarBehavior.floating));
      return;
    }
    if (elecText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter electricity price'), behavior: SnackBarBehavior.floating));
      return;
    }

    final water = double.tryParse(waterText) ?? 0;
    final elec = double.tryParse(elecText) ?? 0;

    final payload = Map<String, dynamic>.from(args);
    payload['water_price'] = water;
    payload['electricity_price'] = elec;

    // Call the ViewModel to submit the combined payload
    vm.registerWithPayload(payload);
  }
}
