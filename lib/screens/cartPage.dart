import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/Store.dart';
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

  Future<void> getCartItems() async {
    final snapShot = await ref.child("cart").get();
    if (snapShot.exists) {
      Map<String, dynamic> map =
          jsonDecode(jsonEncode(snapShot.value)) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          cartItems = map;
          print("************************************************");
          print(cartItems);
        });
      }
    }
  }

  @override
  void initState() {
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
          })
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
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, i) => storeWidget(
                  {cartItems.keys.elementAt(i): cartItems.values.elementAt(i)}),
            ),
          )
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
            margin: const EdgeInsets.all(5),
            child: Text(
              store.keys.first,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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

  // Widget itemStyle(Item item, String storeName) {
  //   var itemCount = item.count;
  //   return Container(
  //     height: 120,
  //     padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
  //     child: Card(
  //       elevation: 7,
  //       shadowColor: const Color.fromARGB(50, 12, 4, 4),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       child: Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.all(5),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             FutureBuilder(
  //               future: getDownloadUrl(item.name),
  //               builder:
  //                   (BuildContext context, AsyncSnapshot<String> snapshot) {
  //                 if (snapshot.connectionState == ConnectionState.done &&
  //                     snapshot.hasData) {
  //                   return SizedBox(
  //                     height: 100,
  //                     width: 100,
  //                     child: Center(
  //                       child: Image.network(
  //                         snapshot.data!,
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                   );
  //                 } else {
  //                   return const SizedBox(
  //                       height: 60,
  //                       width: 60,
  //                       child: Center(
  //                         child: CircularProgressIndicator(),
  //                       ));
  //                 }
  //               },
  //             ),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Expanded(
  //                     child: Container(
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                   vertical: 3,
  //                                   horizontal: 5,
  //                                 ),
  //                                 child: Text(
  //                                   item.name.inCaps,
  //                                   style: const TextStyle(
  //                                     fontWeight: FontWeight.w600,
  //                                     fontSize: 16,
  //                                   ),
  //                                 ),
  //                               ),
  //                               Container(
  //                                 margin:
  //                                     const EdgeInsets.symmetric(horizontal: 6),
  //                                 child: Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     Row(
  //                                       children: [
  //                                         Text(
  //                                           "₹${item.price}",
  //                                           style: const TextStyle(
  //                                             fontWeight: FontWeight.w700,
  //                                             fontSize: 16,
  //                                           ),
  //                                         ),
  //                                         const Text(
  //                                           "  per KG",
  //                                           style: TextStyle(
  //                                             fontSize: 10,
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ],
  //                                 ),
  //                               )
  //                             ],
  //                           ),
  //                           Column(
  //                             children: [
  //                               IconButton(
  //                                   onPressed: () {},
  //                                   icon: const Icon(
  //                                     Icons.delete,
  //                                     color: Colors.red,
  //                                   )),
  //                               Container(
  //                                 height: 30,
  //                                 child: Row(children: [
  //                                   GestureDetector(
  //                                     onTap: () {
  //                                       setState(() {
  //                                         if (itemCount > 0) {
  //                                           changeItemCount(
  //                                             item,
  //                                             storeName,
  //                                             itemCount - 1,
  //                                           );
  //                                         }
  //                                       });
  //                                     },
  //                                     child: Container(
  //                                       margin:
  //                                           EdgeInsets.symmetric(horizontal: 8),
  //                                       width: 30,
  //                                       height: 30,
  //                                       child: const Card(
  //                                         color: Colors.green,
  //                                         child: Icon(
  //                                           Icons.remove,
  //                                           size: 16,
  //                                           color: Colors.white,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Text(itemCount.toString()),
  //                                   GestureDetector(
  //                                     onTap: () {
  //                                       setState(() {
  //                                         changeItemCount(
  //                                           item,
  //                                           storeName,
  //                                           itemCount + 1,
  //                                         );
  //                                       });
  //                                     },
  //                                     child: Container(
  //                                       margin:
  //                                           EdgeInsets.symmetric(horizontal: 8),
  //                                       width: 30,
  //                                       height: 30,
  //                                       child: const Card(
  //                                         color: Colors.green,
  //                                         child: Icon(
  //                                           Icons.add,
  //                                           size: 16,
  //                                           color: Colors.white,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ]),
  //                               )
  //                             ],
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
              if (widget.itemCount > 0) {
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
