import 'package:flutter/material.dart';
import 'contract_form/contract_form_view.dart';

class AddContractView extends StatelessWidget {
  final int roomId;
  const AddContractView({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return ContractFormView(roomId: roomId);
  }
}
