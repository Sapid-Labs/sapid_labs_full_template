import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/**
 * Utility class for fast access to screen dimensions and media query data.
 * Sample usage:
 * final screenSize = context.screenSize;
 */
extension FastDimensions on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => mediaQuery.size.width;

  double get screenHeight => mediaQuery.size.height;

  EdgeInsets get padding => mediaQuery.padding;

  double get textScaleFactor => mediaQuery.textScaler.scale(1);
}

class UiUtils {
  // Screen Dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets screenPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Responsive Breakpoints
  static const double kMobileBreakpoint = 480.0;
  static const double kTabletBreakpoint = 768.0;
  static const double kDesktopBreakpoint = 1024.0;

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < kTabletBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= kTabletBreakpoint && width < kDesktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= kDesktopBreakpoint;
  }

  // Responsive Dimensions
  static double responsiveWidth(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  static double responsiveHeight(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  // Widget Positioning
  static Offset getWidgetPosition(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero);
  }

  static Size getWidgetSize(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    return box.size;
  }

  static Rect getWidgetBounds(BuildContext context) {
    final position = getWidgetPosition(context);
    final size = getWidgetSize(context);
    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  /// Captures a widget as a PNG image using a GlobalKey
  /// Returns the image data as Uint8List
  ///
  /// Example usage:
  /// ```dart
  /// final GlobalKey globalKey = GlobalKey();
  ///
  /// // Wrap your widget with RepaintBoundary
  /// RepaintBoundary(
  ///   key: globalKey,
  ///   child: YourWidget(),
  /// )
  ///
  /// // Capture the image
  /// final imageBytes = await UiUtils.captureWidgetAsImage(globalKey);
  /// ```
  static Future<Uint8List> captureWidgetAsImage(GlobalKey globalKey) async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Safe Area
  static double safeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double safeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double viewInsetsBottom(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  // Layout Calculations
  static double percentageOfScreen(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  static double heightPercentageOfScreen(
      BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  // Grid Calculations
  static int getGridCrossAxisCount(
    BuildContext context, {
    required double minWidth,
    int defaultCount = 2,
  }) {
    final screenWidth = UiUtils.screenWidth(context);
    final count = (screenWidth / minWidth).floor();
    return count < 1 ? defaultCount : count;
  }

  static double getGridItemWidth(
    BuildContext context, {
    required int crossAxisCount,
    double spacing = 8.0,
  }) {
    final screenWidth = UiUtils.screenWidth(context);
    final totalSpacing = spacing * (crossAxisCount - 1);
    return (screenWidth - totalSpacing) / crossAxisCount;
  }

  // Device Type Detection
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Scaling Factors
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Platform Specific
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  static bool isAndroid(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.android;
  }

  // Accessibility
  static bool isReducedMotion(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  static bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  // Layout Helpers
  static Widget addHorizontalSpace(double width) {
    return SizedBox(width: width);
  }

  static Widget addVerticalSpace(double height) {
    return SizedBox(height: height);
  }

  static Widget addResponsiveHorizontalSpace(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return SizedBox(
        width: responsiveWidth(context,
            mobile: mobile, tablet: tablet, desktop: desktop));
  }

  static Widget addResponsiveVerticalSpace(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return SizedBox(
        height: responsiveHeight(context,
            mobile: mobile, tablet: tablet, desktop: desktop));
  }

  // Keyboard Utilities
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  // Custom Dialog Position
  static RelativeRect getOptimalDialogPosition(
      BuildContext context, Size dialogSize) {
    final screen = getScreenSize(context);
    final center = Offset(screen.width / 2, screen.height / 2);

    return RelativeRect.fromLTRB(
      center.dx - (dialogSize.width / 2),
      center.dy - (dialogSize.height / 2),
      center.dx + (dialogSize.width / 2),
      center.dy + (dialogSize.height / 2),
    );
  }
}
