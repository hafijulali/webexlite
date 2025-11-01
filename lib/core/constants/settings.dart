import 'package:packer/core/constants/settings.dart';

mixin SettingConstants on BaseSettingConstants {
  @override
  String appThemeSettingsKey = 'AppTheme';
  @override
  String landingPageSettingsKey = 'LandingPage';
  @override
  String material3SettingsKey = 'Material3';
  @override
  String fontSizeSettingsKey = 'FontSize';
  String apiKeySettingsKey = 'ApiKey';
  String secureDatabaseSettingsKey = 'SecureDatabaseKey';
  String cloudProviderSettingsKey = 'CloudProivder';
  @override
  String usernameSettingsKey = 'Useranme';
  @override
  String isLoggedInSettingsKey = 'LoggedIn';
  String showSubtitleKey = 'Subtitle';
  String tokenSettingsKey = 'Token';
  String maxItemsSettingsKey = 'MaxItems';
  @override
  String messageOverlaySettingsKey = 'MessageOverlay';
  String cacheExpiryTimeSettingsKey = 'CacheExpiryTime';
  String personDatabaseFileName = 'person';
  String searchDatabaseFileName = 'search';
}