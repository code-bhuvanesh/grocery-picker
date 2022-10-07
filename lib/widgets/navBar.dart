import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NavBar extends StatefulWidget {
  NavBar(
      {Key? key,
      this.width,
      this.height,
      required this.items,
      this.color,
      this.itemColor,
      required this.onItemTap})
      : super(key: key);
  double? width = 350;
  double? height = 50.0;
  Color? itemColor;
  Color? color;
  Function onItemTap;
  final List<String> items;
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late double xAlign;

  double alignfactor(int f) {
    return f - 1;
  }

  @override
  void initState() {
    super.initState();
    xAlign = -1;
    widget.color ??= Colors.white;
    widget.itemColor ??= Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    double width = (widget.width != null) ? widget.width! : 350;
    double height = (widget.height != null) ? widget.height! : 50.0;
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        color: widget.color,
        margin: const EdgeInsets.all(0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: AnimatedAlign(
                  alignment: Alignment(xAlign, -1),
                  duration: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: width * (1 / widget.items.length) * 0.8,
                    height: 10,
                    child: Container(
                      alignment: Alignment.topCenter,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(84, 217, 217, 217),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ...widget.items
                  .asMap()
                  .map((pos, item) => MapEntry(pos,
                      navBarItem(pos, item, width * (1 / widget.items.length))))
                  .values
                  .toList()
            ],
          ),
        ),
      ),
    );
  }

  Widget navBarItem(int pos, String path, double width) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            xAlign = alignfactor(pos);
          });
          widget.onItemTap(pos);
        },
        child: Align(
          alignment: Alignment(alignfactor(pos), 0),
          child: Container(
            width: width,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              path,
              height: 20,
              width: 20,
              color: widget.itemColor,
            ),
          ),
        ),
      ),
    );
  }
}
