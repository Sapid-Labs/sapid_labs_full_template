import 'dart:convert';

import 'package:slapp/app/services.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

class TextUtils {
  // Case Conversions
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String sentenceCase(String text) => ReCase(text).sentenceCase;
  static String titleCase(String text) => ReCase(text).titleCase;
  static String camelCase(String text) => ReCase(text).camelCase;
  static String snakeCase(String text) => ReCase(text).snakeCase;
  static String pascalCase(String text) => ReCase(text).pascalCase;
  static String constantCase(String text) => ReCase(text).constantCase;

  // String Validation
  static bool isNullOrEmpty(String? text) => text == null || text.isEmpty;
  static bool isNullOrWhitespace(String? text) =>
      text == null || text.trim().isEmpty;
  static bool containsOnlyDigits(String text) =>
      RegExp(r'^[0-9]+$').hasMatch(text);
  static bool isValidEmail(String text) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(text);
  }

  static bool isValidUrl(String text) {
    return Uri.tryParse(text)?.hasAbsolutePath ?? false;
  }

  // String Manipulation
  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  static String truncate(
    String text,
    int maxLength, {
    String suffix = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  static String reverse(String text) {
    return String.fromCharCodes(text.runes.toList().reversed);
  }

  // Text Formatting
  static String formatPhoneNumber(String number) {
    if (number.length != 10) return number;
    return '(${number.substring(0, 3)}) ${number.substring(3, 6)}-${number.substring(6)}';
  }

  static String formatCurrency(double amount,
      {String symbol = '\$', int decimals = 2}) {
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }

  // Word Operations
  static int wordCount(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }

  static List<String> extractUrls(String text) {
    return RegExp(r'https?://[^\s]+')
        .allMatches(text)
        .map((match) => match.group(0) ?? '')
        .toList();
  }

  static String slugify(String text) {
    var slug = text.toLowerCase().trim();
    slug = slug.replaceAll(RegExp(r'[^a-z0-9\s-]'), '');
    slug = slug.replaceAll(RegExp(r'\s+'), '-');
    return slug;
  }

  // Security
  static String maskString(String text,
      {int visibleChars = 4, String mask = '*'}) {
    if (text.length <= visibleChars) return text;
    return '${text.substring(0, visibleChars)}${mask * (text.length - visibleChars)}';
  }

  // Encoding/Decoding
  static String encodeBase64(String text) {
    return base64.encode(utf8.encode(text));
  }

  static String decodeBase64(String encoded) {
    return utf8.decode(base64.decode(encoded));
  }

  // Text Search
  static bool containsIgnoreCase(String source, String search) {
    return source.toLowerCase().contains(search.toLowerCase());
  }

  static int occurrences(String text, String pattern) {
    return RegExp(pattern).allMatches(text).length;
  }
}

extension FastTextStyle on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle get bodySmall => textTheme.bodySmall!;

  TextStyle get bodyMedium => textTheme.bodyMedium!;

  TextStyle get bodyLarge => textTheme.bodyLarge!;

  TextStyle get labelSmall => textTheme.labelSmall!;

  TextStyle get labelMedium => textTheme.labelMedium!;

  TextStyle get labelLarge => textTheme.labelLarge!;

  TextStyle get titleSmall => textTheme.titleSmall!;

  TextStyle get titleMedium => textTheme.titleMedium!;

  TextStyle get titleLarge => textTheme.titleLarge!;

  TextStyle get headlineSmall => textTheme.headlineSmall!;

  TextStyle get headlineMedium => textTheme.headlineMedium!;

  TextStyle get headlineLarge => textTheme.headlineLarge!;

  TextStyle get displaySmall => textTheme.displaySmall!;

  TextStyle get displayMedium => textTheme.displayMedium!;

  TextStyle get displayLarge => textTheme.displayLarge!;
}

extension FastTextColor on TextStyle {
  BuildContext get context => router.navigatorKey.currentContext!;

  TextStyle get white => copyWith(color: Colors.white);

  TextStyle get black => copyWith(color: Colors.black);

  TextStyle get primary =>
      copyWith(color: Theme.of(context).colorScheme.primary);

  TextStyle get primaryContainer =>
      copyWith(color: Theme.of(context).colorScheme.primaryContainer);

  TextStyle get primaryFixed =>
      copyWith(color: Theme.of(context).colorScheme.primaryFixed);

  TextStyle get primaryFixedDim =>
      copyWith(color: Theme.of(context).colorScheme.primaryFixedDim);

  TextStyle get secondary =>
      copyWith(color: Theme.of(context).colorScheme.secondary);

