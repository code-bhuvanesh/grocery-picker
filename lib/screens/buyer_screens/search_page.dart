import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/item.dart';
import '../../models/shop.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  static const routeName = "/searchPage";
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference ref;
  late Reference storageRef;
  bool noData = false;
  Map<String, dynamic> mainItems = {};
  Map<String, dynamic> items = {};
  @override
  void initState() {
    ref = database.ref();
    storageRef = FirebaseStorage.instance.ref();
    // custom();
    loadItems();
    super.initState();
  }

  void loadItems() async {
    final snapShot = await ref.child("stores").get();
    if (snapShot.exists) {
      noData = false;
      Map<String, dynamic> map =
          jsonDecode(jsonEncode(snapShot.value)) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          mainItems = map;
          // items = map;
        });
      }
    } else {
      noData = true;
    }
  }

  var yourLocality = "Enable";
  var yourCity = "Location";

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 54, 54, 54),
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }

  void addToCart(Shop shop, Item item) {
    var userRef = ref
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("cart")
        .child(shop.name)
        .child(item.name);

    userRef.child("count").get().then((value) {
      if (value.exists) {
        var itemCount = value.value as int;
        userRef.update({"count": (itemCount + 1)});
      } else {
        userRef.set(
          item.toMapC(),
        );
      }
    });
    showToast("item added to cart");
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      items = {};
    }
    items = mainItems;

    debugPrint("*******");
    setState(() {
      items = Map.from(items)..removeWhere((k, v) => !k.startsWith(keyword));
    });
    debugPrint(items.toString());
    debugPrint("*******");
    debugPrint(mainItems.toString());
  }

  late double screenWidth;
  late double screenheight;
  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height - topPadding;
    TextStyle loactionTextStyle(double size) => TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: size);
    const searchFieldBorder = OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 245, 245, 245),
          width: 1.0,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.all(Radius.circular(50)));
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: topPadding, left: 5, right: 5),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                autofocus: true,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  debugPrint(value);
                  search(value);
                },
                decoration: InputDecoration(
                    hintText: "search for shops",
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 233, 233),
                    prefixIcon: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                    ),
                    isCollapsed: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: searchFieldBorder,
                    focusedBorder: searchFieldBorder,
                    enabledBorder: searchFieldBorder),
              ),
            ),
            Expanded(
              child: mainItems.isEmpty
                  ? noData
                      ? const Center(
                          child: Text("no items in database"),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        )
                  : Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: ((context, i) => shop(
                              Shop.fromMap(
                                items.values.elementAt(i),
                              ),
                            )),
                      )),
            ),
          ],
        ),
      ),
    );
  }

  Widget shop(Shop shop) {
    shop.items.shuffle();
    return SizedBox(
      height: screenheight / 4,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.all(5),
              child: Text(
                shop.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
              child: ListView(
            scrollDirection: Axis.horizontal,
            children: shop.items.map((e) => itemStyle(shop, e)).toList(),
          ))
        ],
      ),
    );
  }

  Widget itemStyle(Shop shop, Item item) {
    var downloadUrl =
        "https://firebasestorage.googleapis.com/v0/b/grocerypicker-862b3.appspot.com/o/items%20images%2F${item.name}.jpg?alt=media&token=b252239b-4a3f-4355-92a8-c2f46cfe9332";

    var w = screenWidth / 2.6;
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 60,
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
                        item.name.inCaps,
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
                        GestureDetector(
                          onTap: (() => addToCart(shop, item)),
                          child: const Card(
                            color: Colors.green,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Icon(
                                  size: 16,
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
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
