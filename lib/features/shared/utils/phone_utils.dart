String normalizePhoneNumber(String phoneNumber) {
  // Remove all non-digit characters
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Assuming US numbers for this example; adjust as needed
  if (digitsOnly.length == 10) {
    return '+1$digitsOnly';
  } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
    return '+$digitsOnly';
  } else if (digitsOnly.startsWith('+')) {
    return digitsOnly;
  } else {
    throw FormatException('Invalid phone number format');
  }
}

String formatPhoneNumber(String phoneNumber) {
  // Basic formatting for US numbers; adjust as needed
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
    return '(${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
  } else if (digitsOnly.length == 10) {
    return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  } else {
    return phoneNumber; // Return as is if format is unrecognized
  }
}