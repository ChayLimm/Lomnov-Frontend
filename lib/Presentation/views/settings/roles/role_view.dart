import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/settings/role_provider.dart';
import 'role_screen.dart';

class RoleView extends StatelessWidget {
  const RoleView({super.key});

  static const routeName = '/roles';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoleState()..load(),
      child: const RoleScreen(),
    );
  }
}
