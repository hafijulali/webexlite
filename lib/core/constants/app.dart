import 'package:packer/core/constants/app.dart';

mixin AppConstants on BaseAppConstants {
  @override
  String appName = 'WebexLite';
  String roomsDatabaseFileName = 'rooms';
  String messagesDatabaseFileName = 'messages';
  String secureDatabaseFileName = 'secure';
  String appCodebase = 'https://gitlab.com/hafijulali/webexlite';
}
