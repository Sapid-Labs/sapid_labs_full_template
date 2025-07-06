import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool kIsWideDesktopWeb(BuildContext context) => kIsWeb && LayoutUtils.screenWidth(context) >= 1000;

bool kIsWideScreen(BuildContext context) => (MediaQuery.sizeOf(context).width) >= 600;

/// Spacers
SizedBox gap4 = const SizedBox.square(dimension: 4);
SizedBox gap8 = const SizedBox.square(dimension: 8);
SizedBox gap12 = const SizedBox.square(dimension: 12);
SizedBox gap16 = const SizedBox.square(dimension: 16);
SizedBox gap24 = const SizedBox.square(dimension: 24);
SizedBox gap32 = const SizedBox.square(dimension: 32);
SizedBox gap48 = const SizedBox.square(dimension: 48);
SizedBox gap64 = const SizedBox.square(dimension: 64);
SizedBox smallerGap = const SizedBox.square(dimension: 4);
SizedBox smallGap = const SizedBox.square(dimension: 8);
SizedBox gap = const SizedBox.square(dimension: 10);
SizedBox largeGap = const SizedBox.square(dimension: 32);
SizedBox largerGap = const SizedBox.square(dimension: 48);
SizedBox largestGap = const SizedBox.square(dimension: 64);

/// Paddings
EdgeInsets padding8 = const EdgeInsets.all(8);
EdgeInsets padding12 = const EdgeInsets.all(12);
EdgeInsets padding16 = const EdgeInsets.all(16);
EdgeInsets padding24 = const EdgeInsets.all(24);
EdgeInsets padding36 = const EdgeInsets.all(36);
EdgeInsets paddingH8 = const EdgeInsets.symmetric(horizontal: 8);
EdgeInsets paddingV8 = const EdgeInsets.symmetric(vertical: 8);
EdgeInsets paddingH16 = const EdgeInsets.symmetric(horizontal: 16);
EdgeInsets paddingV16 = const EdgeInsets.symmetric(vertical: 16);
EdgeInsets paddingH24 = const EdgeInsets.symmetric(horizontal: 24);
EdgeInsets paddingV24 = const EdgeInsets.symmetric(vertical: 24);

/// Borders
BorderRadius circular4 = const BorderRadius.all(Radius.circular(4));
BorderRadius circular8 = const BorderRadius.all(Radius.circular(8));
BorderRadius circular12 = const BorderRadius.all(Radius.circular(12));
BorderRadius circular16 = const BorderRadius.all(Radius.circular(16));

/// Widgets
Divider divider = const Divider(height: 2);

class TextStyles {
  // Avoids creating instances of TextStyles
  TextStyles._();

  static double lineHeightForFont(TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: ' ', style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.height;
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle withColor(Color? color) => copyWith(color: color);

  TextStyle withLetterSpacing(double letterSpacing) => copyWith(letterSpacing: letterSpacing);
}

extension SliverExtension on Widget {
  SliverToBoxAdapter toSliver() => SliverToBoxAdapter(child: this);
}

class LayoutUtils {
  static double screenWidth(BuildContext context) => MediaQuery.maybeOf(context)?.size.width ?? 0;

  static double screenHeight(BuildContext context) => MediaQuery.maybeOf(context)?.size.height ?? 0;

  static const double maxWidth = 600;
  static const double maxLargeWidth = 800;
  static const double maxSmallWidth = 400;
  static const double maxSmallerWidth = 300;

  static bool isWide(BuildContext context) => screenWidth(context) > 400;

  static bool isShort(BuildContext context) => screenHeight(context) < 700;
}

// https://m2.material.io/design/layout/responsive-layout-grid.html#breakpoints
class Breakpoints {
  static const double xs = 400.0; // Extra-small (phone)
  static const double sm = 600.0; // Small (tablet)
  static const double md = 1000.0; // Medium (laptop)
  static const double lg = 1440.0; // Large (desktop)
  static const double xl = 1440.0; // Extra-large (desktop)
}

bool? _kIsMobileWeb;

bool get kIsMobileWeb => _kIsMobileWeb!;

Future<bool> checkMobileWeb() async {
  _kIsMobileWeb = await _isMobileWeb();
  return kIsMobileWeb;
}

BrowserName? _browserName;

BrowserName? get browserName => _browserName;

Future<bool> _isMobileWeb() async {
  if (!kIsWeb) return false;

  final WebBrowserInfo webBrowserInfo = await DeviceInfoPlugin().webBrowserInfo;
  _browserName = webBrowserInfo.browserName;

  final userAgent = webBrowserInfo.userAgent?.toLowerCase() ?? '';

  if (userAgent.contains("iphone") || userAgent.contains("android") || userAgent.contains("ipad")) return true;

  final platform = webBrowserInfo.platform?.toLowerCase() ?? '';
  final maxTouchPoints = webBrowserInfo.maxTouchPoints ?? 0;
  if (platform.toLowerCase().contains("macintel") && maxTouchPoints > 0) return true;

  return false;
}