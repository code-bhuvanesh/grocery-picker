import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grocery_picker/screens/buyer_screens/buyer_main_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:grocery_picker/screens/select_type_page.dart';
import 'package:grocery_picker/screens/seller_screens/seller_main_page.dart';
import 'package:grocery_picker/screens/seller_screens/setup_page.dart';

import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = "/splashScreen";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late StreamSubscription<User?> _listner;
  void checkuserNUll() {
    _listner =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        debugPrint('User is currently signed out!');
        Navigator.popAndPushNamed(context, LoginPage.routeName);
      } else {
        debugPrint('User is signed in!');

        String uid = FirebaseAuth.instance.currentUser!.uid;
        DatabaseReference ref =
            FirebaseDatabase.instance.ref("users/$uid/details");
        var defultType = await ref.child("defaultType").get();
        var shopName = await ref.child("shopName").get();
        String? type;
        if (defultType.exists) {
          type = defultType.value as String;
        }
        if (mounted) {
          if (type == "Buyer") {
            Navigator.of(context).popAndPushNamed(BuyerMainPage.routeName);
          } else if (type == "Seller") {
            if (shopName.exists) {
              Navigator.of(context).popAndPushNamed(SellerMainPage.routeName);
            } else {
              Navigator.of(context).popAndPushNamed(SetupPage.routeName);
            }
          } else {
            Navigator.of(context).popAndPushNamed(SelectType.routeName);
          }
        }
      }
      FlutterNativeSplash.remove();
    });
  }

  @override
  void initState() {
    super.initState();
    checkuserNUll();
  }

  @override
  void dispose() {
    _listner.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
