import 'package:firebase_database/firebase_database.dart';

import '../screens/buyer_screens/buyer_home_page.dart';

class Item {
  final String name;
  final num price;
  final List<num> prePrice;
  final num ratting;
  // final String imageLink;
  late int count;
  Item({
    // required this.imageLink,
    required this.name,
    required this.price,
    required this.prePrice,
    required this.ratting,
  });

  Item.map(Map<String, dynamic> itemMap)
      : name = itemMap["name"],
        price = itemMap["price"],
        prePrice = [], // itemMap["prePrice"],
        ratting = itemMap["ratting"] as num,
        // imageLink = itemMap["imageLink"],
        count = (itemMap["count"] != null) ? (itemMap["count"] as int) : 0;

  Future<void> addToCart(
    DatabaseReference ref,
    String uid,
    String shopId,
    String shopName,
  ) async {
    count = 1;
    var userRef = ref.child("users").child(uid).child("cart").child(shopId);
    await userRef.child("shopName").set(shopName);
    userRef = userRef.child("items").child(name);

    userRef.child("count").get().then((value) {
      if (value.exists) {
        var itemCount = value.value as int;
        userRef.update({"count": (itemCount + 1)});
      } else {
        userRef.set(
          toMapC(),
        );
      }
    });
    showToast("item added to cart");
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "price": price,
      "prePrice": prePrice,
      "ratting": ratting,
    };
  }

  Map<String, dynamic> toMapC() {
    return {
      "name": name,
      "price": price,
      "prePrice": prePrice,
      "ratting": ratting,
      "count": count,
    };
  }
}
