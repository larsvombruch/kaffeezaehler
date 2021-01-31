import 'package:flutter/material.dart';
import 'package:kaffeekanne_web/model/services/FirebaseHandler.dart';

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
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
  }

  final FirebaseHandler firebaseHandler = FirebaseHandler();

  int _coffeeCount = 0;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.platformBrightnessOf(context) == Brightness.dark) {
      darkMode = true;
    }
    return Container(
      height: 150,
      width: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(
              this.widget.name,
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            padding: EdgeInsets.only(bottom: 15, top: 20),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 10),
              alignment: Alignment.center,
              child: Image.asset("assets/images/coffee-mug.png"),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Transform.scale(
                      scale: 1.2,
                      child: IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
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
                      style: TextStyle(
                          fontSize: 16,
                          color: darkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  Container(
                    child: Transform.scale(
                      scale: 1.2,
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
          ),
          Expanded(
            child: Container(
              width: 130,
              padding: EdgeInsets.only(bottom: 20),
              // ignore: deprecated_member_use
              child: FlatButton(
                color: Color(0xFF004E98),
                child: Text(
                  "Bestätigen",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                onPressed: () async {
                  await onSubmitted();
                  this.widget.onSubmitted();
                },
              ),
            ),
          )
        ],
      ),
      decoration: BoxDecoration(
          color: darkMode ? Color(0xFF0a0a0a) : Colors.white,
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

  Future onSubmitted() async {
    if (_coffeeCount != 0) {
      int baseClicks = 0;
      await firebaseHandler.readData(document: this.widget.name).then((value) {
        baseClicks = value['clicks'];
      });
      await firebaseHandler.writeData(
          collection: "userdata",
          document: this.widget.name,
          data: <String, dynamic>{
            'clicks': baseClicks + _coffeeCount,
          });
      setState(() {
        _coffeeCount = 0;
      });
      return true;
    } else {
      return false;
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
