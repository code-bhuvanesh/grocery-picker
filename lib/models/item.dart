class Item {
  final String name;
  final num price;
  final List<num> prePrice;
  final num ratting;
  late int count;
  Item({
    this.count = 1,
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
        count = (itemMap["count"] != null) ? (itemMap["count"] as int) : 1;

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
