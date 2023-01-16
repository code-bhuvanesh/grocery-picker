import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:grocery_picker/screens/cartPage.dart';
import 'package:grocery_picker/screens/homePage.dart';
import 'package:grocery_picker/screens/loginPage.dart';
import 'package:grocery_picker/screens/ordersPage.dart';
import 'package:grocery_picker/screens/settingsPage.dart';

import '../widgets/navBar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  static const routeName = "/mainPage";

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _selectedIndex = 0;

  void changeIndex(int pos) {
    setState(() {
      _selectedIndex = pos;
    });
  }

  void checkuserNUll() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        Navigator.popAndPushNamed(context, LoginPage.routeName);
      } else {
        print('User is signed in!');
      }
    });
  }

  final PagesList = const [
    HomePage(),
    CartPage(),
    OrdersPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    checkuserNUll();
    setOptimalDisplayMode();
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
      body: PagesList[_selectedIndex],
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
