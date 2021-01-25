import 'package:flutter/material.dart';
import 'package:kaffeekanne_web/model/core/SelectionCard.dart';
import 'package:kaffeekanne_web/model/services/FirebaseHandler.dart';
import 'package:kaffeekanne_web/view/SettingsScreen.dart';
import 'package:kaffeekanne_web/view/SummaryScreen.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:flutter/painting.dart' as painting;
import '../model/data/Users.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Users> users = [];
  List<Users> top3 = [];
  TextEditingController controller = TextEditingController();
  final FirebaseHandler firebaseHandler = FirebaseHandler();

  bool darkMode = false;

  String lastMonth = "";

  List<String> months = [
    "jan",
    "feb",
    "mar",
    "apr",
    "may",
    "jun",
    "jul",
    "aug",
    "sep",
    "okt",
    "nov",
    "dec"
  ];

  @override
  void initState() {
    initializeUsers();
    compareMonth();
    getMostCafes();
    super.initState();
  }

  void compareMonth() async {
    await firebaseHandler.readMonth().then((value) async {
      lastMonth = value["last"];
      if (months[DateTime.now().month - 1] != value["last"]) {
        await firebaseHandler.writeData("security", "month", <String, dynamic>{
          'last': months[DateTime.now().month - 1],
        });
        handleNewMonth();
      }
    });
  }

  void handleNewMonth() async {
    users.forEach((element) async {
      await firebaseHandler.writeData(
        "userdata",
        element.name,
        <String, dynamic>{'record': element.clicks},
      );
    });
    await firebaseHandler.resetClicks();
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
            backgroundColor: painting.Color(0xFF004E98),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SummaryScreen(),
                      ));
                },
                child: Container(
                  height: 250,
                  width: size.width,
                  child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 2),
                          color: Colors.black.withOpacity(.2),
                          blurRadius: 3,
                          spreadRadius: 2,
                        )
                      ], color: darkMode ? Colors.black : Colors.white),
                      width: 400,
                      height: 150,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: charts.SfCartesianChart(
                          onChartTouchInteractionUp: (args) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SummaryScreen(),
                                ));
                          },
                          title: charts.ChartTitle(
                              text: "Top 3 Kaffeetrinker / Zusammenfassung"),
                          tooltipBehavior: charts.TooltipBehavior(
                            enable: false,
                          ),
                          backgroundColor:
                              darkMode ? Colors.black45 : Colors.white,
                          primaryXAxis: charts.CategoryAxis(
                            majorGridLines: charts.MajorGridLines(width: 0),
                            majorTickLines: charts.MajorTickLines(width: 0),
                            minorGridLines: charts.MinorGridLines(width: 0),
                            labelStyle: painting.TextStyle(
                                color: darkMode ? Colors.white : Colors.black),
                            axisLine: charts.AxisLine(width: 0),
                          ),
                          primaryYAxis: charts.NumericAxis(
                            maximumLabels: 2,
                            majorGridLines: charts.MajorGridLines(width: 0),
                            majorTickLines: charts.MajorTickLines(width: 0),
                            minorGridLines: charts.MinorGridLines(width: 0),
                            labelStyle: painting.TextStyle(
                                color: darkMode ? Colors.white : Colors.black),
                            placeLabelsNearAxisLine: true,
                            axisLine: charts.AxisLine(width: 0),
                          ),
                          plotAreaBorderWidth: 0,
                          series: <charts.ColumnSeries<Users, String>>[
                            charts.ColumnSeries<Users, String>(
                              dataLabelSettings:
                                  charts.DataLabelSettings(isVisible: true),
                              width: .5,
                              sortFieldValueMapper: (Users user, _) =>
                                  user.clicks,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              sortingOrder: charts.SortingOrder.descending,
                              color: Colors.orange,
                              dataSource: top3,
                              xValueMapper: (Users user, _) => user.name,
                              yValueMapper: (Users user, _) => user.clicks,
                            ),
                          ],
                        ),
                      )),
                ),
              ),
              Container(
                height: 8,
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Container(
                        child: Text(
                          "Kaffee hinzufügen",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: GridView.count(
                        childAspectRatio: .7,
                        shrinkWrap: true,
                        clipBehavior: Clip.none,
                        crossAxisCount: 2,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 30.0,
                        crossAxisSpacing: 30.0,
                        children: List.generate(users.length, (index) {
                          return SelectionCard(
                            name: users[index].name,
                            onSubmitted: () {
                              onSubmitted();
                            },
                          );
                        }),
                      ),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
        // ignore: missing_return
        onWillPop: () async => true);
  }

  Future<List<Users>> getMostCafes() async {
    List<Users> tmpUsers = [];
    List tmp = [];
    await firebaseHandler.readData().then((value) {
      tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) {
        tmpUsers.add(Users(
          name: element['name'],
          clicks: element['clicks'],
          record: element['record'],
        ));
      });

      tmpUsers.sort((a, b) => a.clicks.compareTo(b.clicks));
    });

    int _i = 0;
    if (tmpUsers.length > 3) {
      tmpUsers.removeRange(0, tmpUsers.length - 3);
    }

    tmpUsers.forEach((element) {
      if (element.clicks == 0) {
        _i++;
      }
    });
    if (_i == 3) {
      tmpUsers = [];
    }
    return tmpUsers;
  }

  void onSubmitted() async {
    await getMostCafes().then((value) {
      setState(() {
        top3 = value;
      });
    });
  }

  void initializeUsers() async {
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
    await getMostCafes().then((value) {
      setState(() {
        top3 = value;
      });
    });
  }

  void updateClicks(String username, int addedClicks) async {
    await firebaseHandler.readData(username).then((value) {
      users.forEach((element) {
        if (element.name == username) {
          setState(() {
            element.clicks = value['clicks'];
          });
        }
      });
    });
    users.forEach((element) async {
      if (element.name == username) {
        await firebaseHandler.writeData(
          "userdata",
          username,
          {'clicks': element.clicks + addedClicks},
        );

        await getMostCafes().then((value) {
          setState(() {
            top3 = value;
          });
        });

        setState(() {
          element.clicks = element.clicks + addedClicks;
        });
      }
    });
  }
}
