import 'package:flutter/foundation.dart';
import 'package:webexlite/init.dart';

class OAuthConstants {
  static String getRedirectUri() {
    final environment = kReleaseMode ? 'production' : 'development';
    if (kIsWeb) {
      return config![environment]['redirect_uri'];
    } else {
      return 'webexlite://callback';
    }
  }
}
