import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final KeyData;
  final value;
  const InfoRow({super.key, required this.KeyData, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(KeyData,style: ,),
    );
  }
}