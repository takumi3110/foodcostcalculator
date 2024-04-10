import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  const CancelButton({
    super.key,
    required this.onPressed,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white12,
        foregroundColor: Colors.white,
      ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))
    );
  }
}
