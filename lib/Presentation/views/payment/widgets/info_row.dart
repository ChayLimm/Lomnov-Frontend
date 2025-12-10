import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/Presentation/themes/text_styles.dart';

class InfoRow extends StatelessWidget {
  final String keyData;
  final String value;
  final bool isBold;
  final EdgeInsets margin;
  
  const InfoRow({
    super.key, 
    required this.keyData, 
    required this.value,
    this.isBold = false,
    this.margin = const EdgeInsets.symmetric(vertical: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              keyData,
              style: LomTextStyles.bodyText().copyWith(
                fontWeight:  FontWeight.normal,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Text(value,
            style: LomTextStyles.bodyText().copyWith(
              fontWeight:  FontWeight.w700 ,
              color: Colors.black ,
            ),
          ),
        ],
      ),
    );
  }
}