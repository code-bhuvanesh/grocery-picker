import 'item.dart';

class Shop {
  final String name;
  final List<Item> items;
  final String locality;
  final dynamic location;
  final String address;
  final String shopId;
  const Shop({
    required this.name,
    required this.items,
    required this.locality,
    required this.location,
    required this.address,
    required this.shopId,
  });

  toMap() {
    return {
      "name": name,
      "items": {for (var v in items) v.name: v.toMap()},
      "lolity": locality,
      "location": location,
      "address": address,
      "storeId": shopId
    };
  }

  Shop.fromMap(Map<String, dynamic> shopMap)
      : name = shopMap["name"],
        // items = (shopMap["items"] as List<Item>),

        items = (Map<String, dynamic>.from(shopMap["items"])).entries.map((e) {
          print(" ");
          print(shopMap);
          return Item.map(e.value as Map<String, dynamic>);
        }).toList(),
        locality = shopMap["locality"],
        location = shopMap["location"],
        address = shopMap["address"],
        shopId = shopMap["storeId"];
}
