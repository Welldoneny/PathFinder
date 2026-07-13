import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({
    super.key,
    this.style,
    this.onPressed,
    this.isDisabled = false,
  });

  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isDisabled ? "Убрать геометку": "Показать местоположение",
      onPressed: onPressed,
      style: style,
      icon: Icon(
        isDisabled ? Icons.location_disabled : Icons.my_location,
        color: isDisabled ? Colors.grey : Colors.black,
      ),
    );
  }
}
