import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_picker/widgets/item_style_orders.dart';
import 'package:intl/intl.dart';

import '../models/item.dart';
import '../widgets/item_style_cart.dart';

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
    return GestureDetector(
      onTap: () {
        setState(() {
          show = !show;
        });
      },
      child: Card(
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat("y MMMM d , hh:mm:a").format(orderedTime)),
                  Icon(show ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                ],
              ),
              AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Column(children: [
                  ...(show
                      ? orderedStore.entries
                          .map((e) => storeWidget({e.key: e.value}))
                          .toList()
                      : [const SizedBox.shrink()])
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  num getTotalItemPrice(Map<String, dynamic> stores) {
    num total = 0;
    if (stores.isNotEmpty) {
      stores.forEach((key, value) {
        (value as Map<String, dynamic>).forEach((key1, value1) {
          print("price");
          print(value1);
          total += (value1["price"] as num) * (value1["count"] as num);
        });
      });
    }
    return total;
  }

  Widget storeWidget(Map<String, dynamic> store) {
    return Container(
      margin: const EdgeInsets.all(3),
      child: Card(
        elevation: 10,
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
                    store.keys.first,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              ...(store.values.first as Map<String, dynamic>)
                  .values
                  .map((e) => ItemStyleOrders(
                        item: Item.map(e),
                        storeName: store.keys.first,
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
                      "₹${getTotalItemPrice(store)}",
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
