import 'package:flutter/material.dart';

// Lom text styles with functional builders
// Usage: LomTextStyles.headline1(color: theme.colorScheme.onSurface)
class LomTextStyles {
  // Base sizes
  static const double h1 = 24.0;
  static const double h2 = 20.0;
  static const double body = 14.0;
  static const double caption = 12.0;

  // Builders that return TextStyle so you can override as needed
  static TextStyle headline1({
    Color? color,
    FontWeight fontWeight = FontWeight.bold,
    double? size,
    double? height,
    double? letterSpacing,
    String? fontFamily,
    TextDecoration? decoration,
  }) => TextStyle(
        fontSize: size ?? h1,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontFamily: fontFamily,
        decoration: decoration,
      );

  static TextStyle headline2({
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
    double? size,
    double? height,
    double? letterSpacing,
    String? fontFamily,
    TextDecoration? decoration,
  }) => TextStyle(
        fontSize: size ?? h2,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontFamily: fontFamily,
        decoration: decoration,
      );

  static TextStyle bodyText({
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double? size,
    double? height,
    double? letterSpacing,
    String? fontFamily,
    TextDecoration? decoration,
  }) => TextStyle(
        fontSize: size ?? body,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontFamily: fontFamily,
        decoration: decoration,
      );

  static TextStyle captionText({
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double? size,
    double? height,
    double? letterSpacing,
    String? fontFamily,
    TextDecoration? decoration,
  }) => TextStyle(
        fontSize: size ?? caption,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontFamily: fontFamily,
        decoration: decoration,
      );

  // TextTheme for ThemeData.textTheme
  static TextTheme get textTheme => TextTheme(
        displayLarge: headline1(),
        displayMedium: headline2(),
        bodyLarge: bodyText(),
        bodySmall: captionText(),
      );
}

// Backwards compatibility shim for previous TextStyles API.
@Deprecated('Use LomTextStyles instead')
class TextStyles {
  static const double h1 = LomTextStyles.h1;
  static const double h2 = LomTextStyles.h2;
  static const double body = LomTextStyles.body;
  static const double caption = LomTextStyles.caption;

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
