import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:grocery_picker/screens/home_page.dart';

import '../models/item.dart';
import 'item_counter.dart';

class ItemStyleCart extends StatelessWidget {
  ItemStyleCart(
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

  var firestore = FirebaseFirestore.instance;

  Future<double> findPiceYourSave() async {
    debugPrint("highest page");
    debugPrint(item.name);
    var maxPrice = 0.0;
    var coll = firestore.collection("stores");
    var myPosition = await getPosition();
    if (myPosition != null) {
      var snapshot = await Geoflutterfire()
          .collection(collectionRef: coll)
          .within(center: myPosition, radius: 3.0, field: "location")
          .first;
      debugPrint("fhp length1 ${snapshot.length}");
      snapshot.removeWhere((element) => checkDist(
          myPosition,
          (element.data() as Map<String, dynamic>)["location"]["geopoint"],
          3.0));
      debugPrint("fhp length2 ${snapshot.length}");
      for (var i in snapshot) {
        var price =
            (i.data() as Map<String, dynamic>)["items"][item.name]["price"];
        maxPrice = max(maxPrice, price.toDouble());
        debugPrint("maxPrice = ${(i.data() as Map<String, dynamic>)["name"]}");
      }
      return maxPrice - item.price;
    }

    return 0.0;
  }
 //check why here and home pages shops are different
  @override
  Widget build(BuildContext context) {
    var downloadUrl =
        "https://firebasestorage.googleapis.com/v0/b/grocerypicker-862b3.appspot.com/o/items%20images%2F${item.name}.jpg?alt=media&token=b252239b-4a3f-4355-92a8-c2f46cfe9332";

    itemCount = item.count;
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
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
                              ),
                              FutureBuilder(
                                builder: (context, savePrice) =>
                                    (savePrice.data != 0.0 &&
                                            savePrice.connectionState ==
                                                ConnectionState.done)
                                        ? Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "you save ₹${savePrice.data}",
                                                  style: const TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                future: findPiceYourSave(),
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
    );
  }
}

extension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
}
