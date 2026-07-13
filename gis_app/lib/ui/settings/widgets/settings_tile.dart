// Вспомогательный виджет для строки настройки
import 'package:flutter/material.dart';

Widget settingsTile({
  required IconData icon,
  required String title,
  String? subtitle,
  required Widget trailing,
  bool showDivider = true,
}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
      if (showDivider)
        const Divider(height: 1, indent: 48),
    ],
  );
}