import 'package:cotr_flutter_app/app/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

class DialogUtils {
  // Basic Confirmation Dialog
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    String title = 'Confirm',
    String message = 'Are you sure you want to proceed?',
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
    bool barrierDismissible = true,
    Widget? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: icon,
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: cancelColor,
              ),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: confirmColor ?? Theme.of(context).primaryColor,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // Input Dialog
  static Future<String?> showInputDialog({
    required BuildContext context,
    String title = 'Enter Value',
    String? initialValue,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    String? hintText,
    String? labelText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hintText,
                labelText: labelText,
              ),
              validator: validator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, controller.text);
                }
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result;
  }

  // Loading Dialog
  static Future<void> showLoadingDialog({
    required BuildContext context,
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                gap24,
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  // Success Dialog
  static Future<void> showSuccessDialog({
    required BuildContext context,
    String title = 'Success',
    String message = 'Operation completed successfully',
    String buttonText = 'OK',
    VoidCallback? onPressed,
    Duration autoCloseDuration = const Duration(seconds: 2),
  }) async {
    Timer? timer;

    timer = Timer(autoCloseDuration, () {
      Navigator.of(context).pop();
      timer?.cancel();
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle_outline,
              color: Colors.green, size: 48),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                timer?.cancel();
                Navigator.pop(context);
                onPressed?.call();
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  // Error Dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    String title = 'Error',
    String message = 'An error occurred',
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onPressed?.call();
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  // Choice Dialog
  static Future<T?> showChoiceDialog<T>({
    required BuildContext context,
    required String title,
    required List<DialogChoice<T>> choices,
    String? message,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(message),
                ),
              ...choices.map((choice) => ListTile(
                    leading: choice.icon,
                    title: Text(choice.title),
                    subtitle:
                        choice.subtitle != null ? Text(choice.subtitle!) : null,
                    onTap: () => Navigator.pop(context, choice.value),
                  )),
            ],
          ),
        );
      },
    );
  }

  // Custom Bottom Sheet Dialog
  static Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  child: content,
                ),
              ),
              // Actions
              if (actions != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Helper class for choice dialog
class DialogChoice<T> {
  final String title;
  final String? subtitle;
  final Icon? icon;
  final T value;

  DialogChoice({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
  });
}
