import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaffeezaehler/model/data/Users.dart';
import 'package:kaffeezaehler/model/services/FirebaseHandler.dart';

class SelectionCard extends StatefulWidget {
  final String name;
  final Function onSubmitted;

  SelectionCard({
    Key key,
    this.name,
    this.onSubmitted,
  }) : super(key: key);
  @override
  _SelectionCardState createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard> {
  @override
  void initState() {
    super.initState();
  }

  final FirebaseHandler firebaseHandler = FirebaseHandler();

  int _coffeeCount = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  this.widget.name,
                  style: TextStyle(fontSize: 14),
                ),
                padding: EdgeInsets.only(bottom: 10),
              ),
              Container(
                padding: EdgeInsets.only(left: 6),
                alignment: Alignment.center,
                child: getImage(),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Transform.scale(
                        scale: 1.4,
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF004E98),
                          ),
                          onPressed: () {
                            onMinusPressed();
                          },
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "$_coffeeCount",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      child: Transform.scale(
                        scale: 1.4,
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF004E98),
                          ),
                          onPressed: () {
                            onPlusPressed();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: FlatButton(
                  color: Color(0xFF004E98),
                  child: Text(
                    "Bestätigen",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  onPressed: () {
                    onSubmitted();
                  },
                ),
              )
            ],
          ),
        ],
      )),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.15),
                spreadRadius: 2,
                blurRadius: 1,
                offset: Offset(0, 4)),
          ],
          borderRadius: BorderRadius.circular(12)),
    );
  }

  void onSubmitted() async {
    int baseClicks = 0;
    await firebaseHandler.readData(this.widget.name).then((value) {
      baseClicks = value['clicks'];
    });
    firebaseHandler.writeData(this.widget.name, <String, dynamic>{
      'clicks': baseClicks + _coffeeCount,
    });
    setState(() {
      _coffeeCount = 0;
    });
  }

  Widget getImage() {
    if (_coffeeCount <= 2) {
      return SvgPicture.asset(
        "icons/coffee-beans.svg",
        height: 50,
        width: 50,
      );
    } else if (_coffeeCount > 2 && _coffeeCount <= 5) {
      return SvgPicture.asset(
        "icons/coffee-mug.svg",
        height: 50,
        width: 50,
      );
    } else {
      return SvgPicture.asset(
        "icons/coffee-pot.svg",
        height: 50,
        width: 50,
      );
    }
  }

  void onPlusPressed() {
    setState(() {
      _coffeeCount++;
    });
  }

  void onMinusPressed() {
    if (_coffeeCount > 0) {
      setState(() {
        _coffeeCount--;
      });
    }
  }
}
