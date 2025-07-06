import 'package:flutter/material.dart';
import 'package:sapid_labs/features/shared/ui/loading_overlay.dart';

class LoadingStack extends StatelessWidget {
  const LoadingStack({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) LoadingOverlay(),
      ],
    );
  }
}
