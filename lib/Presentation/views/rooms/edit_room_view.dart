import 'package:flutter/material.dart';
import 'room_form_view.dart';

class EditRoomView extends StatelessWidget {
  final dynamic room; // RoomModel or Map
  const EditRoomView({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return RoomFormView(room: room);
  }
}
