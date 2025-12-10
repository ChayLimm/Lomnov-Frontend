import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/Presentation/themes/text_styles.dart';

class InfoRow extends StatelessWidget {
  final title;
  final KeyData;
  final value;
  const InfoRow({super.key,required this.title, required this.KeyData, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,style: LomTextStyles.captionText().copyWith(color: AppColors.primaryColor,fontWeight: FontWeight.bold),),
        ListTile(
          leading: Text(KeyData,style: LomTextStyles.bodyText(),),
          trailing: Text( value,style: LomTextStyles.bodyText().copyWith(fontWeight: FontWeight.bold),),
        ),
      ],
    );
  }
}