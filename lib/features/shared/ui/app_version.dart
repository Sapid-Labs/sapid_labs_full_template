import 'package:slapp/features/shared/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final PackageInfo packageInfo = snapshot.data as PackageInfo;
          return Text(
            'Version: ${packageInfo.version}',
            style: context.bodySmall.primary,
          );
        }

        return const SizedBox();
      },
    );
  }
}
