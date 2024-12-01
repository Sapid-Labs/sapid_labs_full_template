import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.sideLength = 100.0});

  final double sideLength;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: sideLength,
      height: sideLength,
    );
  }
}
