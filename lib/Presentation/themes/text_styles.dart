import 'package:flutter/material.dart';

//we can define more text styles as needed
//and make change of the global text styles from here

class TextStyles {
  static const double h1 = 24.0;
  static const double h2 = 20.0;
  static const double body = 14.0;
  static const double caption = 12.0;

  static const TextStyle headline1 = TextStyle(fontSize: h1, fontWeight: FontWeight.bold);
  static const TextStyle headline2 = TextStyle(fontSize: h2, fontWeight: FontWeight.w600);
  static const TextStyle bodyText = TextStyle(fontSize: body);
  static const TextStyle captionText = TextStyle(fontSize: caption);

  static TextTheme get textTheme => TextTheme(
        displayLarge: headline1,
        displayMedium: headline2,
        bodyLarge: bodyText,
        bodySmall: captionText,
      );
}
