import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/item.dart';
import '../../widgets/buyer/item_style_orders.dart';

class SellersOrdersPage extends StatefulWidget {
  const SellersOrdersPage({super.key});
  static String routeName = "/sellersOrderPage";

  @override
  State<SellersOrdersPage> createState() => _SellersOrdersPageState();
}

class _SellersOrdersPageState extends State<SellersOrdersPage> {
  var ordersList = {};

  Future<void> getOrdersList() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var ref = FirebaseDatabase.instance.ref("storeUsers/$uid");
    var snapshot = await ref.get();
    if (snapshot.exists) {
      var data = snapshot.value as Map<String, dynamic>;
      data.forEach((buyerId, orders) {
        ordersList.addAll(orders);
      });
    }
  }

  static var uid = FirebaseAuth.instance.currentUser?.uid;
  var ref = FirebaseDatabase.instance.ref("storeUsers/$uid");
  late double screenWidth;
  late double screenheight;
  Map<String, dynamic> orders = {};

  bool isOrderItemsEmpty = false;
  Future<void> getOrders() async {
    final snapShot = await ref.get();
    if (snapShot.exists) {
      Map<String, dynamic> map =
          jsonDecode(jsonEncode(snapShot.value)) as Map<String, dynamic>;
      Map<String, dynamic> data = {};
      map.forEach((key, value) {
        (value as Map<String, dynamic>).forEach((key1, value1) {
          value1["custId"] = key;
        });
        data.addAll(value);
        print(value);
      });

      if (mounted) {
        setState(() {
          orders = data;
          print(orders);
          isOrderItemsEmpty = orders.isEmpty;
        });
      }
    }
    if (mounted) {
      setState(() {
        isOrderItemsEmpty = orders.isEmpty;
      });
    }
  }

  void updateOrderItems() {
    ref.onChildChanged.listen((event) {
      if (mounted) {
        setState(() {
          getOrders();
        });
      }
    });
    ref.onChildAdded.listen((event) {
      if (mounted) {
        setState(() {
          getOrders();
        });
      }
    });
  }

  @override
  void initState() {
    // getOrders();
    updateOrderItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height - topPadding;
    var appBarPadding = AppBar().preferredSize.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.only(top: topPadding),
        child: Column(
          children: [
            Expanded(
              child: orders.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      shrinkWrap: true,
                      itemCount: orders.length,
                      itemBuilder: (context, i) => OrderWidget(
                        order: orders.values.elementAt(i),
                      ),
                    )
                  : Center(
                      child: isOrderItemsEmpty
                          ? const Text("no orders yet")
                          : const CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key, required this.order});
  final Map<String, dynamic> order;
  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  var show = false;
  var orderedStore = {};
  @override
  void initState() {
    orderedStore = {"items": widget.order["items"]};

    super.initState();
  }

  Future<String> getUserName(String uid) async {
    var ref = FirebaseDatabase.instance.ref("users/$uid/details/username");
    var usernameSnapshot = await ref.get();
    var userName = "username";
    if (usernameSnapshot.exists) {
      userName = usernameSnapshot.value as String;
    }
    return userName;
  }

  @override
  Widget build(BuildContext context) {
    var orderedTime = DateTime.parse(widget.order["orderedTime"]);
    return orderWidget(widget.order["items"], widget.order["custId"]);
  }

  num getTotalItemPrice(Map<String, dynamic> shop) {
    num total = 0;
    if (shop.isNotEmpty) {
      shop.forEach((key, value) {
        total += (value["price"] as num) * (value["count"] as num);
      });
    }
    return total;
  }

  Widget orderWidget(Map<String, dynamic> items, String custId) {
    return Container(
      margin: const EdgeInsets.all(3),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 5, bottom: 5, left: 5, right: 10),
                  child: FutureBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text(
                          snapshot.data,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                    future: getUserName(custId),
                  ),
                ),
              ),
              ...items.values
                  .map((e) => ItemStyleOrders(
                        item: Item.map(e),
                        shopName: "getUserName(uid)",
                      ))
                  .toList(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Total : ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  Center(
                    child: Text(
                      "₹${getTotalItemPrice(items)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CustomButton(
                      "Deleiverd",
                      Colors.green,
                      () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded CustomButton(
    String text,
    MaterialColor color,
    void Function() onClick,
  ) {
    return Expanded(
      child: Container(
        height: 50,
        child: Card(
          color: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Center(
              child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          )),
        ),
      ),
    );
  }
}
