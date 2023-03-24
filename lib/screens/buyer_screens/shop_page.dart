import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_picker/widgets/buyer/item_style_shop_view.dart';

import '../../../models/item.dart';

class ShopPage extends StatefulWidget {
  static var routeName = "shopPage";
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late double screenWidth;
  late double screenheight;

  late DatabaseReference ref;
  late Reference storageRef;
  var firestore = FirebaseFirestore.instance;
  late String uid;

  Map<String, dynamic> mainItems = {};
  var isItemsLoaded = false;

  void loadItems() async {
    DocumentSnapshot? doc;
    List<DocumentSnapshot<Object?>>? snapShot1;

    doc = await firestore.collection("stores").doc(shopName).get();
    if (mounted) {
      setState(() {
        mainItems.clear();
      });
    }

    if (doc.exists) {
      var data = (doc.data() as Map<String, dynamic>)["items"];
      var map = data;
      if (mounted) {
        setState(() {
          mainItems.addAll(map);
        });
      }
    }
    //updating from user cart
    Map<String, dynamic> cartItems = {};
    Map<String, dynamic> items = mainItems;
    final cartSnapShot = await ref.child("/users/$uid/cart/$shopName").get();
    if (cartSnapShot.exists) {
      Map<String, dynamic> map =
          jsonDecode(jsonEncode(cartSnapShot.value)) as Map<String, dynamic>;
      cartItems = map;
    } else {
      cartItems = {};
    }
    if (cartItems.isNotEmpty) {
      items.addAll(cartItems);
    }

    if (mounted) {
      setState(() {
        mainItems = items;
        isItemsLoaded = true;
      });
    }
  }

  late final String shopName;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    ref = FirebaseDatabase.instance.ref();
  }

  @override
  void didChangeDependencies() {
    shopName = ModalRoute.of(context)!.settings.arguments as String;
    loadItems();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height - topPadding;
    return Scaffold(
      appBar: AppBar(
          title: Text(shopName),
          centerTitle: true,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      body: !isItemsLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10),
              itemCount: mainItems.length,
              itemBuilder: (context, index) => ItemStyleShop(
                shopName: shopName,
                item: Item.map(mainItems.values.elementAt(index)),
                shopId: uid,
              ),
            ),
    );
  }
}
