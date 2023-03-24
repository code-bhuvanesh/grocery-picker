import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../models/item.dart';

class ItemStyle extends StatefulWidget {
  const ItemStyle({super.key, required this.item});
  final Item item;

  @override
  State<ItemStyle> createState() => _ItemStyleState();
}

class _ItemStyleState extends State<ItemStyle> {
  var ref = FirebaseDatabase.instance.ref();
  var uid = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    // var downloadUrl =
    //     "https://firebasestorage.googleapis.com/v0/b/grocerypicker-862b3.appspot.com/o/items%20images%2F${uid + widget.item.name}.jpg?alt=media&token=b252239b-4a3f-4355-92a8-c2f46cfe9332";
    var downloadUrl =
        "https://firebasestorage.googleapis.com/v0/b/grocerypicker-862b3.appspot.com/o/items%20images%2F${widget.item.name}.jpg?alt=media&token=b252239b-4a3f-4355-92a8-c2f46cfe9332";

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var w = screenWidth / 2.6;
    var h = screenHeight / 4;
    return Container(
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
              Expanded(
                child: Container(
                  child: Center(
                    child: CachedNetworkImage(
                      // errorWidget: Container(child: Icon(Icons.no_photography)),
                      imageUrl: downloadUrl,
                      placeholder: (context, url) => Container(
                          height: 40,
                          width: 40,
                          child: const CircularProgressIndicator()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
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
                ],
              ),
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
