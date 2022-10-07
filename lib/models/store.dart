import 'dart:ffi';

import 'package:geocoding/geocoding.dart';

import 'item.dart';

class Store {
  final String name;
  final List<Item> items;
  final String locality;
  final double latitude;
  final double longitude;
  final String address;
  const Store({
    required this.name,
    required this.items,
    required this.locality,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  toMap() {
    return {
      "name": name,
      "items": {for (var v in items) v.name: v.toMap()},
      "lolity": locality,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,
    };
  }

  Store.fromMap(Map<String, dynamic> storeMap)
      : name = storeMap["name"],
        // items = (storeMap["items"] as List<Item>),
        items = (storeMap["items"] as Map<String, dynamic>)
            .entries
            .map((e) => Item.map(e.value as Map<String, dynamic>))
            .toList(),
        locality = storeMap["locality"],
        latitude = storeMap["latitude"],
        longitude = storeMap["longitude"],
        address = storeMap["address"];
}
