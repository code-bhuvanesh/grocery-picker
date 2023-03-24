import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:grocery_picker/screens/buyer_screens/cart_page.dart';
import 'package:grocery_picker/screens/buyer_screens/buyer_orders_page.dart';
import 'package:grocery_picker/screens/seller_screens/seller_home_page.dart';

import '../../widgets/nav_bar.dart';

class SellerMainPage extends StatefulWidget {
  const SellerMainPage({Key? key}) : super(key: key);
  static const routeName = "/sellerMainPage";

  @override
  State<SellerMainPage> createState() => _SellerMainPageState();
}

class _SellerMainPageState extends State<SellerMainPage> {
  var _selectedIndex = 0;

  void changeIndex(int pos) {
    setState(() {
      _selectedIndex = pos;
    });
  }

  final pagesList = const [
    SellerHomePage(),
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
    );
  }
}
