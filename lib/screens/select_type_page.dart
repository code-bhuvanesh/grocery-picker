import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grocery_picker/screens/seller_screens/seller_main_page.dart';
import 'package:grocery_picker/screens/seller_screens/setup_page.dart';

import 'buyer_screens/buyer_main_page.dart';

class SelectType extends StatefulWidget {
  SelectType({super.key});

  static const routeName = "/selectPage";

  @override
  State<SelectType> createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  var uid = FirebaseAuth.instance.currentUser!.uid;

  var ref = FirebaseDatabase.instance.ref("users");

  Future<void> asSeller(BuildContext context) async {
    ref = ref.child(uid);
    ref.set({
      "details": {"defaultType": "Seller"}
    });
    var shopName = await ref.child("details/ShopName").get();
    if (shopName.exists && mounted) {
      Navigator.of(context).popAndPushNamed(SellerMainPage.routeName);
    } else {
      Navigator.of(context).popAndPushNamed(SetupPage.routeName);
    }
  }

  void asBuyer(BuildContext context) {
    ref = ref.child(uid);
    var username = FirebaseAuth.instance.currentUser!.displayName;
    ref.update({
      "details": {"username": username, "defaultType": "Buyer"}
    });
    Navigator.of(context).popAndPushNamed(BuyerMainPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color.fromARGB(255, 250, 250, 250),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
              child: const FittedBox(
                child: Text(
                  "how your going to use\nGrocery Picker?",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            selectButton("AS A SELLER", () => asSeller(context)),
            selectButton("AS A BUYER", () => asBuyer(context))
          ],
        ),
      ),
    );
  }

  Widget selectButton(String type, void Function() onClick) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: onClick,
        child: Card(
          color: Colors.green,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
            child: Text(
              type,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
