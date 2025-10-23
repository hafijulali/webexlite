import 'package:packer/core/constants/constants.dart';

import 'app.dart';
import 'oauth.dart';
import 'routes.dart';
import 'settings.dart';
import 'strings.dart';

class Constants extends BaseConstants
    with
        AppConstants,
        RouteConstants,
        StringConstants,
        SettingConstants,
        OAuthConstants {}
