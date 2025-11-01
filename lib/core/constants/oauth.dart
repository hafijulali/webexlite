import 'package:flutter/foundation.dart';
import 'package:webexlite/init.dart';

class OAuthConstants {
  static String getRedirectUri() {
    final environment = kReleaseMode ? 'production' : 'development';
    return config![environment]['redirect_uri'];
  }
}
