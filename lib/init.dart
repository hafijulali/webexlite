import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:packer/core/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_latest;
import 'package:timezone/timezone.dart' as tz;
import 'package:webexapis/core/apicontract.dart';
import 'package:webexapis/webexapis.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/constants.dart';
import 'screens/home_page/home_page.dart';
import 'screens/login_page/login_page.dart';
import 'screens/messages_page/messages_page.dart';
import 'screens/rooms_page/rooms_page.dart';
import 'screens/settings_page/settings_page.dart';

Box? roomsDatabase;
Box? messagesDatabase;
Box<dynamic>? settingsDatabase;
Box<dynamic>? blockDatabase;
// WARN: This `secureDatabase` object is only for compatibility reasons.
// As of 2025 there is no stable cross-paltform solution to securely store data.
// Flutter Secure Storage doesn't work well on Web, which is a deal-breaker.
// Web version of this app is hosted publicly, and needs secure way to login and access data.
Box<dynamic>? secureDatabase;
String? roomsDatabaseFilePath;
String? messagesDatabaseFilePath;
String? settingsDatabaseFilePath;
String? blockDatabaseFilePath;
Directory? databaseDirectory;
WebexApis? webexApis;

TextEditingController searchTextController = TextEditingController();
TextEditingController apiKeyTextController = TextEditingController();
bool enableDebug = false;
bool showSubtitle = settingsDatabase?.get(
  Constants().showSubtitleKey,
  defaultValue: false,
);
int currentPageIndex = settingsDatabase?.get(
  Constants().landingPageSettingsKey,
  defaultValue: 0,
);
String currentPath = Constants().currentPageRoute;
String appVersion = '';
PageController pageController = PageController(initialPage: currentPageIndex);
String appThemeMode = settingsDatabase?.get(
  Constants().appThemeSettingsKey,
  defaultValue: Constants().systemTheme,
);
bool useMaterial3 = settingsDatabase?.get(
  Constants().material3SettingsKey,
  defaultValue: true,
);
double fontSize = settingsDatabase?.get(
  Constants().fontSizeSettingsKey,
  defaultValue: 10.0,
);
int maxItems = settingsDatabase?.get(
  Constants().maxItemsSettingsKey,
  defaultValue: 20,
);
String? accessToken = settingsDatabase?.get(Constants().tokenSettingsKey);
String databaseFilePath = BaseConstants().appName;

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  Constants().roomsPageRoute: (_) => const RoomsPage(),
  Constants().messagesPageRoute: (_) => const RoomsPage(),
  Constants().homePageRoute: (_) => const HomePage(),
  Constants().settingsPageRoute: (_) => const SettingsPage(),
  Constants().loginPageRoute: (_) => LoginPage(),
};

Map<String, Widget> tabs = <String, Widget>{
  Constants().roomsPageRoute: const RoomsPage(),
  Constants().sendMessagePageRoute: const RoomsPage(),
  Constants().messagesPageRoute: const MessagesPage(roomTitle: '', roomId: ''),
};

Future<void> initApp() async {
  await dotenv.load(fileName: ".env");
  await _initServices();
  await _initDatabase();
  await _initCloud();
}

Future<void> _initCloud() async {}

Future<void> _initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  webexApis = WebexApis(
    token: Token(
      accessToken: dotenv.env['ACCESS_TOKEN']!,
      refreshToken: dotenv.env['REFRESH_TOKEN']!,
      expiresIn: DateTime.fromMillisecondsSinceEpoch(7775999),
    ),
    clientId: dotenv.env['CLIENT_ID']!,
    clientSecret: dotenv.env['CLIENT_SECRET']!,
  );

  if (!kIsWeb) {
    tz_latest.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  }
}

Future<void> _initDatabase() async {
  databaseFilePath = kReleaseMode
      ? (await getApplicationDocumentsDirectory()).path
      : (await getTemporaryDirectory()).path;
  Hive.init(databaseFilePath);

  roomsDatabase = await Hive.openBox<dynamic>(
    Constants().roomsDatabaseFileName,
  );
  messagesDatabase = await Hive.openBox(Constants().messagesDatabaseFileName);
  settingsDatabase = await Hive.openBox<dynamic>(
    Constants().settingsDatabaseFileName,
  );
  blockDatabase = await Hive.openBox<dynamic>(
    Constants().blockDatabaseFileName,
  );
  roomsDatabaseFilePath = roomsDatabase!.path.toString();
  messagesDatabaseFilePath = messagesDatabase!.path.toString();
  settingsDatabaseFilePath = settingsDatabase!.path.toString();
  if (!kIsWeb) {
    databaseDirectory = Directory(roomsDatabaseFilePath!).parent;
  }
}
