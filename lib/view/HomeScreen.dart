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
  List<Users> top5 = [];
  TextEditingController controller = TextEditingController();
  final FirebaseHandler firebaseHandler = FirebaseHandler();

  int mustPayAt = 0;

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

  List<String> collectionList = [
    "userdata",
    "bfthis",
    "bfbfthis",
    "bfbfbfthis",
    "bfbfbfbfthis",
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
        await firebaseHandler.writeData(
            collection: "security",
            document: "month",
            data: <String, dynamic>{
              'last': months[DateTime.now().month - 1],
            });
        handleNewMonth();
      }
    });
  }

  void handleNewMonth() async {
    //month 3 to month 4
    await firebaseHandler.readData(collection: "bfbfbfthis").then((value) {
      List tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) async {
        await firebaseHandler.writeData(
            collection: "bfbfbfbfthis",
            document: element.name,
            data: {
              'clicks': element.clicks,
              'paidAt': element.paidAt,
              'paymentRequired': element.paymentRequired,
              'name': element.name
            });
      });
    });
    //month 2 to month 3
    await firebaseHandler.readData(collection: "bfbfthis").then((value) {
      List tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) async {
        await firebaseHandler
            .writeData(collection: "bfbfbfthis", document: element.name, data: {
          'clicks': element.clicks,
          'paidAt': element.paidAt,
          'paymentRequired': element.paymentRequired,
          'name': element.name
        });
      });
    });
    //month 1 to month 2
    await firebaseHandler.readData(collection: "bfthis").then((value) {
      List tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) async {
        await firebaseHandler
            .writeData(collection: "bfbfthis", document: element.name, data: {
          'clicks': element.clicks,
          'paidAt': element.paidAt,
          'paymentRequired': element.paymentRequired,
          'name': element.name
        });
      });
    });
    //this month to month 1
    users.forEach((element) async {
      await firebaseHandler.writeData(
        collection: "bfthis",
        document: element.name,
        data: {
          'clicks': element.clicks,
          'paidAt': element.paidAt,
          'paymentRequired': element.paymentRequired,
          'name': element.name
        },
      );
    });

    await firebaseHandler.resetClicks();
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
                              text: "Top 5 Kaffeetrinker / Zusammenfassung",
                              textStyle: TextStyle(
                                  color:
                                      darkMode ? Colors.white : Colors.black)),
                          tooltipBehavior: charts.TooltipBehavior(
                            enable: false,
                          ),
                          backgroundColor:
                              darkMode ? Colors.black45 : Colors.white,
                          primaryXAxis: charts.CategoryAxis(
                            labelIntersectAction:
                                charts.AxisLabelIntersectAction.multipleRows,
                            majorGridLines: charts.MajorGridLines(width: 0),
                            majorTickLines: charts.MajorTickLines(width: 0),
                            minorGridLines: charts.MinorGridLines(width: 0),
                            labelStyle: painting.TextStyle(
                                color: darkMode ? Colors.white : Colors.black,
                                fontSize: 12),
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
                              dataLabelSettings: charts.DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(
                                    color:
                                        darkMode ? Colors.white : Colors.black),
                              ),
                              width: .5,
                              sortFieldValueMapper: (Users user, _) =>
                                  user.clicks,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              sortingOrder: charts.SortingOrder.descending,
                              dataSource: top5,
                              xValueMapper: (Users user, _) => user.name,
                              yValueMapper: (Users user, _) => user.clicks,
                              pointColorMapper: (Users user, _) =>
                                  user.paymentRequired
                                      ? Colors.red
                                      : Colors.orange,
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
                        child: Text("Kaffee hinzufügen",
                            style: TextStyle(
                                fontSize: 20,
                                color: darkMode ? Colors.white : Colors.black)),
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
          paymentRequired: element['paymentRequired'],
          paidAt: element['paidAt'],
        ));
      });

      tmpUsers.sort((a, b) => a.clicks.compareTo(b.clicks));
    });

    int _i = 0;
    if (tmpUsers.length > 5) {
      tmpUsers.removeRange(0, tmpUsers.length - 5);
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
        top5 = value;
      });
    });
  }

  void initializeUsers() async {
    await firebaseHandler
        .readData(collection: "security", document: "month")
        .then((value) {
      setState(() {
        mustPayAt = value['mustPayAt'];
      });
    });
    await firebaseHandler.readData().then((value) {
      List tmp2 = [];
      tmp2 = value.docs.map((doc) => doc.data()).toList();
      tmp2.forEach((element) async {
        if (element['clicks'] - element['paidAt'] >= mustPayAt) {
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
      });
    });
    List tmp = [];
    await firebaseHandler.readData().then((value) {
      tmp = value.docs.map((doc) => doc.data()).toList();

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
    await getMostCafes().then((value) {
      setState(() {
        top5 = value;
      });
    });
  }

  void updateClicks(String username, int addedClicks) async {
    await firebaseHandler.readData(document: username).then((value) {
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
          collection: "userdata",
          document: username,
          data: {'clicks': element.clicks + addedClicks},
        );

        await getMostCafes().then((value) {
          setState(() {
            top5 = value;
          });
        });

        setState(() {
          element.clicks = element.clicks + addedClicks;
        });
      }
    });
  }
}
