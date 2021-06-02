import 'package:flutter/material.dart';
import 'dart:js' as js;

Future<void> reload(BuildContext context) async {
  js.context.callMethod("reload");
}
