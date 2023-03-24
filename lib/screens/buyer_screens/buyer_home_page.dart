import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:grocery_picker/screens/settings_page.dart';
import 'package:grocery_picker/screens/buyer_screens/shop_page.dart';

import '../../models/shop.dart';
import '../../widgets/buyer/item_style_shop_view.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({Key? key}) : super(key: key);
  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference ref;
  late Reference storageRef;
  var firestore = FirebaseFirestore.instance;
  late String uid;
  double shopRadius = 3.0;

  late ScrollController scrollController;

  var yourLocality = "Enable";
  var yourCity = "Location";

  GeoFirePoint? myPosition;

  late double screenWidth;
  late double screenheight;

  Map<String, dynamic> mainItems = {};
  var isItemsLoaded = false;
  @override
  void initState() {
    ref = database.ref();
    storageRef = FirebaseStorage.instance.ref();
    uid = FirebaseAuth.instance.currentUser!.uid;

    // custom();
    getGeoLoaction();
    scrollController = ScrollController();
   
    // loadItems(null);
    super.initState();
  }

  void getGeoLoaction() async {
    // await FirebaseFirestore.instance
    //     .collection("stores")
    //     .doc(uid)
    //     .set({"hello": "asds"});
    var permissionResult = await Permission.location.request();
    if (permissionResult.isGranted) {
      var pos = await getPosition();
      if (pos == null) {
        toastMsg("Error getting location.  try again!");
        return;
      }
      var loc = await getLocality(pos.latitude, pos.longitude);
      var city = await getCity(pos.latitude, pos.longitude);
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
    debugPrint("on changed $searchText");
    isItemsLoaded = false;
    QuerySnapshot? snapShot;
    List<DocumentSnapshot<Object?>>? snapShot1;
    CollectionReference colRef;
    List<dynamic>? docs;
    if (searchText != null) {
      searchText = searchText.trim();
    }
    if (searchText == null || searchText.isEmpty) {
      colRef = firestore.collection("stores");
      shopRadius = 300;
      if (myPosition != null) {
        snapShot1 = await GeoFlutterFire()
            .collection(collectionRef: colRef)
            .within(center: myPosition!, radius: shopRadius, field: "location")
            .first;
      } else {
        snapShot = await colRef.get();
      }
    } else {
      searchText = searchText.toLowerCase();
      snapShot = await firestore
          .collection("stores")
          .where("searchCase", arrayContains: searchText)
          .limit(30)
          .get();
    }
    if (mounted) {
      setState(() {
        mainItems.clear();
      });
    }

    //updating from user cart
    Map<String, dynamic> cartItems;
    final cartSnapShot = await ref.child("users/$uid/cart").get();
    if (cartSnapShot.exists) {
      Map<String, dynamic> map =
          jsonDecode(jsonEncode(cartSnapShot.value)) as Map<String, dynamic>;
      cartItems = map;
    } else {
      cartItems = {};
    }

    // snapShot.docs.shuffle();
    if (snapShot != null) {
      docs = snapShot.docs;
      // docs.removeWhere(
      //     (element) => checkDist(element.data()["location"]["geopoint"]
      //, 10.0));
    } else if (snapShot1 != null) {
      docs = snapShot1;
      // docs.removeWhere((element) =>
      //     checkDist(myPosition!, element.data()["location"]["geopoint"], 3.0));
    }
    for (DocumentSnapshot i in docs!) {
      if (i.exists) {
        var data = i.data() as Map<String, dynamic>;
        var itemCol = await firestore
            .collection("stores")
            .doc(i.id)
            .collection("items")
            .get();
        var shopName = data["name"] as String;
        if (itemCol.size > 0) {
          var itemsMap = {};
          for (var item in itemCol.docs) {
            if (item.exists) {
              var data = item.data();
              itemsMap.addAll(data);
              // var shopName = data["name"] as String;
              // var map = {shopName: data};
            }
          }
          data["items"] = itemsMap;
          data["storeId"] = i.id;

          if (mounted) {
            setState(() {
              if (cartItems.containsKey(i.id)) {
                data["items"].addAll(cartItems[i.id]["items"]);
              }
              mainItems.addAll({shopName: data});
              if (mainItems.isNotEmpty) isItemsLoaded = true;
            });
          }
        }
      }
    }

    // Map<String, dynamic> items = mainItems;
    // for (var entry in cartItems.entries) {
    //   if (items.containsKey(entry.value["shopName"])) {
    //     items[entry.value["shopName"]]["items"].addAll(entry.value["items"]);
    //     print(entry.value["items"]);
    //   }
    // }

    // if (mounted) {
    //   setState(() {
    //     mainItems = items;
    //     isItemsLoaded = true;
    //   });
    // }
  }

  Future<String> getDownloadUrl(String imageName) async {
    storageRef = FirebaseStorage.instance.ref().child("items images");
    imageName = imageName.replaceAll(" ", "_");
    return storageRef.child("$imageName.jpg").getDownloadURL();
  }

  static const searchFieldBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(255, 245, 245, 245),
        width: 1.0,
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.all(Radius.circular(50)));
  @override
  Widget build(BuildContext context) {
    // setLocation();

    var topPadding = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height - topPadding;
    TextStyle loactionTextStyle(double size) => TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: size);
    return Container(
      margin: EdgeInsets.only(
        top: topPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.all(0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            color: Colors.green,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: getGeoLoaction,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Colors.white,
                            size: 25,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  yourLocality,
                                  style: loactionTextStyle(24),
                                ),
                                Text(
                                  yourCity,
                                  style: loactionTextStyle(20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: (() {
                        Navigator.of(context).pushNamed(SettingsPage.routeName);
                        // loadItems(null);
                        // showToast("");
                        // setLocation();
                      }),
                      child: Card(
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
                    ),
                  ),
                ],
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextField(
                  onTap: () {
                    // Navigator.of(context).pushNamed(SearchPage.routeName);
                  },
                  // readOnly: true,
                  maxLines: 1,
                  onChanged: loadItems,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: "search for shops",
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
            ]),
          ),
          Expanded(
            child: !isItemsLoaded
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    margin: const EdgeInsets.only(left: 5, right: 5),
                    child: (mainItems.isNotEmpty)
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount: mainItems.length,
                            itemBuilder: ((context, i) => shopWidget(
                                  Shop.fromMap(
                                    mainItems.values.elementAt(i),
                                  ),
                                )),
                          )
                        : Center(child: const Text("no results")),
                  ),
          ),
        ],
      ),
    );
  }

  Widget shopWidget(Shop shop) {
    // shop.items.shuffle();
    var w = screenWidth / 2.6;
    var maxItems = shop.items.length > 5 ? (5) : shop.items.length;
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

Future<String> getLocality(double latitude, double longitude) async {
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

Future<String> getCity(double latitude, double longitude) async {
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
