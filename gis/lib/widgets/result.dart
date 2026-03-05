import 'package:flutter/material.dart';

Widget resultRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.grey),
      const SizedBox(width: 8),
      Text('$label:', style: const TextStyle(fontSize: 16)),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  );
}