  TextStyle get secondaryFixed =>
      copyWith(color: Theme.of(context).colorScheme.secondaryFixed);

  TextStyle get secondaryFixedDim =>
      copyWith(color: Theme.of(context).colorScheme.secondaryFixedDim);

  TextStyle get tertiary =>
      copyWith(color: Theme.of(context).colorScheme.tertiary);

  TextStyle get tertiaryFixed =>
      copyWith(color: Theme.of(context).colorScheme.tertiaryFixed);

  TextStyle get tertiaryFixedDim =>
      copyWith(color: Theme.of(context).colorScheme.tertiaryFixedDim);

  TextStyle get onPrimary =>
      copyWith(color: Theme.of(context).colorScheme.onPrimary);

  TextStyle get onPrimaryContainer =>
      copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer);

  TextStyle get onPrimaryFixed =>
      copyWith(color: Theme.of(context).colorScheme.onPrimaryFixed);

  TextStyle get onPrimaryFixedVariant =>
      copyWith(color: Theme.of(context).colorScheme.onPrimaryFixedVariant);

  TextStyle get onSecondary =>
      copyWith(color: Theme.of(context).colorScheme.onSecondary);

  TextStyle get onSecondaryContainer =>
      copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer);

  TextStyle get onSecondaryFixed =>
      copyWith(color: Theme.of(context).colorScheme.onSecondaryFixed);

  TextStyle get onSecondaryFixedVariant =>
      copyWith(color: Theme.of(context).colorScheme.onSecondaryFixedVariant);

  TextStyle get onTertiary =>
      copyWith(color: Theme.of(context).colorScheme.onTertiary);

  TextStyle get onTertiaryContainer =>
      copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer);

  TextStyle get onTertiaryFixed =>
      copyWith(color: Theme.of(context).colorScheme.onTertiaryFixed);

  TextStyle get onTertiaryFixedVariant =>
      copyWith(color: Theme.of(context).colorScheme.onTertiaryFixedVariant);

  TextStyle get background =>
      copyWith(color: Theme.of(context).colorScheme.background);

  TextStyle get onBackground =>
      copyWith(color: Theme.of(context).colorScheme.onBackground);

  TextStyle get surface =>
      copyWith(color: Theme.of(context).colorScheme.surface);

  TextStyle get surfaceDim =>
      copyWith(color: Theme.of(context).colorScheme.surfaceDim);

  TextStyle get surfaceBright =>
      copyWith(color: Theme.of(context).colorScheme.surfaceBright);

  TextStyle get surfaceContainer =>
      copyWith(color: Theme.of(context).colorScheme.surfaceContainer);

  TextStyle get surfaceContainerHigh =>
      copyWith(color: Theme.of(context).colorScheme.surfaceContainerHigh);

  TextStyle get surfaceContainerHighest =>
      copyWith(color: Theme.of(context).colorScheme.surfaceContainerHighest);

  TextStyle get surfaceContainerLow =>
      copyWith(color: Theme.of(context).colorScheme.surfaceContainerLow);

  TextStyle get surfaceContainerLowest =>
      copyWith(color: Theme.of(context).colorScheme.surfaceContainerLowest);

  TextStyle get onSurface =>
      copyWith(color: Theme.of(context).colorScheme.onSurface);

  TextStyle get onSurfaceVariant =>
      copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

  TextStyle get surfaceTint =>
      copyWith(color: Theme.of(context).colorScheme.surfaceTint);

  TextStyle get error => copyWith(color: Theme.of(context).colorScheme.error);

  TextStyle get onError =>
      copyWith(color: Theme.of(context).colorScheme.onError);

  TextStyle get onErrorContainer =>
      copyWith(color: Theme.of(context).colorScheme.onErrorContainer);

  TextStyle get outline =>
      copyWith(color: Theme.of(context).colorScheme.outline);

  TextStyle get outlineVariant =>
      copyWith(color: Theme.of(context).colorScheme.outlineVariant);

  TextStyle get inversePrimary =>
      copyWith(color: Theme.of(context).colorScheme.inversePrimary);

  TextStyle get inverseSurface =>
      copyWith(color: Theme.of(context).colorScheme.inverseSurface);

  TextStyle get onInverseSurface =>
      copyWith(color: Theme.of(context).colorScheme.onInverseSurface);

  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
}

extension TextColorOpacity on TextStyle {
  TextStyle withOpacity(double opacity) {
    return copyWith(color: color?.withValues(alpha: opacity));
  }
}
