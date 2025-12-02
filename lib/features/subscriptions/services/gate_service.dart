import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GateService extends ChangeNotifier {
  Future<void> setup() async {
    // Check if user is over any limits
  }
}
