import 'package:flutter/material.dart';

Widget searchBar(
  BuildContext context,
  void Function() onEditingComplete,
  TextEditingController searchTextController, [
  String hintText = 'Search',
]) {
  return Container(
    width: MediaQuery.of(context).size.width / 1.5,
    height: 50,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blueGrey),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Center(
      child: TextField(
        textAlign: TextAlign.center,
        onEditingComplete: onEditingComplete,
        controller: searchTextController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => searchTextController.clear(),
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    ),
  );
}
