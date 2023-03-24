import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_picker/screens/seller_screens/seller_main_page.dart';
import 'package:grocery_picker/widgets/custom_button.dart';

import '../buyer_screens/buyer_home_page.dart';

class SetupPage extends StatefulWidget {
  SetupPage({super.key});
  static const routeName = "/setupPage";

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  var firestore = FirebaseFirestore.instance;

  TextEditingController shopNameController = TextEditingController();

  List<String> createSearchCase(String name) {
    List<String> output = [];
    for (int i = 0; i < name.length; i++) {
      output.add(name.substring(0, i));
    }
    return output;
  }

  var uploading = false;

  void onSumbit(BuildContext context) async {
    setState(() {
      uploading = true;
    });
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var database = FirebaseDatabase.instance;
    var ref = database.ref("users/$uid/details/shopName");

    ref.set(shopNameController.text);

    var firestore = FirebaseFirestore.instance;
    // if(geopoint == null && locality == null) return;
    var curpos = await getPosition();
    var locality = await getLocality(curpos!.latitude, curpos.longitude);
    var address = await getCity(curpos.latitude, curpos.longitude);
    await firestore.collection("stores").doc(uid).set({
      "location": {"geohash": curpos.hash, "geopoint": curpos.geoPoint},
      // "location": curpos,
      "address": address,
      "locality": locality,
      "name": shopNameController.text.trim(),
      "rating": 5,
      "searchCase": createSearchCase(shopNameController.text),
    }, SetOptions(merge: true)).onError((error, stackTrace) async {
      var e = await error;
      print("${e} ,  error ...............................................");
    });

    // print(result)

    if (mounted) {
      setState(() {
        uploading = false;
      });
      Navigator.of(context).popAndPushNamed(SellerMainPage.routeName);
    }
  }

  Future<String?> getLocality(double latitude, double longitude) async {
    bool serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (serviceStatus) {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission != LocationPermission.denied ||
          permission != LocationPermission.whileInUse) {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);

        return placemarks.first.subLocality.toString();
      } else {
        toastMsg('Location permissions are denied');
        debugPrint('Location permissions are denied');
      }
    } else {
      toastMsg("loaction service is disabled");
      debugPrint("loaction service is disabled");
    }
  }

  GeoFirePoint? geopoint;
  Future<GeoFirePoint?> getPosition() async {
    bool serviceStatus = await Geolocator.isLocationServiceEnabled();
    if (serviceStatus) {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);

        return GeoFirePoint(position.latitude, position.longitude);
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tfBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Colors.green,
        width: 1.0,
      ),
    );
    return Scaffold(
      body: Stack(children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                width: double.infinity,
                child: const FittedBox(
                  child: Text(
                    "What's your shop name?",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: TextField(
                  controller: shopNameController,
                  decoration: InputDecoration(
                    labelText: "shop Name",
                    hintText: "eg: Agro grocery",
                    border: tfBorder,
                    enabledBorder: tfBorder,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: CustomButton(
                  btnText: "Submit",
                  onClick: () => onSumbit(context),
                ),
              )
            ],
          ),
        ),
        uploading
            ? Container(
                color: Color.fromARGB(150, 255, 255, 255),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox.shrink()
      ]),
    );
  }
}
