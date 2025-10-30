import 'package:flutter/material.dart';

class ResponsiveHelper {
  final BuildContext context;
  late final MediaQueryData _mediaQuery;
  late final double screenWidth;
  late final double screenHeight;
  late final double blockSizeHorizontal;
  late final double blockSizeVertical;
  late final double safeBlockHorizontal;
  late final double safeBlockVertical;

  ResponsiveHelper(this.context) {
    _mediaQuery = MediaQuery.of(context);
    screenWidth = _mediaQuery.size.width;
    screenHeight = _mediaQuery.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    final safePadding = _mediaQuery.padding;
    final safeWidth = screenWidth - safePadding.left - safePadding.right;
    final safeHeight = screenHeight - safePadding.top - safePadding.bottom;
    safeBlockHorizontal = safeWidth / 100;
    safeBlockVertical = safeHeight / 100;
  }

  // Width percentages
  double wp(double percentage) => screenWidth * (percentage / 100);

  // Height percentages
  double hp(double percentage) => screenHeight * (percentage / 100);

  // Font sizes based on screen width
  double fontSize(double size) {
    // Base font size calculation (assuming 375px as base width)
    return size * (screenWidth / 375);
  }

  // Responsive padding/margin
  double spacing(double size) {
    return size * (screenWidth / 375);
  }

  // Icon sizes
  double iconSize(double size) {
    return size * (screenWidth / 375);
  }

  // Border radius
  double radius(double size) {
    return size * (screenWidth / 375);
  }

  // Check device type
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // Responsive value based on device
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}
