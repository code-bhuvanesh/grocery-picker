import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_picker/screens/seller_screens/sellers_orders_page.dart';
import 'package:grocery_picker/widgets/seller/add_item_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:grocery_picker/screens/settings_page.dart';
import 'package:grocery_picker/screens/buyer_screens/shop_page.dart';

import '../../models/item.dart';
import '../../models/shop.dart';
import '../../widgets/buyer/item_style_shop_view.dart';
import '../../widgets/seller/item_style.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({Key? key}) : super(key: key);

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  static const searchFieldBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(255, 245, 245, 245),
        width: 1.0,
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.all(Radius.circular(50)));

  FirebaseDatabase database = FirebaseDatabase.instance;
  var firestore = FirebaseFirestore.instance;
  var isItemsLoaded = false;
  Map<String, dynamic> mainItems = {};
  GeoFirePoint? myPosition;
  late DatabaseReference ref;
  late double screenWidth;
  late double screenheight;
  late ScrollController scrollController;
  String? shopName;
  late Reference storageRef;
  double shopRadius = 3.0;
  late String uid;
  var yourCity = "Location";
  var yourLocality = "Enable";

  @override
  void initState() {
    ref = database.ref();
    storageRef = FirebaseStorage.instance.ref();
    uid = FirebaseAuth.instance.currentUser!.uid;
    getGeoLoaction();
    scrollController = ScrollController();

    super.initState();
  }

  void getGeoLoaction() async {
    var permissionResult = await Permission.location.request();
    if (permissionResult.isGranted) {
      var pos = await getPosition();
      var loc = await getLocality();
      var city = await getCity();
      if (mounted) {
        setState(() {
          myPosition = pos;
          yourLocality = loc;
          yourCity = city;
        });

        loadItems(null);
      }
    } else {
      toastMsg("location permission Denied");
      await openAppSettings();
      getGeoLoaction();
    }
  }

  Future<void> loadItems(String? searchText) async {
    QuerySnapshot<Map<String, dynamic>>? doc;
    List<DocumentSnapshot<Object?>>? snapShot1;

    var sn = (await ref.child("users/$uid/details/shopName").get()).value;
    if (sn != null) {
      setState(() {
        shopName = sn as String;
      });
    } else {
      ref.child("users/$uid/details/shopName").set("Agro Grocery");
      shopName = "Agro Grocery";
    }

    doc =
        await firestore.collection("stores").doc(uid).collection("items").get();
    if (mounted) {
      setState(() {
        mainItems.clear();
      });
    }

    if (doc.size > 0) {
      for (var i in doc.docs) {
        if (i.exists) {
          var data = i.data() as Map<String, dynamic>;
          print(data);
          // var shopName = data["name"] as String;
          // var map = {shopName: data};
          if (mounted) {
            setState(() {
              mainItems.addAll(data);
            });
          }
        }
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

  Future<String> getDownloadUrl(String imageName) async {
    storageRef = FirebaseStorage.instance.ref().child("items images");
    imageName = imageName.replaceAll(" ", "_");
    return storageRef.child("$imageName.jpg").getDownloadURL();
  }

  // add new item buy the seller to thier shop to the database
  void addItem() {}

  Widget shopWidget(Shop shop) {
    // shop.items.shuffle();
    var w = screenWidth / 2.6;
    var maxItems = shop.items.length > 5 ? (5 + 1) : shop.items.length;
    return SizedBox(
      height: screenheight / 3.1,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(ShopPage.routeName, arguments: shop.name)
                        .then((_) => loadItems(null)),
                    child: const Text(
                      "show all",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 5),
              scrollDirection: Axis.horizontal,
              itemCount: maxItems,
              itemBuilder: (context, index) => index != maxItems
                  ? ItemStyleShop(
                      shopName: shop.name,
                      item: shop.items[index],
                      shopId: shop.shopId,
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushNamed(ShopPage.routeName, arguments: shop),
                        child: Card(
                          elevation: 7,
                          shadowColor: const Color.fromARGB(50, 12, 4, 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            width: w,
                            padding: const EdgeInsets.all(5),
                            child: const Center(
                              child: Text("show all",
                                  style: TextStyle(
                                    color: Colors.green,
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // setLocation();

    var topPadding = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height - topPadding;

    var w = screenWidth / 2;
    var h = MediaQuery.of(context).size.height / 5;
    TextStyle loactionTextStyle(double size) => TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: size);

    return Container(
      margin: EdgeInsets.only(
        top: topPadding,
      ),
      child: Stack(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.all(0),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              color: Colors.green,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: (shopName != null)
                            ? Text(
                                shopName!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 25, color: Colors.white),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: (() {
                            Navigator.of(context)
                                .pushNamed(SettingsPage.routeName);
                            // loadItems(null);
                            // showToast("");
                            // setLocation();
                          }),
                          child: Row(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                child: const Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed(SellersOrdersPage.routeName),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Padding(
                                    padding: EdgeInsets.all(3),
                                    child: Image.asset(
                                      "assets/images/orders_icon.png",
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    // width: 200,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: TextField(
                      onTap: () {
                        // Navigator.of(context).pushNamed(SearchPage.routeName);
                      },
                      // readOnly: true,
                      maxLines: 1,
                      onChanged: loadItems,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: "search for items",
                        filled: true,
                        fillColor: Color.fromARGB(255, 233, 233, 233),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Icon(
                            Icons.search,
                            color: Color.fromARGB(255, 97, 97, 97),
                          ),
                        ),
                        isCollapsed: true,
                        border: searchFieldBorder,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        focusedBorder: searchFieldBorder,
                        enabledBorder: searchFieldBorder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !isItemsLoaded
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : (mainItems.isNotEmpty)
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            childAspectRatio: w / h,
                          ),
                          itemCount: mainItems.length,
                          itemBuilder: (context, index) => ItemStyle(
                            item: Item.map(mainItems.values.elementAt(index)),
                          ),
                        )
                      : const Center(
                          child: Text(
                            "Add items to be visible here",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      child: AddItemDialog(() => loadItems(null)),
                    );
                  },
                );
              },
            ),
          ),
        )
      ]),
    );
  }
}

extension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
}

enum PermissionGroup { locationAlways, locationWhenInUse }

void showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color.fromARGB(255, 54, 54, 54),
      timeInSecForIosWeb: 1,
      fontSize: 16.0);
}

