import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/item.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static var UID = FirebaseAuth.instance.currentUser?.uid;
  var ref = FirebaseDatabase.instance.ref("users/$UID");
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

  Future<void> placeOrder() async {
    ref.child("orders").set(cartItems);
    var ref1 = ref.root.child("storeUsers");
    cartItems.forEach((key, value) {
      ref1.child(key).child(UID!).set(value);
    });
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
                    children: const [
                      Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      Padding(
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
                                fontWeight: FontWeight.bold, fontSize: 26),
                          ),
                          Text(
                            "₹${getTotalItemPrice(cartItems)}",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: placeOrder,
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
        ],
      ),
    );
  }

  Widget storeWidget(Map<String, dynamic> store) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin:
                const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 10),
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
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...(store.values.first as Map<String, dynamic>)
            .values
            .map((e) => ItemStyle(
                  item: Item.map(e),
                  storeName: store.keys.first,
                  deleteItem: deleteItem,
                ))
            .toList(),
      ],
    );
  }
}

class ItemStyle extends StatelessWidget {
  ItemStyle(
      {super.key,
      required this.item,
      required this.storeName,
      required this.deleteItem});
  final Item item;
  final String storeName;
  final Function deleteItem;
  late int itemCount;

  static var UID = FirebaseAuth.instance.currentUser?.uid;
  var ref = FirebaseDatabase.instance.ref("users/$UID");

  late Reference storageRef;
  Future<String> getDownloadUrl(String imageName) async {
    storageRef = FirebaseStorage.instance.ref().child("items images");
    imageName = imageName.replaceAll(" ", "_");
    return storageRef.child("$imageName.jpg").getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    var downloadUrl =
        "https://firebasestorage.googleapis.com/v0/b/grocerypicker-862b3.appspot.com/o/items%20images%2F${item.name}.jpg?alt=media&token=b252239b-4a3f-4355-92a8-c2f46cfe9332";

    itemCount = item.count;
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Card(
        elevation: 7,
        shadowColor: const Color.fromARGB(50, 12, 4, 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: downloadUrl,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                    horizontal: 5,
                                  ),
                                  child: Text(
                                    item.name.inCaps,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "₹${item.price}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Text(
                                            "  per KG",
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      deleteItem(item.name, storeName);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )),
                                ItemCounter(
                                  itemCount: itemCount,
                                  itemName: item.name,
                                  storeName: storeName,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ItemCounter extends StatefulWidget {
  ItemCounter({
    Key? key,
    required this.itemCount,
    required this.itemName,
    required this.storeName,
  }) : super(key: key);

  int itemCount;
  final String itemName;
  final String storeName;

  @override
  State<ItemCounter> createState() => _ItemCounterState();
}

class _ItemCounterState extends State<ItemCounter> {
  static var UID = FirebaseAuth.instance.currentUser?.uid;
  var ref = FirebaseDatabase.instance.ref("users/$UID");
  void changeItemCount(String itemName, String storeName, int itemCount) {
    var userRef = ref.child("cart").child(storeName).child(itemName);

    userRef.get().then((value) {
      if (value.exists) {
        userRef.update({"count": itemCount});
      } else {
        userRef.update({"count": itemCount});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: Row(children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (widget.itemCount > 1) {
                widget.itemCount -= 1;
                changeItemCount(
                  widget.itemName,
                  widget.storeName,
                  widget.itemCount,
                );
              }
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 30,
            height: 30,
            child: const Card(
              color: Colors.green,
              child: Icon(
                Icons.remove,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Text(widget.itemCount.toString()),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.itemCount += 1;
              changeItemCount(
                widget.itemName,
                widget.storeName,
                widget.itemCount,
              );
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 30,
            height: 30,
            child: const Card(
              color: Colors.green,
              child: Icon(
                Icons.add,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

extension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
}
