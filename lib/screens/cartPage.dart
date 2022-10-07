import 'dart:ui';

import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).viewPadding.top;
    var appBarPadding = AppBar().preferredSize.height;
    return Container(
      margin: EdgeInsets.only(top: topPadding),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: appBarPadding,
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text("Cart",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
