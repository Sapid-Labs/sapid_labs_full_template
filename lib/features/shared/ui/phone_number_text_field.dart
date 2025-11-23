import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Phone number formatter class
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit to 10 digits
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }
    
    // Format as xxx-xxx-xxxx
    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      formatted = digitsOnly.substring(0, digitsOnly.length >= 3 ? 3 : digitsOnly.length);
    }
    if (digitsOnly.length >= 4) {
      formatted += '-${digitsOnly.substring(3, digitsOnly.length >= 6 ? 6 : digitsOnly.length)}';
    }
    if (digitsOnly.length >= 7) {
      formatted += '-${digitsOnly.substring(6)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PhoneNumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool showCountryCode;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;

  const PhoneNumberTextField({
    super.key,
    this.controller,
    this.labelText = 'Phone Number',
    this.hintText = '555-123-4567',
    this.showCountryCode = true,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration ?? InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.phone),
        prefixText: showCountryCode ? '+1 ' : null,
      ),
      keyboardType: TextInputType.phone,
      enabled: enabled,
      inputFormatters: [PhoneNumberFormatter()],
      validator: validator ?? _defaultValidator,
      onChanged: onChanged ?? _defaultOnChanged,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    // Basic phone number validation - check if we have 10 digits
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  void _defaultOnChanged(String value) {
    // Default implementation does nothing
    // Users can override this with their own onChanged callback
  }

  /// Helper method to extract just the digits from a formatted phone number
  static String extractDigits(String formattedNumber) {
    return formattedNumber.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Helper method to format a phone number with country code
  static String formatWithCountryCode(String phoneNumber, {String countryCode = '+1'}) {
    String digitsOnly = extractDigits(phoneNumber);
    return '$countryCode$digitsOnly';
  }
}