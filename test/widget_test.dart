import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webexlite/init.dart';
import 'package:webexlite/main.dart';
import 'package:webexlite/screens/home_page/home_page.dart';

void main() {
  testWidgets('HomePage builds smoke test', (WidgetTester tester) async {
    final Directory systemTemp = Directory.systemTemp;
    final String tempPath = systemTemp.path;

    TestWidgetsFlutterBinding.ensureInitialized();

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return tempPath;
      }
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempPath;
      }
      return null;
    });

    await initApp();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that HomePage is present.
    expect(find.byType(HomePage), findsOneWidget);
  });
}
