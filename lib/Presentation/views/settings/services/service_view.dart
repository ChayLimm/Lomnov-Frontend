import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/settings/service_provider.dart';
import 'service_screen.dart';

class ServiceView extends StatelessWidget {
  const ServiceView({super.key});

  static const routeName = '/services';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceState()..load(),
      child: const ServiceScreen(),
    );
  }
}

