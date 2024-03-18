import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final Function() onPressed;
  final String childText;
  final bool isError;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.childText,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isError ? Colors.white38 : Colors.blueAccent,
        foregroundColor: Colors.white
      ),
        onPressed:onPressed,
        child: Text(childText, style: const TextStyle(fontWeight: FontWeight.bold),)
    );
  }
}
