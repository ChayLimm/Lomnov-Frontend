import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/settings/room_type_provider.dart';
import 'room_type_screen.dart';

class RoomTypeView extends StatelessWidget {
  const RoomTypeView({super.key});

  static const routeName = '/room-types';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomTypeState()..load(),
      child: const RoomTypeScreen(),
    );
  }
}
