import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_picker/screens/buyer_screens/buyer_main_page.dart';
import 'package:grocery_picker/screens/buyer_screens/search_page.dart';
import 'package:grocery_picker/screens/seller_screens/seller_main_page.dart';
import 'package:grocery_picker/screens/seller_screens/sellers_orders_page.dart';
import 'package:grocery_picker/screens/seller_screens/setup_page.dart';
import 'package:grocery_picker/screens/settings_page.dart';
import 'package:grocery_picker/screens/login_page.dart';
import 'package:grocery_picker/screens/buyer_screens/shop_page.dart';
import 'package:grocery_picker/screens/select_type_page.dart';
import 'package:grocery_picker/screens/splash_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        BuyerMainPage.routeName: (context) => const BuyerMainPage(),
        SellerMainPage.routeName: (context) => const SellerMainPage(),
        LoginPage.routeName: (context) => const LoginPage(),
        SearchPage.routeName: (context) => const SearchPage(),
        SettingsPage.routeName: (context) => const SettingsPage(),
        ShopPage.routeName: (context) => const ShopPage(),
        SelectType.routeName: (context) => SelectType(),
        SetupPage.routeName: (context) => SetupPage(),
        SellersOrdersPage.routeName: (context) => const SellersOrdersPage(),
      },
    );
  }
}
