import 'package:flutter/foundation.dart';

mixin OAuthConstants {
  String get redirectUri {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'webexlite://callback';
    }
  }
}
