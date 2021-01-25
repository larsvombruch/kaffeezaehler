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

  bool lastMonth = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    List tmp = [];
    await firebaseHandler.readData().then((value) {
      tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) {
        setState(() {
          users.add(Users(
            name: element['name'],
            clicks: element['clicks'],
            record: element['record'],
          ));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      darkMode = true;
    }
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        child: Scaffold(
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
            title: Text("Dometic Kaffeezähler"),
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
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !lastMonth
                              ? IconButton(
                                  icon: Icon(Icons.chevron_left),
                                  onPressed: () {
                                    setState(() {
                                      lastMonth = true;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.chevron_right,
                                    color: Colors.transparent,
                                  ),
                                  onPressed: () {},
                                ),
                          Container(
                            child: Text(
                                !lastMonth ? "Dieser Monat" : "Letzter Monat"),
                          ),
                          lastMonth
                              ? IconButton(
                                  icon: Icon(
                                    Icons.chevron_right,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      lastMonth = false;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.chevron_right,
                                    color: Colors.transparent,
                                  ),
                                  onPressed: () {},
                                )
                        ],
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: darkMode ? Colors.transparent : Colors.white,
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

  ListView summaryList() {
    TextStyle textStyle = TextStyle(fontSize: 18);
    List<Users> tmpUsers;
    setState(() {
      tmpUsers = users;
    });
    if (lastMonth) {
      tmpUsers.sort((a, b) => b.record.compareTo(a.record));
    } else {
      tmpUsers.sort((a, b) => b.clicks.compareTo(a.clicks));
    }

    return ListView.builder(
      itemCount: tmpUsers.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
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
                    !lastMonth
                        ? "${tmpUsers[index].clicks}"
                        : "${tmpUsers[index].record}",
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
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
