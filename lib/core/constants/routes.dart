import 'package:packer/core/constants/routes.dart';

mixin RouteConstants on BaseRouteConstants {
  String sendMessagePageRoute = '/SendMessagePage';
  String roomsPageRoute = '/RoomsPage';
  String messagesPageRoute = '/MessagesPage';
  String editMessagePageRpute = '/EditMessagePage';
  @override
  String currentPageRoute = BaseRouteConstants().homePageRoute;
}
