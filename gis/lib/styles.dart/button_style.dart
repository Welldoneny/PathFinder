import 'package:flutter/material.dart';

var buttonStyle = ButtonStyle(
  padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
  backgroundColor: WidgetStatePropertyAll(Colors.white.withValues(alpha: 0.6)),
  foregroundColor: const WidgetStatePropertyAll(Colors.black87),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  elevation: const WidgetStatePropertyAll(4),
  shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.2)),
);

