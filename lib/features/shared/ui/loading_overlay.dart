import 'package:flutter/material.dart';
import 'package:foolscript/features/shared/ui/loading_indicator.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: LoadingIndicator(),
      ),
    );
  }
}
