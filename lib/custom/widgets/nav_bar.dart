import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../init.dart';

List<Map<String, Icon>> navBarsItems() {
  Map<String, Icon> editOrAddButton =
      (currentPath == Constants().editMessagePageRpute)
          ? {
              Constants().editMessage: Icon(
                Icons.edit_outlined,
                color: Colors.greenAccent,
              ),
            }
          : {
              Constants().sendMessage: Icon(
                Icons.add_outlined,
                color: Colors.greenAccent,
              ),
            };

  return [
    {
      Constants().rooms: Icon(
        Icons.groups_outlined,
        color: Colors.redAccent,
      )
    },
    editOrAddButton,
    {
      Constants().messages: Icon(
        Icons.message_outlined,
        color: Colors.blueAccent,
      ),
    }
  ];
}
