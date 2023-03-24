import 'package:flutter/material.dart';

typedef CustomButtonCallBack = void Function();

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.btnText,
    required this.onClick,
    this.borderRadius = 20.0,
  });

  final String btnText;
  final CustomButtonCallBack onClick;
  double borderRadius = 20;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.green,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Text(
              btnText,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
