import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ItemCounter extends StatefulWidget {
  ItemCounter({
    Key? key,
    required this.itemCount,
    required this.itemName,
    required this.storeName,
  }) : super(key: key);

  int itemCount;
  final String itemName;
  final String storeName;

  @override
  State<ItemCounter> createState() => _ItemCounterState();
}

class _ItemCounterState extends State<ItemCounter> {
  static var UID = FirebaseAuth.instance.currentUser?.uid;
  var ref = FirebaseDatabase.instance.ref("users/$UID");
  void changeItemCount(String itemName, String storeName, int itemCount) {
    var userRef = ref.child("cart").child(storeName).child(itemName);

    userRef.get().then((value) {
      if (value.exists) {
        userRef.update({"count": itemCount});
      } else {
        userRef.update({"count": itemCount});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: Row(children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (widget.itemCount > 1) {
                widget.itemCount -= 1;
                changeItemCount(
                  widget.itemName,
                  widget.storeName,
                  widget.itemCount,
                );
              }
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 30,
            height: 30,
            child: const Card(
              color: Colors.green,
              child: Icon(
                Icons.remove,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Text(widget.itemCount.toString()),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.itemCount += 1;
              changeItemCount(
                widget.itemName,
                widget.storeName,
                widget.itemCount,
              );
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 30,
            height: 30,
            child: const Card(
              color: Colors.green,
              child: Icon(
                Icons.add,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
