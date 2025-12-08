import 'package:flutter/material.dart';
import 'room_form_view.dart';

class AddRoomView extends StatelessWidget {
  final int buildingId;
  const AddRoomView({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context) {
    return RoomFormView(buildingId: buildingId);
  }
}
