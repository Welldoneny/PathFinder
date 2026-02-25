import 'package:flutter/material.dart';

Widget buildDrawerButton() {
  return Positioned(
    top: 22,
    left: 16,
    child: Builder(
      builder: (context) => IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: const Icon(Icons.menu, color: Colors.black),
      ),
    ),
  );
}