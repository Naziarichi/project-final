import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String label;
  final String hint;
  final IconData icon;
  final String? errorText;

  const InputField({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.label,
    required this.hint,
    required this.icon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: keyboardType == TextInputType.visiblePassword,
      decoration: InputDecoration(
        errorText: errorText,
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label field is empty";
        }
        if (keyboardType == TextInputType.emailAddress &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return "Enter a valid email";
        }
        if (keyboardType == TextInputType.visiblePassword && value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }
}
