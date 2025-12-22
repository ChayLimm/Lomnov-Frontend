import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'package:app/Presentation/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class BakongController extends GetxController {
  String? name;
  String? email;
  String? phoneNumber;
  String? password;
  String? token; // Telegram ID token

  String bakongId = '';
  String bakongName = '';
  String bakongLocation = '';
  String deviceId = ''; 

  void initFromArgs(Map<String, dynamic> args) {
    name = args['name'] as String?;
    email = args['email'] as String?;
    phoneNumber = args['phonenumber'] as String?;
    password = args['password'] as String?;
    token = args['token'] as String?;
  }
}

class BakongSetupView extends StatefulWidget {
  const BakongSetupView({super.key});

  @override
  State<BakongSetupView> createState() => _BakongSetupViewState();
}


class _BakongSetupViewState extends State<BakongSetupView> {
  final _bakongIdCtrl = TextEditingController();
  final _bakongNameCtrl = TextEditingController();
  final _bakongLocationCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();

  late final BakongController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(BakongController());
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      ctrl.initFromArgs(args);
    }
  }

  @override
  void dispose() {
    _bakongIdCtrl.dispose();
    _bakongNameCtrl.dispose();
    _bakongLocationCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
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
                        title: 'Almost there',
                        subtitle: "Let's set you up for Bakong",
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _bakongIdCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'ID',
                          suffixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bakongNameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          suffixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bakongLocationCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          suffixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tokenCtrl,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Token',
                          suffixIcon: Icon(Icons.vpn_key_outlined),
                        ),
                        onSubmitted: (_) => _create(vm),
                      ),
                    ],
                  ),
                ),
              ),
              GradientButton(
                label: vm.loading ? 'Creating…' : 'Create',
                loading: vm.loading,
                onPressed: vm.loading ? null : () => _create(vm),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _create(AuthViewModel vm) {
    final id = _bakongIdCtrl.text.trim();
    final name = _bakongNameCtrl.text.trim();
    final location = _bakongLocationCtrl.text.trim();
    final token = _tokenCtrl.text.trim();

    if (id.isEmpty) {
      _showMessage('Please enter your Bakong ID');
      return;
    }
    if (name.isEmpty) {
      _showMessage('Please enter your Bakong username');
      return;
    }
    if (location.isEmpty) {
      _showMessage('Please enter your Bakong location');
      return;
    }
    if (token.isEmpty) {
      _showMessage('Please enter your Bakong token');
      return;
    }

    ctrl.bakongId = id;
    ctrl.bakongName = name;
    ctrl.bakongLocation = location;
    ctrl.token = token;

    final payload = {
      'name': ctrl.name,
      'email': ctrl.email,
      'phonenumber': ctrl.phoneNumber,
      'password': ctrl.password,
      'token': token, // use the entered token
      'bakong_id': ctrl.bakongId,
      'bakong_name': ctrl.bakongName,
      'bakong_location': ctrl.bakongLocation,
      'device_id': ctrl.deviceId,
    };

    vm.registerWithPayload(payload);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
                  'lib/assets/images/bakong.png',
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
