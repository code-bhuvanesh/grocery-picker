import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:grocery_picker/widgets/buyer/item_counter.dart';

import '../../models/item.dart';

class ItemStyleShop extends StatefulWidget {
  ItemStyleShop(
      {super.key,
      required this.shopName,
      required this.item,
      required this.shopId});
  final String shopName;
  final String shopId;
  final Item item;

  @override
  State<ItemStyleShop> createState() => _ItemStyleShopState();
}

class _ItemStyleShopState extends State<ItemStyleShop> {
  var ref = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    var downloadUrl =
        "https://firebasestorage.googleapis.com/v0/b/grocerypicker-862b3.appspot.com/o/items%20images%2F${widget.item.name}.jpg?alt=media&token=b252239b-4a3f-4355-92a8-c2f46cfe9332";

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var w = screenWidth / 2.6;
    var h = screenHeight / 4;
    return Container(
      height: 1000,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Card(
        elevation: 7,
        shadowColor: const Color.fromARGB(50, 12, 4, 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: w,
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 55,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: downloadUrl,
                    placeholder: (context, url) => Container(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator()),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 5,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.item.name.inCaps,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "₹${widget.item.price}",
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
              ),
              widget.item.count == 0
                  ? GestureDetector(
                      onTap: (() {
                        widget.item.addToCart(
                          ref,
                          FirebaseAuth.instance.currentUser!.uid,
                          widget.shopId,
                          widget.shopName,

                        );
                        setState(() {
                          widget.item.count;
                        });
                      }),
                      child: SizedBox(
                        height: 45,
                        width: screenWidth / 5,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Card(
                              color: Colors.green,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Center(
                                  child: Text(
                                    "ADD",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ItemCounter(
                          itemCount: widget.item.count,
                          itemName: widget.item.name,
                          shopName: widget.shopName,
                          shopId: widget.shopId,
                          callOnCountZero: () {
                            setState(() {
                              widget.item.count = 0;
                            });
                          },
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
}
