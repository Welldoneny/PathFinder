import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final ButtonStyle? style;

  const LocationButton({
    required this.onPressed,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: style,
      icon: const Icon(Icons.my_location, color: Colors.black),
    );
  }
}