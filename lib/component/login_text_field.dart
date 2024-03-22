import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final String hintText;
  final TextInputType textInputType;
  final TextEditingController textEditingController;
  final bool isObscureText;
  final Widget? suffixIcon;
  final Function(String)? onChanged;


  const LoginTextField({
    super.key,
    required this.hintText,
    required this.textInputType,
    required this.textEditingController,
    this.isObscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        width: 300,
        child: TextField(
          keyboardType: textInputType,
          controller: textEditingController,
          decoration: InputDecoration(
              hintText: hintText,
            suffixIcon: suffixIcon
          ),
          obscureText: isObscureText,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
