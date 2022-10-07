import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_picker/screens/searchPage.dart';
import 'package:grocery_picker/screens/settingsPage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/Store.dart';
import '../models/item.dart';
import '../utilities/uploadDummyData.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference ref;
  Map<String, dynamic> items = {};
  @override
  void initState() {
    ref = database.ref();
    storageRef = FirebaseStorage.instance.ref();
    // custom();
    loadItems();
    getGeoLoaction();
    super.initState();
  }

  Future<void> loadItems() async {
    final snapShot = await ref.child("stores").get();
    if (snapShot.exists) {
      Map<String, dynamic> map =
          jsonDecode(jsonEncode(snapShot.value)) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          items = map;
        });
      }
    }
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

  var yourLocality = "";
  var yourCity = "";

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
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          toastMsg("'Location permissions are permanently denied");
          print("'Location permissions are permanently denied");
        }
      }
      print("location permission : ${LocationPermission.denied}");
      if (permission != LocationPermission.denied) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (mounted) {
          setState(() {
            // print(
            //     "${placemarks.first.subLocality}, ${placemarks.first.locality}");
            yourLocality = placemarks.first.subLocality.toString();
            yourCity = placemarks.first.locality.toString();
          });
        }
      }
    } else {
      toastMsg("loaction service is disabled");
      print("loaction service is disabled");
    }
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
          item.toMap(),
        );
        userRef.update({"count": 1});
      }
    });
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
                    Container(
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
                    Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: (() => Navigator.of(context)
                            .pushNamed(SettingsPage.routeName)),
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
                    Navigator.of(context).pushNamed(SearchPage.routeName);
                  },
                  readOnly: true,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: "search for shop name or item",
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
            child: Container(
                margin: const EdgeInsets.only(left: 5, right: 5),
                child: ListView(
                    children: items.entries
                        .map((e) => storeWidget(
                            Store.fromMap(e.value as Map<String, dynamic>)))
                        .toList())),
          ),
        ],
      ),
    );
  }

  Widget storeWidget(Store store) => SizedBox(
        height: screenheight / 4,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.all(5),
                child: Text(
                  store.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
                child: ListView(
              scrollDirection: Axis.horizontal,
              children: store.items.map((e) => itemStyle(store, e)).toList(),
            ))
          ],
        ),
      );

  Widget itemStyle(Store store, Item item) {
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
              FutureBuilder(
                future: getDownloadUrl(item.name),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return SizedBox(
                      height: 60,
                      child: Center(
                        child: Image.network(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox(
                        height: 60,
                        width: 60,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ));
                  }
                },
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

  late Reference storageRef;
  Future<String> getDownloadUrl(String imageName) async {
    storageRef = FirebaseStorage.instance.ref().child("items images");
    imageName = imageName.replaceAll(" ", "_");
    return storageRef.child("$imageName.jpg").getDownloadURL();
  }
}

extension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
}

enum PermissionGroup { locationAlways, locationWhenInUse }
