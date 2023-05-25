import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  //splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Request permission to receive notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  //set device orientation to potrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
  runApp(const MyApp());
}

void initFirebaseMessageingService() {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  messaging.getToken().then((token) {
    print("token is : ");
    print(token);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    print('Message data: ${message.data}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // initFirebaseMessageingService(); 

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
