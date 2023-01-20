import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:grocery_picker/models/Store.dart';

import '../models/item.dart';

List<Map<String, dynamic>> groceryItems = [
  {
    "price": 240,
    "ratting": 4.2,
    "name": "apple",
    "prePrice": [240, 240, 236, 240, 236]
  },
  {
    "price": 40,
    "ratting": 4.3,
    "name": "bannana",
    "prePrice": [38, 37, 39, 43, 41]
  },
  {
    "price": 65,
    "ratting": 3.5,
    "name": "brinjal",
    "prePrice": [64, 69, 67, 69, 62]
  },
  {
    "price": 120,
    "ratting": 3.9,
    "name": "carrot",
    "prePrice": [121, 117, 124, 123, 118]
  },
  {
    "price": 60,
    "ratting": 4.6,
    "name": "cauliflower",
    "prePrice": [60, 62, 62, 55, 61]
  },
  {
    "price": 86,
    "ratting": 4.2,
    "name": "corn",
    "prePrice": [84, 82, 84, 88, 89]
  },
  {
    "price": 55,
    "ratting": 3.6,
    "name": "cucumber",
    "prePrice": [52, 55, 52, 59, 50]
  },
  {
    "price": 185,
    "ratting": 3.8,
    "name": "garlic",
    "prePrice": [184, 186, 183, 185, 185]
  },
  {
    "price": 48,
    "ratting": 4.6,
    "name": "ladies_finger",
    "prePrice": [45, 51, 46, 47, 45]
  },
  {
    "price": 18,
    "ratting": 4.2,
    "name": "watermelon",
    "prePrice": [22, 19, 22, 18, 21]
  }
];
// Future<void> uploadToFirebase() async {
//   var items = [
//     const Item(
//         name: "apple", prePrice: [10, 1, 11, 2, 2], price: 10.2, ratting: 4.2),
//     const Item(
//         name: "bannana",
//         prePrice: [60, 1, 11, 2, 2],
//         price: 12.2,
//         ratting: 3.2),
//     const Item(
//         name: "garlic", prePrice: [20, 1, 11, 2, 2], price: 43.2, ratting: 4.1),
//   ];
//   var store = Store(
//       name: "murugan",
//       items: items,
//       loaclity: "chennai",
//       latitude: 40.2,
//       longitude: 21.2,
//       address: "address");
//   await ref.child(store.name).set(store.toMap());
//   print("uploaded to firebase");
// }

var latRange = 0.0172;
var longRange = 0.0108;

var shopNames = [
  "Foodmoji",
  "Tasty Treats",
  "Farmer Jack’s Produce",
  "Authentic Grocery",
  "New Age Grocery",
  "Dear Grocery",
  "The Pick ‘n’ Mix",
  "Groceteria",
  "Basketcase Supermarket",
  "The Everyday Grocery",
  "Wonderworld of Groceries",
  "Naturally Gourmet Grocery",
  "Urban Organic Market",
  "Sparkling Foodie",
  "Groceries Are Us",
  "Berries & Blooms Grocery",
  "Fresh Pickens",
  "Agro Grocery",
];
List<Store> shopsList = [];
void custom() {
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  groceryItems.shuffle();
  shopNames.forEach((element) {
    shopsList.add(Store.fromMap({
      "name": element,
      "items": groceryItems.map((e) => Item.map(e)).toList()..shuffle(),
      "locality": "shollinganallur",
      "latitude": 12.8846 + genRandomNum(latRange),
      "longitude": 80.2249 + genRandomNum(longRange),
      "address": "shollinganallur"
    }));
  });

  print(
      "shops list : ///////////////////////////////////////////////////////////////////////");
  shopsList.forEach((element) {
    print(element.toMap());
    ref.child("stores").child(element.toMap()["name"]).set(element.toMap());
  });
}

double genRandomNum(double max) {
  return Random().nextDouble() * max;
}
