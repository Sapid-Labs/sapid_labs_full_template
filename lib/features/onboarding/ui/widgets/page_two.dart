import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:slapp/app/constants.dart';
import 'package:slapp/features/shared/utils/text_utils.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hire us at sapidlabs.com',
              textAlign: TextAlign.center,
              style: context.headlineSmall,
            ).animate(effects: [
              const FadeEffect(delay: Duration(milliseconds: 300))
            ]),
            gap16,
            const Text('💙')
          ],
        ),
      ),
    );
  }
}
