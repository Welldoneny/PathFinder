import 'package:flutter/material.dart';
import 'package:path_finder/styles.dart/button_style.dart';

Widget buildDrawerButton() {
  return Positioned(
    top: 30,
    left: 16,
    child: Builder(
      builder: (context) => IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: const Icon(Icons.menu),
        style: buttonStyle,
      ),
    ),
  );
}
