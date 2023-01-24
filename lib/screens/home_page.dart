import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_picker/screens/search_page.dart';
import 'package:grocery_picker/screens/settings_page.dart';
import 'package:grocery_picker/screens/shop_page.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/Store.dart';
import '../models/item.dart';
import '../utilities/upload_dummy_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference ref;
  late Reference storageRef;

  Map<String, dynamic> items = {};
  var isItemsLoaded = false;
  @override
  void initState() {
    ref = database.ref();
    storageRef = FirebaseStorage.instance.ref();
    // custom();
    getGeoLoaction();
    // loadItems(null);
    super.initState();
  }

  void loadItems(String? seachText) async {
    double storeRadius = 2.0;
    debugPrint("on changed $seachText");
    isItemsLoaded = false;
    late QuerySnapshot snapShot;
    late List<DocumentSnapshot<Object?>>? snapShot1 = null;
    if (seachText == null || seachText.isEmpty) {
      var collection = FirebaseFirestore.instance.collection("stores");
      snapShot = await collection.get();
      if (myPosition != null) {
        snapShot1 = await Geoflutterfire()
            .collection(collectionRef: collection)
            .within(center: myPosition!, radius: storeRadius, field: "location")
            .first;
        debugPrint("length : ${snapShot1.length}");
      }
    } else {
      seachText = seachText.toLowerCase();
      snapShot = await FirebaseFirestore.instance
          .collection("stores")
          .where("searchCase", arrayContains: seachText)
          .get();
    }
    setState(() {
      items.clear();
    });
    snapShot.docs.shuffle();
    List<dynamic> docs = snapShot.docs;
    if (snapShot1 != null) {
      docs = snapShot1;
      // debugPrint("my ${myPosition!.latitude},${myPosition!.longitude}");
      for (var i in docs) {
        if (i.exists) {
          // debugPrint("data");
          // debugPrint(i.data());
        }
      }
    }
    for (var i in docs) {
      if (i.exists) {
        var data = i.data() as dynamic;
        var shopName = data["name"] as String;
        var map = {shopName: data};
        var geo = data["location"]["geopoint"] as GeoPoint;
        // debugPrint(
        //     "distance ${(await Geolocator.distanceBetween(myPosition!.latitude, myPosition!.longitude, geo.latitude, geo.longitude) / 1000) * 0.621371}");
        var distance = GeoFirePoint.distanceBetween(
            to: Coordinates(myPosition!.latitude, myPosition!.longitude),
            from: Coordinates(geo.latitude, geo.longitude));
        if (distance > storeRadius) {
          continue;
        }
        debugPrint("$shopName : $distance");
        if (mounted) {
          setState(() {
            items.addAll(map);
          });
        }
      }
    }
    isItemsLoaded = true;
  }

  Future<String> getDownloadUrl(String imageName) async {
    storageRef = FirebaseStorage.instance.ref().child("items images");
    imageName = imageName.replaceAll(" ", "_");
    return storageRef.child("$imageName.jpg").getDownloadURL();
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

  var yourLocality = "Enable";
  var yourCity = "Location";

  GeoFirePoint? myPosition;

  Future<void> getGeoLoaction() async {
    bool serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (serviceStatus) {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.location,
        ].request();
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          toastMsg('Location permissions are denied');
          debugPrint('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          toastMsg("'Location permissions are permanently denied");
          debugPrint("'Location permissions are permanently denied");
        }
      }
      debugPrint("location permission : ${LocationPermission.denied}");
      if (permission != LocationPermission.denied) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (mounted) {
          loadItems(null);
          setState(() {
            // debugPrint(
            //     "${placemarks.first.subLocality}, ${placemarks.first.locality}");
            myPosition = Geoflutterfire().point(
                latitude: position.latitude, longitude: position.longitude);
            yourLocality = placemarks.first.subLocality.toString();
            yourCity = placemarks.first.locality.toString();
          });
        }
      }
    } else {
      toastMsg("loaction service is disabled");
      debugPrint("loaction service is disabled");
    }
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

  void addToCart(Store store, Item item) {
    var userRef = ref
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("cart")
        .child(store.name)
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

  late double screenWidth;
  late double screenheight;

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
              Container(
                child: Row(
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
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: (() {
                          Navigator.of(context)
                              .pushNamed(SettingsPage.routeName);
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
                    child: (items.isNotEmpty)
                        ? ListView.builder(
                            itemCount: items.length,
                            itemBuilder: ((context, i) => storeWidget(
                                  Store.fromMap(
                                    items.values.elementAt(i),
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

  Widget storeWidget(Store store) {
    // store.items.shuffle();
    return SizedBox(
      height: screenheight / 4,
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
                    store.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ShopPage.routeName, arguments: store);
                    },
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
              child: ListView(
            padding: EdgeInsets.only(top: 5),
            scrollDirection: Axis.horizontal,
            children: store.items.map((e) => itemStyle(store, e)).toList(),
          ))
        ],
      ),
    );
  }

  Widget itemStyle(Store store, Item item) {
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
                          onTap: (() => addToCart(store, item)),
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

enum PermissionGroup { locationAlways, locationWhenInUse }
