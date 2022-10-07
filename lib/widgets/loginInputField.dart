import 'package:flutter/material.dart';

class LoginInputField extends StatelessWidget {
  LoginInputField(
      {Key? key,
      required this.hintText,
      required this.controller,
      this.isPassword})
      : super(key: key);
  final String hintText;
  bool? isPassword = false;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    isPassword ??= false;
    OutlineInputBorder tfBorder = const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(20)));
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        child: TextField(
          controller: controller,
          obscureText: isPassword!,
          decoration: InputDecoration(
            labelText: hintText,
            labelStyle: const TextStyle(color: Colors.grey),
            border: tfBorder,
            enabledBorder: tfBorder,
          ),
        ));
  }
}
