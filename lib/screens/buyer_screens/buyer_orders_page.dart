import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_picker/widgets/buyer/item_style_orders.dart';
import 'package:intl/intl.dart';

import '../../../models/item.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static var UID = FirebaseAuth.instance.currentUser?.uid;
  var ref = FirebaseDatabase.instance.ref("users/$UID");
  late double screenWidth;
  late double screenheight;
  Map<String, dynamic> orders = {};
  bool isCartItemsEmpty = false;
  Future<void> getOrders() async {
    final snapShot = await ref.child("orders").get();
    if (snapShot.exists) {
      Map<String, dynamic> map =
          jsonDecode(jsonEncode(snapShot.value)) as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          orders = map;
          print(orders);
          isCartItemsEmpty = orders.isEmpty;
        });
      }
    }
    if (mounted) {
      setState(() {
        isCartItemsEmpty = orders.isEmpty;
      });
    }
  }

  void updateCartItems() {
    ref.child("orders").onChildChanged.listen((event) {
      if (mounted) {
        setState(() {
          getOrders();
        });
      }
    });
  }

  @override
  void initState() {
    getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height - topPadding;
    var appBarPadding = AppBar().preferredSize.height;
    return Container(
      margin: EdgeInsets.only(top: topPadding),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: appBarPadding,
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/orders-icon.svg",
                        height: 20,
                        width: 20,
                        color: Colors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text("Your Orders",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                    child: isCartItemsEmpty
                        ? const Text("no orders yet")
                        : const CircularProgressIndicator(),
                  ),
          ),
        ],
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
    orderedStore = widget.order["items"];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var orderedTime = DateTime.parse(widget.order["orderedTime"]);
    return Card(
      shadowColor: Colors.black38,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: ExpandablePanel(
          header: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(DateFormat("y MMMM d , hh:mm:a").format(orderedTime)),
          ),
          expanded: Column(
            children: [
              ...(orderedStore.entries.map((e) => shopWidget(e.value)).toList())
            ],
          ),
          collapsed: const SizedBox.shrink(),
        ),
      ),
    );
  }

  num getTotalItemPrice(Map<String, dynamic> shop) {
    num total = 0;
    if (shop.isNotEmpty) {
      shop["items"].forEach((key, value) {
        total += (value["price"] as num) * (value["count"] as num);
      });
    }
    return total;
  }

  Widget shopWidget(Map<String, dynamic> shop) {
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
                  child: Text(
                    shop["shopName"],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              ...(shop["items"])
                  .values
                  .map((e) => ItemStyleOrders(
                        item: Item.map(e),
                        shopName: shop.keys.first,
                      ))
                  .toList(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Total : ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26,),
                  ),
                  Center(
                    child: Text(
                      "₹${getTotalItemPrice(shop)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22,),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
