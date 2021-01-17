import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaffeekanne_web/model/services/FirebaseHandler.dart';
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
  User newUser;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    initializeUsers();
    getMostCafes();
    super.initState();
  }

  final FirebaseHandler firebaseHandler = FirebaseHandler();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: painting.Color(0xFF004E98),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: painting.Color(0xFF004E98),
                height: 300,
                width: size.width,
                child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 2),
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 3,
                        spreadRadius: 2,
                      )
                    ], color: Colors.white),
                    width: 400,
                    height: 200,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: charts.SfCartesianChart(
                        title: charts.ChartTitle(text: "Top 3 Kaffeetrinker"),
                        backgroundColor: Colors.white,
                        onChartTouchInteractionMove: (value) {},
                        tooltipBehavior: charts.TooltipBehavior(
                          canShowMarker: false,
                          enable: true,
                          activationMode: charts.ActivationMode.doubleTap,
                          format: 'point.y',
                          header: 'Kaffeetassen',
                        ),
                        primaryXAxis: charts.CategoryAxis(
                          majorGridLines: charts.MajorGridLines(width: 0),
                          majorTickLines: charts.MajorTickLines(width: 0),
                          minorGridLines: charts.MinorGridLines(width: 0),
                          labelStyle: painting.TextStyle(color: Colors.black),
                          axisLine: charts.AxisLine(width: 0),
                        ),
                        primaryYAxis: charts.NumericAxis(
                          maximumLabels: 2,
                          majorGridLines: charts.MajorGridLines(width: 0),
                          majorTickLines: charts.MajorTickLines(width: 0),
                          minorGridLines: charts.MinorGridLines(width: 0),
                          labelStyle: painting.TextStyle(color: Colors.black),
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
                                topRight: Radius.circular(10)),
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
              Container(
                  padding: EdgeInsets.only(top: size.height * .05),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            child: TextField(
                              controller: controller,
                            ),
                          ),
                          Container(
                            child: Container(
                              child: FlatButton(
                                child: Text("TEST"),
                                onPressed: () {
                                  updateClicks(
                                      controller.text != ""
                                          ? controller.text
                                          : "Lars vom Bruch",
                                      10);
                                  controller.clear();
                                },
                              ),
                            ),
                            height: 270,
                            width: size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.3),
                                      blurRadius: 3,
                                      spreadRadius: 2,
                                      offset: Offset(0, 2))
                                ],
                                borderRadius: BorderRadius.circular(12)),
                          )
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ));
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

    tmpUsers.removeRange(0, tmpUsers.length - 3);
    return tmpUsers;
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
