import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  static const routeName = "/searchPage";
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    var topPadding = AppBar().preferredSize.height;
    const searchFieldBorder = OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 245, 245, 245),
          width: 1.0,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.all(Radius.circular(50)));
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: topPadding, left: 5, right: 5),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                autofocus: true,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    hintText: "search for shop name or item",
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 233, 233),
                    prefixIcon: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                    ),
                    isCollapsed: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: searchFieldBorder,
                    focusedBorder: searchFieldBorder,
                    enabledBorder: searchFieldBorder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
