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
) ?? Constants().systemTheme;
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
  logger?.debug('start', source: 'initDatabase');
  if (kIsWeb) {
    Hive.initFlutter(Constants().appName);
    logger?.debug(
        'Hive initialized for web with ${Constants().appName}',
        source: 'initDatabase');
  } else {
    final databaseFilePath = kReleaseMode
        ? (await getApplicationDocumentsDirectory()).path
        : (await getTemporaryDirectory()).path;
    Hive.init(databaseFilePath);
    logger?.debug(
        'Hive initialized for non-web with path: $databaseFilePath',
        source: 'initDatabase');
  }

  try {
    settingsDatabase = await Hive.openBox<dynamic>(
      Constants().settingsDatabaseFileName,
    );
    logger?.debug(
        'settingsDatabase opened successfully. Is null: ${settingsDatabase == null}',
        source: 'initDatabase');
  } catch (e) {
    logger?.error('Error opening settingsDatabase: $e', source: 'initDatabase');
    settingsDatabase = null;
  }

  try {
    blockDatabase = await Hive.openBox<dynamic>(
      Constants().blockDatabaseFileName,
    );
  } catch (e) {
    logger?.error('Error opening blockDatabase: $e', source: 'initDatabase');
    blockDatabase = null;
  }

  try {
    personDatabase = await Hive.openBox<dynamic>(
      Constants().personDatabaseFileName,
    );
  } catch (e) {
    logger?.error('Error opening personDatabase: $e', source: 'initDatabase');
    personDatabase = null;
  }

  try {
    searchDatabase = await Hive.openBox<dynamic>(
      Constants().searchDatabaseFileName,
    );
  } catch (e) {
    logger?.error('Error opening searchDatabase: $e', source: 'initDatabase');
    searchDatabase = null;
  }

  try {
    roomsDatabase = await Hive.openBox<dynamic>(
      Constants().roomsDatabaseFileName,
    );
  } catch (e) {
    logger?.error('Error opening roomsDatabase: $e', source: 'initDatabase');
    roomsDatabase = null;
  }

  try {
    messagesDatabase = await Hive.openBox<dynamic>(
      Constants().messagesDatabaseFileName,
    );
  } catch (e) {
    logger?.error('Error opening messagesDatabase: $e', source: 'initDatabase');
    messagesDatabase = null;
  }

  try {
    meetingsDatabase = await Hive.openBox<dynamic>(
      Constants().meetingsDatabaseFileName,
    );
  } catch (e) {
    logger?.error('Error opening meetingsDatabase: $e', source: 'initDatabase');
    meetingsDatabase = null;
  }

  try {
    await Hive.openBox<dynamic>('webexlite');
  } catch (e) {
    logger?.error('Error opening webexlite Hive box: $e', source: 'initDatabase');
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
  logger?.debug("start", source: 'initApp');
  await dotenv.load(fileName: ".env");
  logger?.debug("dotenv loaded", source: 'initApp');
  await _initDatabase(); // Call _initDatabase first
  logger?.debug("database initialized", source: 'initApp');
  await initServices();
  logger?.debug("services initialized", source: 'initApp');
  await _initCloud();
  logger?.debug("cloud initialized", source: 'initApp');
}

Future<void> _initCloud() async {}

Future<WebexApis?> initServices() async {
  logger?.debug('start', source: 'initServices');
  logger?.debug(
      'settingsDatabase is null: ${settingsDatabase == null}',
      source: 'initServices');
  if (settingsDatabase != null) {
    logger?.debug(
          'settingsDatabase contains tokenSettingsKey: ${settingsDatabase!.containsKey(Constants().tokenSettingsKey)}',
          source: 'initServices');  }
  logger?.debug(
      'Retrieving token with key: ${Constants().tokenSettingsKey}',
      source: 'initServices');
  final storedToken = settingsDatabase?.get(Constants().tokenSettingsKey);
  logger?.debug('storedToken (raw): $storedToken', source: 'initServices');
  if (storedToken != null) {
    try {
      token = Token.fromStorage(Map<String, dynamic>.from(storedToken));
      accessToken = token!.accessToken; // Initialize accessToken here
      logger?.debug('token loaded from storage successfully', source: 'initServices');
    } catch (e) {
      logger?.error("Failed to load token from storage: $e", source: 'initServices');
      await settingsDatabase?.delete(Constants().tokenSettingsKey);
      logger?.debug('tokenSettingsKey deleted from settingsDatabase', source: 'initServices');
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
    logger?.debug("webexApisInstance created: $webexApisInstance", source: 'initServices');
    tz_latest.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    return webexApisInstance;
  }
  logger?.debug("token is null, returning null WebexApis", source: 'initServices');

  tz_latest.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  return null;
}