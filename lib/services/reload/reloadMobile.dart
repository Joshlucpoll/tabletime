import 'package:flutter/material.dart';
import 'package:flutter_restart/flutter_restart.dart';

Future<void> reload(BuildContext context) async {
  await FlutterRestart.restartApp();
}
