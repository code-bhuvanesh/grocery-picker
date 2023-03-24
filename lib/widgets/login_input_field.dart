import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  CustomInputField(
      {Key? key,
      required this.hintText,
      required this.controller,
      this.borderRadius = 20,
      this.isPassword, this.keyboardType})
      : super(key: key);
      TextInputType? keyboardType = TextInputType.text; 
  final String hintText;
  bool? isPassword = false;
  final TextEditingController controller;
  double borderRadius = 20;
  @override
  Widget build(BuildContext context) {
    isPassword ??= false;
    OutlineInputBorder tfBorder = OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)));
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: TextField(
          controller: controller,
          obscureText: isPassword!,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: hintText,
            labelStyle: const TextStyle(color: Colors.grey),
            border: tfBorder,
            enabledBorder: tfBorder,
          ),
        ));
  }
}
