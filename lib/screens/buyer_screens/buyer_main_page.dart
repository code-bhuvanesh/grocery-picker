import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:grocery_picker/screens/buyer_screens/cart_page.dart';
import 'package:grocery_picker/screens/buyer_screens/buyer_home_page.dart';
import 'package:grocery_picker/screens/buyer_screens/buyer_orders_page.dart';

import '../../widgets/nav_bar.dart';

class BuyerMainPage extends StatefulWidget {
  const BuyerMainPage({Key? key}) : super(key: key);
  static const routeName = "/buyerMainPage";

  @override
  State<BuyerMainPage> createState() => _BuyerMainPageState();
}

class _BuyerMainPageState extends State<BuyerMainPage> {
  var _selectedIndex = 0;

  void changeIndex(int pos) {
    setState(() {
      _selectedIndex = pos;
    });
  }

  final pagesList = const [
    BuyerHomePage(),
    CartPage(),
    OrdersPage(),
  ];

  @override
  void initState() {
    // setOptimalDisplayMode();
    super.initState();
  }

  Future<void> setOptimalDisplayMode() async {
    final List<DisplayMode> supported = await FlutterDisplayMode.supported;
    final DisplayMode active = await FlutterDisplayMode.active;

    final List<DisplayMode> sameResolution = supported
        .where((DisplayMode m) =>
            m.width == active.width && m.height == active.height)
        .toList()
      ..sort((DisplayMode a, DisplayMode b) =>
          b.refreshRate.compareTo(a.refreshRate));

    final DisplayMode mostOptimalMode =
        sameResolution.isNotEmpty ? sameResolution.first : active;

    /// This setting is per session.
    /// Please ensure this was placed with `initState` of your root widget.
    await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        shadowColor: Colors.transparent,
      ),
      body: pagesList[_selectedIndex],
      bottomNavigationBar: NavBar(
        onItemTap: changeIndex,
        color: Colors.green,
        itemColor: Colors.white,
        items: const [
          "assets/icons/home-icon.svg",
          "assets/icons/cart-icon.svg",
          "assets/icons/orders-icon.svg",
        ],
      ),
    );
  }
}
