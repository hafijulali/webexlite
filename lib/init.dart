import 'dart:convert';

import 'package:flutter/services.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/adapters.dart';

import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz_latest;
import 'package:timezone/timezone.dart' as tz;
import 'package:webexapis/core/apicontract.dart';
import 'package:webexapis/webexapis.dart';
import 'package:packer/logging/logging.dart';

import 'core/constants/constants.dart';
import 'screens/home_page/home_page.dart';
import 'screens/login_page/login_page.dart';
import 'screens/messages_page/messages_page.dart';
import 'screens/messages_page/send_messages_page.dart';
import 'screens/rooms_page/rooms_page.dart';
import 'screens/settings_page/settings_page.dart';

Map<String, dynamic>? config;
Box? roomsDatabase;
Box? messagesDatabase;
Box? meetingsDatabase;
Box? personDatabase;
Box? searchDatabase;
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
String? searchDatabaseFilePath;
Directory? databaseDirectory;
Token? token;
PackerLogger? logger;

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
  Constants().sendMessagePageRoute: (_) => const SendMessagesPage(roomId: ''),
};

Future<void> _initConfig() async {
  final configString = await rootBundle.loadString('assets/config.json');
  config = json.decode(configString);
}

Future<void> _initDatabase() async {
  logger?.log('initDatabase: start');
  if (kIsWeb) {
    Hive.initFlutter(Constants().appName);
    logger?.log(
        'initDatabase: Hive initialized for web with ${Constants().appName}');
  } else {
    final databaseFilePath = kReleaseMode
        ? (await getApplicationDocumentsDirectory()).path
        : (await getTemporaryDirectory()).path;
    Hive.init(databaseFilePath);
    logger?.log(
        'initDatabase: Hive initialized for non-web with path: $databaseFilePath');
  }

  try {
    settingsDatabase = await Hive.openBox<dynamic>(
      Constants().settingsDatabaseFileName,
    );
    logger?.log(
        'initDatabase: settingsDatabase opened successfully. Is null: ${settingsDatabase == null}');
  } catch (e) {
    logger?.log('initDatabase: Error opening settingsDatabase: $e');
    settingsDatabase = null;
  }

  try {
    blockDatabase = await Hive.openBox<dynamic>(
      Constants().blockDatabaseFileName,
    );
  } catch (e) {
    logger?.log('Error opening blockDatabase: $e');
    blockDatabase = null;
  }

  try {
    personDatabase = await Hive.openBox<dynamic>(
      Constants().personDatabaseFileName,
    );
  } catch (e) {
    logger?.log('Error opening personDatabase: $e');
    personDatabase = null;
  }

  try {
    searchDatabase = await Hive.openBox<dynamic>(
      Constants().searchDatabaseFileName,
    );
  } catch (e) {
    logger?.log('Error opening searchDatabase: $e');
    searchDatabase = null;
  }

  try {
    roomsDatabase = await Hive.openBox<dynamic>(
      Constants().roomsDatabaseFileName,
    );
  } catch (e) {
    logger?.log('Error opening roomsDatabase: $e');
    roomsDatabase = null;
  }

  try {
    messagesDatabase = await Hive.openBox<dynamic>(
      Constants().messagesDatabaseFileName,
    );
  } catch (e) {
    logger?.log('Error opening messagesDatabase: $e');
    messagesDatabase = null;
  }

  roomsDatabaseFilePath = roomsDatabase?.path.toString();
  messagesDatabaseFilePath = messagesDatabase?.path.toString();
  meetingsDatabaseFilePath = meetingsDatabase?.path.toString();
  settingsDatabaseFilePath = settingsDatabase?.path.toString();
  personDatabaseFilePath = personDatabase?.path.toString();
  searchDatabaseFilePath = searchDatabase?.path.toString();
  if (!kIsWeb && roomsDatabaseFilePath != null) {
    databaseDirectory = Directory(roomsDatabaseFilePath!).parent;
  }
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initConfig();
  logger = PackerLoggerFactory.create(LoggingBackend.file);
  logger?.log("initApp: start");
  await dotenv.load(fileName: ".env");
  logger?.log("initApp: dotenv loaded");
  await _initDatabase(); // Call _initDatabase first
  logger?.log("initApp: database initialized");
  await initServices();
  logger?.log("initApp: services initialized");
  await _initCloud();
  logger?.log("initApp: cloud initialized");
}

Future<void> _initCloud() async {}

Future<WebexApis?> initServices() async {
  logger?.log('initServices: start');
  logger?.log(
      'initServices: settingsDatabase is null: ${settingsDatabase == null}');
  if (settingsDatabase != null) {
    logger?.log(
        'initServices: settingsDatabase contains tokenSettingsKey: ${settingsDatabase!.containsKey(Constants().tokenSettingsKey)}');
  }
  logger?.log(
      'initServices: Retrieving token with key: ${Constants().tokenSettingsKey}');
  final storedToken = settingsDatabase?.get(Constants().tokenSettingsKey);
  logger?.log('initServices: storedToken (raw): $storedToken');
  if (storedToken != null) {
    try {
      token = Token.fromStorage(Map<String, dynamic>.from(storedToken));
      accessToken = token!.accessToken; // Initialize accessToken here
      logger?.log('initServices: token loaded from storage successfully');
    } catch (e) {
      logger?.error("initServices: Failed to load token from storage: $e");
      await settingsDatabase?.delete(Constants().tokenSettingsKey);
      logger
          ?.log('initServices: tokenSettingsKey deleted from settingsDatabase');
    }
  }

  if (token != null) {
    final webexApisInstance = WebexApis(
        token: token,
        clientId: dotenv.env['CLIENT_ID']!,
        clientSecret: dotenv.env['CLIENT_SECRET']!,
        onTokenRefreshed: (newToken) async {
          token = newToken;
          accessToken = newToken.accessToken;
          await settingsDatabase?.put(
              Constants().tokenSettingsKey, newToken.toJson());
        });
    logger?.log("initServices: webexApisInstance created: $webexApisInstance");
    tz_latest.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    return webexApisInstance;
  }
  logger?.log("initServices: token is null, returning null WebexApis");

  tz_latest.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  return null;
}