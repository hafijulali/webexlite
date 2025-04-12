import 'package:flutter/material.dart';

import '../../init.dart';

Future<void> safePop(BuildContext context) async {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

Future<String?> safePopWithResult(BuildContext context, String result) async {
  if (Navigator.canPop(context)) {
    Navigator.pop(context, result);
  }
  return 'NONE';
}

void safePush(BuildContext context, String route) {
  if (currentPath != route) {
    Navigator.pushNamed(context, route);
  }
}
