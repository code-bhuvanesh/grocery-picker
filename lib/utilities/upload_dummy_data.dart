import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

// List<Map<String, dynamic>> groceryItems = [
//   {
//     "price": 240,
//     "ratting": 4.2,
//     "name": "apple",
//     "prePrice": [240, 240, 236, 240, 236]
//   },
//   {
//     "price": 40,
//     "ratting": 4.3,
//     "name": "bannana",
//     "prePrice": [38, 37, 39, 43, 41]
//   },
//   {
//     "price": 65,
//     "ratting": 3.5,
//     "name": "brinjal",
//     "prePrice": [64, 69, 67, 69, 62]
//   },
//   {
//     "price": 120,
//     "ratting": 3.9,
//     "name": "carrot",
//     "prePrice": [121, 117, 124, 123, 118]
//   },
//   {
//     "price": 60,
//     "ratting": 4.6,
//     "name": "cauliflower",
//     "prePrice": [60, 62, 62, 55, 61]
//   },
//   {
//     "price": 86,
//     "ratting": 4.2,
//     "name": "corn",
//     "prePrice": [84, 82, 84, 88, 89]
//   },
//   {
//     "price": 55,
//     "ratting": 3.6,
//     "name": "cucumber",
//     "prePrice": [52, 55, 52, 59, 50]
//   },
//   {
//     "price": 185,
//     "ratting": 3.8,
//     "name": "garlic",
//     "prePrice": [184, 186, 183, 185, 185]
//   },
//   {
//     "price": 48,
//     "ratting": 4.6,
//     "name": "ladies_finger",
//     "prePrice": [45, 51, 46, 47, 45]
//   },
//   {
//     "price": 18,
//     "ratting": 4.2,
//     "name": "watermelon",
//     "prePrice": [22, 19, 22, 18, 21]
//   }
// ];
// // Future<void> uploadToFirebase() async {
// //   var items = [
// //     const Item(
// //         name: "apple", prePrice: [10, 1, 11, 2, 2], price: 10.2, ratting: 4.2),
// //     const Item(
// //         name: "bannana",
// //         prePrice: [60, 1, 11, 2, 2],
// //         price: 12.2,
// //         ratting: 3.2),
// //     const Item(
// //         name: "garlic", prePrice: [20, 1, 11, 2, 2], price: 43.2, ratting: 4.1),
// //   ];
// //   var shop = Shop(
// //       name: "murugan",
// //       items: items,
// //       loaclity: "chennai",
// //       latitude: 40.2,
// //       longitude: 21.2,
// //       address: "address");
// //   await ref.child(store.name).set(store.toMap());
// //   debugPrint("uploaded to firebase");
// // }

// var latRange = 0.0172;
// var longRange = 0.0108;

// var shopNames = [
//   "Foodmoji",
//   "Tasty Treats",
//   "Farmer Jack’s Produce",
//   "Authentic Grocery",
//   "New Age Grocery",
//   "Dear Grocery",
//   "The Pick ‘n’ Mix",
//   "Groceteria",
//   "Basketcase Supermarket",
//   "The Everyday Grocery",
//   "Wonderworld of Groceries",
//   "Naturally Gourmet Grocery",
//   "Urban Organic Market",
//   "Sparkling Foodie",
//   "Groceries Are Us",
//   "Berries & Blooms Grocery",
//   "Fresh Pickens",
//   "Agro Grocery",
// ];
// List<Store> shopsList = [];
// void custom() {
//   DatabaseReference ref = FirebaseDatabase.instance.ref();

//   groceryItems.shuffle();
//   shopNames.forEach((element) {
//     shopsList.add(Store.fromMap({
//       "name": element,
//       "items": groceryItems.map((e) => Item.map(e)).toList()..shuffle(),
//       "locality": "shollinganallur",
//       "latitude": 12.8846 + genRandomNum(latRange),
//       "longitude": 80.2249 + genRandomNum(longRange),
//       "address": "shollinganallur"
//     }));
//   });

//   debugPrint(
//       "shops list : ///////////////////////////////////////////////////////////////////////");
//   shopsList.forEach((element) {
//     debugPrint(element.toMap());
//     ref.child("stores").child(element.toMap()["name"]).set(element.toMap());
//   });
// }

// double genRandomNum(double max) {
//   return Random().nextDouble() * max;
// }

final geo = GeoFlutterFire();
//12.9055917,80.2303483
Future<void> setLocation() async {
  var already1 = [];
  var already2 = [];
  var shops =
      FirebaseFirestore.instance.collection("stores").get().then((snapshot) {
    for (var ds in snapshot.docs) {
      if (ds.exists) {
        var data = ds.data();

        var r1 = 0.0;
        var r2 = 0.0;

        while (r1 == 0.0 && !already1.contains(r1)) {
          r1 = randomNum();
        }
        while (r2 == 0.0 && !already2.contains(r2)) {
          r2 = randomNum();
        }

        already1.add(r1);
        already2.add(r2);

        var lat = 12.9055917 + r1;
        var long = 80.2303483 + r2;
        var location = geo.point(latitude: lat, longitude: long);
        data.addAll({"location": location.data});
        // data.remove("latitude");
        // data.remove("longitude");
        ds.reference.set(data);
      }
    }
  });
}

double randomNum() {
  var min = -2;
  var max = 2;
  return (min + Random().nextInt(max - min)) / 100;
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
