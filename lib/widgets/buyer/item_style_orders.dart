import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/item.dart';
import 'item_counter.dart';

class ItemStyleOrders extends StatelessWidget {
  ItemStyleOrders({
    super.key,
    required this.item,
    required this.shopName,
  });
  final Item item;
  final String shopName;
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
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Card(
        elevation: 7,
        shadowColor: const Color.fromARGB(50, 12, 4, 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(3),
                height: 50,
                width: 50,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "₹${item.price * item.count}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text("X${item.count}"),
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

extension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
}
