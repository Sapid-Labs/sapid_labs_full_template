import 'package:flutter/material.dart';
import 'dart:math' as math;

class ColorUtils {
  // Color Creation
  static Color fromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static Color random({int alpha = 255}) {
    return Color.fromARGB(
      alpha,
      math.Random().nextInt(256),
      math.Random().nextInt(256),
      math.Random().nextInt(256),
    );
  }

  // Color Manipulation
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color adjustOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  // Color Blending
  static Color blend(Color color1, Color color2, [double weight = 0.5]) {
    return Color.lerp(color1, color2, weight) ?? color1;
  }

  static Color multiply(Color color1, Color color2) {
    final r = (color1.red * color2.red) ~/ 255;
    final g = (color1.green * color2.green) ~/ 255;
    final b = (color1.blue * color2.blue) ~/ 255;
    return Color.fromARGB(color1.alpha, r, g, b);
  }

  // Color Analysis
  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  static bool isLight(Color color) {
    return !isDark(color);
  }

  static double contrast(Color background, Color foreground) {
    final bgLuminance = background.computeLuminance();
    final fgLuminance = foreground.computeLuminance();

    final lighter = math.max(bgLuminance, fgLuminance);
    final darker = math.min(bgLuminance, fgLuminance);

    return (lighter + 0.05) / (darker + 0.05);
  }

  // Gradient Generation
  static List<Color> generateGradient(
      Color startColor, Color endColor, int steps) {
    List<Color> colors = [];
    for (int i = 0; i < steps; i++) {
      colors.add(blend(startColor, endColor, i / (steps - 1)));
    }
    return colors;
  }

  // Color Schemes
  static List<Color> complementary(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final complement = hsl.withHue((hsl.hue + 180) % 360);
    return [baseColor, complement.toColor()];
  }

  static List<Color> analogous(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return [
      hsl.withHue((hsl.hue - 30) % 360).toColor(),
      baseColor,
      hsl.withHue((hsl.hue + 30) % 360).toColor(),
    ];
  }

  static List<Color> triadic(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return [
      baseColor,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  // Material Design Specific
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (final double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        (r + ((ds < 0 ? r : (255 - r)) * ds)).round(),
        (g + ((ds < 0 ? g : (255 - g)) * ds)).round(),
        (b + ((ds < 0 ? b : (255 - b)) * ds)).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  // Accessibility
  static Color getTextColor(Color backgroundColor) {
    return isDark(backgroundColor) ? Colors.white : Colors.black;
  }

  static bool isAccessible(Color background, Color foreground) {
    // WCAG 2.0 level AA requires a contrast ratio of at least 4.5:1
    return contrast(background, foreground) >= 4.5;
  }

  // Color Space Conversion
  static HSLColor toHSL(Color color) {
    return HSLColor.fromColor(color);
  }

  static HSVColor toHSV(Color color) {
    return HSVColor.fromColor(color);
  }
}

extension FastColor on BuildContext {
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  Color get secondaryColor => Theme.of(this).colorScheme.secondary;

  Color get tertiaryColor => Theme.of(this).colorScheme.tertiary;

  Color get errorColor => Theme.of(this).colorScheme.error;

  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;

  Color get onSecondaryColor => Theme.of(this).colorScheme.onSecondary;

  Color get onTertiaryColor => Theme.of(this).colorScheme.onTertiary;

  Color get onErrorColor => Theme.of(this).colorScheme.onError;

  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
}
