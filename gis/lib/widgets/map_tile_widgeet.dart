import 'package:flutter/material.dart';

Widget buildMapTileWidget(BuildContext context, String title, String image, String value) {
  return InkWell(
    onTap: () {
      Navigator.pop(context, value);
    },
    child: Card(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(padding: const EdgeInsets.all(6), child: Text(title)),
        ],
      ),
    ),
  );
}