void toastMsg(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color.fromARGB(255, 54, 54, 54),
      timeInSecForIosWeb: 1,
      fontSize: 16.0);
}

Future<GeoFirePoint?> getPosition() async {
  bool serviceStatus = await Geolocator.isLocationServiceEnabled();
  if (serviceStatus) {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      return GeoFlutterFire()
          .point(latitude: position.latitude, longitude: position.longitude);
    } else {
      toastMsg('Location permissions are denied');
      debugPrint('Location permissions are denied');
    }
  } else {
    toastMsg("loaction service is disabled");
    debugPrint("loaction service is disabled");
    return null;
  }
}

Future<String> getLocality() async {
  bool serviceStatus = await Geolocator.isLocationServiceEnabled();
  if (serviceStatus) {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.denied ||
        permission != LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      return placemarks.first.subLocality.toString();
    } else {
      toastMsg('Location permissions are denied');
      debugPrint('Location permissions are denied');
    }
  } else {
    toastMsg("loaction service is disabled");
    debugPrint("loaction service is disabled");
  }

  return "Enable";
}

Future<String> getCity() async {
  bool serviceStatus = await Geolocator.isLocationServiceEnabled();
  if (serviceStatus) {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.denied ||
        permission != LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      return placemarks.first.locality.toString();
    } else {
      toastMsg('Location permissions are denied');
      debugPrint('Location permissions are denied');
    }
  } else {
    toastMsg("loaction service is disabled");
    debugPrint("loaction service is disabled");
  }

  return "Location";
}

bool checkDist(GeoFirePoint myPosition, GeoPoint geo, double radius) {
  var distance = GeoFirePoint.distanceBetween(
      to: Coordinates(myPosition.latitude, myPosition.longitude),
      from: Coordinates(geo.latitude, geo.longitude));
  if (distance >= radius) {
    return false;
  }
  return true;
}
