import 'package:flutter/material.dart';

enum FontSize {
  xs,
  sm,
  md,
  mdl,
  lg,
  xl,
  xxl,
  xxxl,
}

enum FontWeightType {
  regular,
  medium,
  semibold,
  bold,
}

class FontUtils {
  static double getFontSize(FontSize size) {
    switch (size) {
      case FontSize.xs:
        return 12.0;
      case FontSize.sm:
        return 14.0;
      case FontSize.md:
        return 16.0;
      case FontSize.mdl:
        return 18.0;
      case FontSize.lg:
        return 22.0;
      case FontSize.xl:
        return 24.0;
      case FontSize.xxl:
        return 26;
      case FontSize.xxxl:
        return 32.0;
      default:
        return 16.0;
    }
  }

  static FontWeight weight(FontWeightType type) {
    switch (type) {
      case FontWeightType.regular:
        return FontWeight.w400;
      case FontWeightType.medium:
        return FontWeight.w500;
      case FontWeightType.semibold:
        return FontWeight.w600;
      case FontWeightType.bold:
        return FontWeight.w700;
      default:
        return FontWeight.w400;
    }
  }

  static TextStyle style({
    FontSize size = FontSize.md,
    FontWeightType weight = FontWeightType.regular,
    Color color = Colors.black,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: getFontSize(size),
      fontWeight: FontUtils.weight(weight),
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}
