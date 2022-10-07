class Item {
  final String name;
  final num price;
  final List<num> prePrice;
  final num ratting;
  const Item({
    required this.name,
    required this.price,
    required this.prePrice,
    required this.ratting,
  });

  Item.map(Map<String, dynamic> itemMap)
      : name = itemMap["name"],
        price = itemMap["price"],
        prePrice = [], // itemMap["prePrice"],
        ratting = 4.2; //itemMap["ratting"];

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "price": price,
      "prePrice": [],
      "ratting": ratting,
    };
  }
}
