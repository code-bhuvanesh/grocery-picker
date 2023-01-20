import 'package:flutter/material.dart';
import 'package:grocery_picker/screens/settings_page.dart';

import '../models/Store.dart';

class ShopPage extends StatefulWidget {
  static var routeName = "shopPage";
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late double screenWidth;
  late double screenheight;
  @override
  Widget build(BuildContext context) {
    final Store store = ModalRoute.of(context)!.settings.arguments as Store;

    var topPadding = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height - topPadding;
    TextStyle loactionTextStyle(double size) => TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: size);
    return Scaffold(
      appBar: AppBar(title: Text(store.name)),
    );
  }
}
