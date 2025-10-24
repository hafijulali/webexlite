import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:packer/core/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_latest;
import 'package:timezone/timezone.dart' as tz;
import 'package:webexapis/core/apicontract.dart';
import 'package:webexapis/webexapis.dart';

import 'core/constants/constants.dart';
import 'screens/home_page/home_page.dart';
import 'screens/login_page/login_page.dart';
import 'screens/messages_page/messages_page.dart';
import 'screens/rooms_page/rooms_page.dart';
import 'screens/settings_page/settings_page.dart';

Box? roomsDatabase;
Box? messagesDatabase;
Box? meetingsDatabase;
Box? personDatabase;
Box<dynamic>? settingsDatabase;
Box<dynamic>? blockDatabase;
// WARN: This `secureDatabase` object is only for compatibility reasons.
// As of 2025 there is no stable cross-paltform solution to securely store data.
// Flutter Secure Storage doesn't work well on Web, which is a deal-breaker.
// Web version of this app is hosted publicly, and needs secure way to login and access data.
Box<dynamic>? secureDatabase;
String? roomsDatabaseFilePath;
String? messagesDatabaseFilePath;
String? meetingsDatabaseFilePath;
String? settingsDatabaseFilePath;
String? blockDatabaseFilePath;
String? personDatabaseFilePath;
Directory? databaseDirectory;
WebexApis? webexApis;
Token? token;

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
String? accessToken; // This will be populated from the token object
String databaseFilePath = BaseConstants().appName;

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  Constants().roomsPageRoute: (_) => const RoomsPage(),
  Constants().messagesPageRoute: (_) =>
      const MessagesPage(roomId: '', roomTitle: '', roomType: ''),
  Constants().homePageRoute: (_) => const HomePage(),
  Constants().settingsPageRoute: (_) => const SettingsPage(),
  Constants().loginPageRoute: (_) => LoginPage(),
};

Map<String, WidgetBuilder> tabs = <String, WidgetBuilder>{
  Constants().roomsPageRoute: (_) => const RoomsPage(),
  Constants().sendMessagePageRoute: (_) =>
      const MessagesPage(roomId: '', roomTitle: '', roomType: ''),
};

Future<void> _initDatabase() async {
  databaseFilePath = kReleaseMode
      ? (await getApplicationDocumentsDirectory()).path
      : (await getTemporaryDirectory()).path;
  Hive.init(databaseFilePath);

  try {
    roomsDatabase = await Hive.openBox<dynamic>(
      Constants().roomsDatabaseFileName,
    );
  } catch (e) {
    debugPrint('Error opening roomsDatabase: $e');
    roomsDatabase = null;
  }

  try {
    messagesDatabase = await Hive.openBox(Constants().messagesDatabaseFileName);
  } catch (e) {
    debugPrint('Error opening messagesDatabase: $e');
    messagesDatabase = null;
  }

  try {
    meetingsDatabase = await Hive.openBox(Constants().meetingsDatabaseFileName);
  } catch (e) {
    debugPrint('Error opening meetingsDatabase: $e');
    meetingsDatabase = null;
  }

  try {
    settingsDatabase = await Hive.openBox<dynamic>(
      Constants().settingsDatabaseFileName,
    );
  } catch (e) {
    debugPrint('Error opening settingsDatabase: $e');
    settingsDatabase = null;
  }

  try {
    blockDatabase = await Hive.openBox<dynamic>(
      Constants().blockDatabaseFileName,
    );
  } catch (e) {
    debugPrint('Error opening blockDatabase: $e');
    blockDatabase = null;
  }

  try {
    personDatabase = await Hive.openBox<dynamic>(
      Constants().personDatabaseFileName,
    );
  } catch (e) {
    debugPrint('Error opening personDatabase: $e');
    personDatabase = null;
  }

  roomsDatabaseFilePath = roomsDatabase?.path.toString();
  messagesDatabaseFilePath = messagesDatabase?.path.toString();
  meetingsDatabaseFilePath = meetingsDatabase?.path.toString();
  settingsDatabaseFilePath = settingsDatabase?.path.toString();
  personDatabaseFilePath = personDatabase?.path.toString();
  if (!kIsWeb) {
    databaseDirectory = Directory(roomsDatabaseFilePath!).parent;
  }
}

Future<void> initApp() async {
  print("initApp: start");
  await dotenv.load(fileName: ".env");
  print("initApp: dotenv loaded");
  await _initDatabase(); // Call _initDatabase first
  print("initApp: database initialized");
  await _initServices();
  print("initApp: services initialized");
  await _initCloud();
  print("initApp: cloud initialized");
}

Future<void> _initCloud() async {}

Future<void> _initServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storedToken = settingsDatabase?.get(Constants().tokenSettingsKey);
  debugPrint('storedToken: $storedToken');
  if (storedToken != null) {
    try {
      token = Token.fromStorage(Map<String, dynamic>.from(storedToken));
      accessToken = token!.accessToken; // Initialize accessToken here
    } catch (e) {
      debugPrint("Failed to load token from storage: $e");
      await settingsDatabase?.delete(Constants().tokenSettingsKey);
    }
  }

  if (token != null) {
    webexApis = WebexApis(
        token: token,
        clientId: dotenv.env['CLIENT_ID']!,
        clientSecret: dotenv.env['CLIENT_SECRET']!,
        onTokenRefreshed: (newToken) async {
          token = newToken;
          accessToken = newToken.accessToken;
          await settingsDatabase?.put(
              Constants().tokenSettingsKey, newToken.toJson());
        });
  }
  debugPrint("webexApis is null: ${webexApis == null}");

  tz_latest.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
}
