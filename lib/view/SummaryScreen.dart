import 'package:flutter/material.dart';
import 'package:kaffeekanne_web/model/data/Users.dart';
import 'package:kaffeekanne_web/model/services/FirebaseHandler.dart';

import 'HomeScreen.dart';
import 'SettingsScreen.dart';

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<Users> users = [];
  FirebaseHandler firebaseHandler = FirebaseHandler();

  bool darkMode = false;

  int month = 0;

  List<String> collectionList = [
    "userdata",
    "bfthis",
    "bfbfthis",
    "bfbfbfthis",
    "bfbfbfbfthis",
  ];

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    List tmp = [];
    await firebaseHandler.readData(collection: "userdata").then((value) {
      tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) async {
        if (element['clicks'] - element['paidAt'] >= 50) {
          await firebaseHandler.writeData(
              collection: "userdata",
              document: element['name'],
              data: <String, dynamic>{
                'paymentRequired': true,
              });
        } else {
          await firebaseHandler.writeData(
              collection: "userdata",
              document: element['name'],
              data: <String, dynamic>{
                'paymentRequired': false,
              });
        }
        setState(() {
          users.add(Users(
            name: element['name'],
            clicks: element['clicks'],
            paymentRequired: element['paymentRequired'],
            paidAt: element['paidAt'],
          ));
        });
      });
    });
  }

  Future handleMonthChange() async {
    await firebaseHandler
        .readData(collection: collectionList[month])
        .then((value) {
      List tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) {
        if ((element['clicks'] - element['paidAt']) > 50) {
          firebaseHandler.writeData(
              collection: collectionList[month],
              document: element['name'],
              data: {
                'paymentRequired': true,
              });
        } else {
          firebaseHandler.writeData(
              collection: collectionList[month],
              document: element['name'],
              data: {
                'paymentRequired': false,
              });
        }
      });
    });
    await firebaseHandler
        .readData(collection: collectionList[month])
        .then((value) {
      List tmp = value.docs.map((doc) => doc.data()).toList();
      users = [];
      tmp.forEach((element) {
        setState(() {
          users.add(
            Users(
              name: element['name'],
              clicks: element['clicks'],
              paidAt: element['paidAt'],
              paymentRequired: element['paymentRequired'],
            ),
          );
        });
      });
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.platformBrightnessOf(context) == Brightness.dark) {
      darkMode = true;
    }
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        child: Scaffold(
          backgroundColor: darkMode ? Color(0xFF363333) : Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ));
                  }),
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ));
                  }),
            ],
            title: Text(
              "Dometic Kaffeezähler",
              style: TextStyle(color: Colors.white),
            ),
            toolbarHeight: 50,
            elevation: 0,
            backgroundColor: Color(0xFF004E98),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                width: size.width,
                height: 150,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "Zusammenfassung",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            color: darkMode ? Colors.white : Colors.black),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: monthList(),
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: darkMode ? Color(0xFF0a0a0a) : Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        offset: Offset(0, 2),
                        blurRadius: 2,
                        spreadRadius: 3),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: summaryList(),
                ),
              )
            ],
          ),
        ),
        onWillPop: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            )));
  }

  List<Widget> monthList() {
    List<Widget> tmp = [];
    List monthText = [
      "",
      "Vor einem Monat",
      "Vor zwei Monaten",
      "Vor drei Monaten",
    ];
    if (month == 0) {
      tmp.add(IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: darkMode ? Colors.white : Colors.black,
        ),
        onPressed: () async {
          setState(() {
            month += 1;
          });
          await handleMonthChange();
        },
      ));
      tmp.add(
        Container(
          child: Text(
            "Dieser Monat",
            style: TextStyle(color: darkMode ? Colors.white : Colors.black),
          ),
        ),
      );
      tmp.add(IconButton(
        icon: Icon(
          Icons.chevron_right,
          color: Colors.transparent,
        ),
        onPressed: () {},
      ));
    } else if (month > 0 && month < 4) {
      tmp.add(IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: darkMode ? Colors.white : Colors.black,
        ),
        onPressed: () async {
          setState(() {
            month += 1;
          });
          await handleMonthChange();
        },
      ));
      tmp.add(
        Container(
          child: Text(
            monthText[month],
            style: TextStyle(color: darkMode ? Colors.white : Colors.black),
          ),
        ),
      );
      tmp.add(
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: darkMode ? Colors.white : Colors.black,
          ),
          onPressed: () async {
            setState(() {
              month -= 1;
            });
            await handleMonthChange();
          },
        ),
      );
    } else if (month == 4) {
      tmp.add(IconButton(
        icon: Icon(
          Icons.chevron_left,
          color: Colors.transparent,
        ),
        onPressed: () {},
      ));
      tmp.add(
        Container(
          child: Text(
            "Vor vier Monaten",
            style: TextStyle(color: darkMode ? Colors.white : Colors.black),
          ),
        ),
      );
      tmp.add(IconButton(
        icon: Icon(
          Icons.chevron_right,
          color: darkMode ? Colors.white : Colors.black,
        ),
        onPressed: () async {
          setState(() {
            month -= 1;
          });
          await handleMonthChange();
        },
      ));
    }
    return tmp;
  }

  ListView summaryList() {
    String tmp = "";
    TextStyle textStyle =
        TextStyle(fontSize: 18, color: darkMode ? Colors.white : Colors.black);
    List<Users> tmpUsers = [];
    tmpUsers = users;
    tmpUsers.sort((a, b) => b.clicks.compareTo(a.clicks));

    return ListView.builder(
      itemCount: tmpUsers.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (tmpUsers[index].paidAt == 0) {
          tmp = "${tmpUsers[index].clicks}";
        } else {
          if (tmpUsers[index].clicks == 0) {
            tmp = "(${tmpUsers[index].paidAt}) ${0}";
          } else
            tmp =
                "(${tmpUsers[index].paidAt}) ${tmpUsers[index].clicks - tmpUsers[index].paidAt}";
        }
        return Container(
          padding: EdgeInsets.only(top: 10),
          child: ListTile(
            leading: Text(
              "${index + 1}.",
              style: textStyle,
            ),
            title: Text(
              "${tmpUsers[index].name}",
              style: textStyle,
            ),
            trailing: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$tmp",
                    style: textStyle,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 5, left: 10, right: 10),
                    child: Image.asset(
                      "assets/images/coffee-mug.png",
                      height: 28,
                      width: 28,
                    ),
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.euro,
                        color: tmpUsers[index].paymentRequired
                            ? Colors.red
                            : Colors.green,
                      ),
                      onPressed: () async {
                        await firebaseHandler.writeData(
                            collection: collectionList[month],
                            document: tmpUsers[index].name,
                            data: <String, dynamic>{
                              'paymentRequired': false,
                              'paidAt': tmpUsers[index].clicks,
                            });
                        setState(() {
                          users = [];
                        });
                        await firebaseHandler
                            .readData(collection: collectionList[month])
                            .then((value) {
                          List tmp =
                              value.docs.map((doc) => doc.data()).toList();
                          tmp.forEach((element) {
                            setState(() {
                              users.add(Users(
                                name: element['name'],
                                clicks: element['clicks'],
                                paymentRequired: element['paymentRequired'],
                                paidAt: element['paidAt'],
                              ));
                            });
                          });
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
