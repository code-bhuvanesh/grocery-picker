import 'dart:convert';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/item.dart';
import '../widgets/item_style_cart.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static var UID = FirebaseAuth.instance.currentUser?.uid;
  var ref = FirebaseDatabase.instance.ref("users/$UID");
  var firestore = FirebaseFirestore.instance;
  late double screenWidth;
  late double screenheight;
  Map<String, dynamic> cartItems = {};
  bool isCartItemsEmpty = false;
  Future<void> getCartItems() async {
    final snapShot = await ref.child("cart").get();
    if (snapShot.exists) {
      Map<String, dynamic> map =
          jsonDecode(jsonEncode(snapShot.value)) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          cartItems = map;
          isCartItemsEmpty = cartItems.isEmpty;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          cartItems = {};
          isCartItemsEmpty = cartItems.isEmpty;
        });
      }
    }
    if (mounted) {
      setState(() {
        isCartItemsEmpty = cartItems.isEmpty;
      });
    }
  }

  void updateCartItems() {
    ref.child("cart").onChildChanged.listen((event) {
      if (mounted) {
        setState(() {
          getCartItems();
        });
      }
    });
    ref.onChildRemoved.listen((event) {
      if (mounted) {
        setState(() {
          getCartItems();
        });
      }
    });
  }

  @override
  void initState() {
    updateCartItems();
    getCartItems();
    super.initState();
  }

  void deleteItem(String itemName, String storeName) {
    var userRef = ref.child("cart").child(storeName).child(itemName);

    userRef.remove().then((value) => {
          setState(() {
            (cartItems[storeName] as Map<String, dynamic>).remove(itemName);
            if ((cartItems[storeName] as Map<String, dynamic>).isEmpty) {
              cartItems.remove(storeName);
            }
            isCartItemsEmpty = cartItems.isEmpty;
          })
        });
  }

  num getTotalItemPrice(Map<String, dynamic> stores) {
    num total = 0;
    if (stores.isNotEmpty) {
      stores.forEach((key, value) {
        (value as Map<String, dynamic>).forEach((key1, value1) {
          total += (value1["price"] as num) * (value1["count"] as num);
        });
      });
    }
    return total;
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 54, 54, 54),
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }

  void placeOrder(DateTime pickupTime) async {
    var orderedTime = DateTime.now();
    var curRef = ref.child("orders").push();
    var orderId = curRef.key;
    await curRef.child("items").set(cartItems);
    await curRef.child("orderId").set(orderId);
    await curRef.child("collected").set(false);
    await curRef.child("orderedTime").set(orderedTime.toIso8601String());
    await curRef.child("pickupTime").set(pickupTime.toIso8601String());
    var ref1 = ref.root.child("storeUsers");
    cartItems.forEach((key, value) async {
      var total = getTotalItemPrice({key: value});
      await ref1.child(key).child(UID!).child(orderId!).set({
        "items": value,
        "collected": false,
        "orderId": orderId,
        "orderedTime": orderedTime.toIso8601String(),
        "pickupTIme": pickupTime.toIso8601String(),
        "total": total
      });
    });
    await ref.child("cart").set({});
    showToast("order placed");
  }

  Future<double?> FindHighestPrice(String itemName) async {
    print("highest page");
    print(itemName);
    var maxPrice = 0.0;
    var snapshot = await firestore
        .collection("stores")
        .where("items.name", isEqualTo: itemName)
        .get();
    for (var i in snapshot.docs) {
      print(i.data());
    }
  }

  void _openDateTimePickerWithCustomButton(BuildContext context) {
    BottomPicker.time(
      title: 'Select your pickup time',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ),
      onSubmit: (date) {
        placeOrder(date);
        print("placed order");
      },
      onClose: () {
        print('Picker closed');
      },
      displayCloseIcon: false,
      pickerTextStyle: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      bottomPickerTheme: BottomPickerTheme.blue,
      dismissable: true,
      displayButtonIcon: false,
      buttonText: 'Confirm',
      buttonTextStyle: const TextStyle(color: Colors.white),
      buttonSingleColor: Colors.green,
      minDateTime: DateTime.now(),
      maxDateTime: DateTime.now().add(const Duration(hours: 5)),
      // gradientColors: const [
      //   Color(0xfffdcbf1),
      //   Color(0xffe6dee9),
      // ],
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height - topPadding;
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
                    children: [
                      SvgPicture.asset(
                        "assets/icons/cart-icon.svg",
                        height: 20,
                        width: 20,
                        color: Colors.white,
                      ),
                      const Padding(
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
          ),
          Expanded(
            child: cartItems.isNotEmpty
                ? ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, i) => storeWidget({
                      cartItems.keys.elementAt(i): cartItems.values.elementAt(i)
                    }),
                  )
                : Center(
                    child: isCartItemsEmpty
                        ? const Text("your cart is empty")
                        : const CircularProgressIndicator(),
                  ),
          ),
          cartItems.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            "₹${getTotalItemPrice(cartItems)}",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 26),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: (() =>
                            _openDateTimePickerWithCustomButton(context)),
                        child: Container(
                          width: 200,
                          height: 50,
                          margin: const EdgeInsets.all(10),
                          child: Card(
                            color: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            child: const Center(
                                child: Text(
                              "Place Order",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget storeWidget(Map<String, dynamic> store) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 7,
        shadowColor: const Color.fromARGB(50, 12, 4, 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(
                    top: 10, bottom: 5, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      store.keys.first,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      "₹${getTotalItemPrice(store)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...(store.values.first as Map<String, dynamic>)
                .values
                .map((e) => ItemStyleCart(
                      item: Item.map(e),
                      storeName: store.keys.first,
                      deleteItem: deleteItem,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
