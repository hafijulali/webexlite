import 'package:packer/core/constants/app.dart';

mixin AppConstants on BaseAppConstants {
  @override
  String appName = 'WebexLite';
  String roomsDatabaseFileName = 'rooms';
  String messagesDatabaseFileName = 'messages';
  String meetingsDatabaseFileName = 'meetings';
  String blockDatabaseFileName = 'block';
  String secureDatabaseFileName = 'secure';
  String appCodebase = 'https://gitlab.com/hafijulali/webexlite';
  String webexApiTokenUrl = 'https://developer.webex.com/docs/getting-started';
}
