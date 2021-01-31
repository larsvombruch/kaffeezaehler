import 'package:flutter/material.dart';
import 'package:kaffeekanne_web/model/data/Users.dart';
import 'package:kaffeekanne_web/model/services/FirebaseHandler.dart';
import 'package:kaffeekanne_web/view/HomeScreen.dart';
import 'package:pinput/pin_put/pin_put.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FirebaseHandler firebaseHandler = FirebaseHandler();
  TextEditingController controller = TextEditingController();
  TextEditingController pinController = TextEditingController();

  int newClicks;

  List<Users> users = [];

  bool darkMode = false;

  bool wrong = false;

  bool tmp1 = false;
  bool tmp2 = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    await firebaseHandler.readKey().then((value) {
      if (value['key_enabled']) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
                child: AlertDialog(
                    backgroundColor: Color(0xFF363333),
                    actions: [
                      Container(
                        padding: EdgeInsets.all(15),
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ));
                          },
                          child: Text(
                            "Abbrechen",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                    scrollable: false,
                    content: StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: Text(
                                "PIN eingeben",
                                style: TextStyle(color: Colors.white),
                              ),
                              padding: EdgeInsets.only(bottom: 40),
                            ),
                            Container(
                              height: 100,
                              child: PinPut(
                                textStyle: TextStyle(
                                    color:
                                        darkMode ? Colors.white : Colors.black),
                                keyboardType: TextInputType.number,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: pinController,
                                validator: (element) {
                                  if (wrong) {
                                    try {
                                      pinController.text = "";
                                    } catch (e) {
                                      print(e);
                                    }
                                    return "Falsche Pin";
                                  } else {
                                    return '';
                                  }
                                },
                                withCursor: true,
                                autofocus: true,
                                focusNode: FocusNode(
                                  canRequestFocus: true,
                                ),
                                eachFieldHeight: 20,
                                followingFieldDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Color(0xFF004E98), width: 2)),
                                disabledDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Color(0xFF004E98), width: 2)),
                                selectedFieldDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Color(0xFF004E98), width: 2)),
                                submittedFieldDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Color(0xFF004E98), width: 2)),
                                fieldsCount: 4,
                                onSubmit: (value1) {
                                  if (value1 == value["pin"].toString()) {
                                    Navigator.pop(context);
                                  } else {
                                    setState(() => wrong = true);
                                    Future.delayed(Duration(milliseconds: 500),
                                        () {
                                      setState(() => wrong = false);
                                    });
                                  }
                                },
                              ),
                            )
                          ],
                        );
                      },
                    )),
                // ignore: missing_return
                onWillPop: () {});
          },
        );
      }
    });
    List tmp1 = [];
    await firebaseHandler.readData().then((value) {
      tmp1 = value.docs.map((doc) => doc.data()).toList();
      tmp1.forEach((element) {
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
              IconButton(icon: Icon(Icons.settings), onPressed: () {}),
            ],
            title: Text(
              "Dometic Kaffeezähler",
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            toolbarHeight: 50,
            elevation: 0,
            backgroundColor: Color(0xFF004E98),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                child: Text(
                  "Personenmanagement",
                  style: TextStyle(
                      fontSize: 20,
                      color: darkMode ? Colors.white : Colors.black),
                ),
              ),
              Container(
                width: size.width * .8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: darkMode ? Colors.black45 : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.2),
                      blurRadius: 2,
                      spreadRadius: 3,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20),
                  child: TextFormField(
                    style: TextStyle(
                        color: darkMode ? Colors.white : Colors.black),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (string) {
                      onAdd(string);
                    },
                    controller: controller,
                    // ignore: missing_return
                    validator: (value) {
                      if (tmp1) {
                        return "Name existiert bereits";
                      }
                      if (tmp2) {
                        return 'Bitte Namen eingeben';
                      }
                    },
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "Benutzer hinzufügen",
                      hintStyle: TextStyle(
                          color: darkMode ? Colors.white30 : Colors.grey),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorStyle: TextStyle(color: Colors.red),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add, color: Color(0xFF004E98)),
                        onPressed: () {
                          onAdd(controller.text);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: size.height * .02,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(
                              "${users[index].name} / ${users[index].clicks} Kaffeetassen",
                              style: TextStyle(
                                  color:
                                      darkMode ? Colors.white : Colors.black),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    onEdit(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.highlight_remove,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    onDelete(index);
                                  },
                                ),
                              ],
                            ));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        onWillPop: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            )));
  }

  void onAdd(String name) async {
    setState(() {
      tmp1 = false;
      tmp2 = false;
    });
    if (name != "") {
      if ((users.singleWhere((element) => element.name == name,
              orElse: () => null)) ==
          null) {
        await firebaseHandler.addDocument(
          document: controller.text,
          data: <String, dynamic>{
            'name': controller.text,
            'clicks': 0,
          },
        ).then((value) {
          setState(() {
            users.add(new Users(clicks: 0, name: controller.text));
          });
        });
      } else {
        setState(() {
          tmp1 = true;
        });
      }
    } else {
      setState(() {
        tmp2 = true;
      });
    }

    controller.clear();
  }

  void onDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            child: Text("Diesen Benutzer entfernen?"),
          ),
          actions: [
            // ignore: deprecated_member_use
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Nein")),
            // ignore: deprecated_member_use
            FlatButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await firebaseHandler.deleteDocument(users[index].name);
                  setState(() {
                    users.removeAt(index);
                  });
                },
                child: Text("Ja")),
          ],
        );
      },
    );
  }

  void applyEdits(int index, int newClicks) async {
    await firebaseHandler.writeData(
        collection: "userdata",
        document: users[index].name,
        data: <String, dynamic>{
          'clicks': newClicks,
        }).then((value) {
      setState(() {
        users[index].clicks = newClicks;
      });
      Navigator.pop(context);
    });
  }

  void onEdit(int index) {
    setState(() {
      newClicks = users[index].clicks;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            Container(
              padding: EdgeInsets.all(12),
              child:
                  // ignore: deprecated_member_use
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Abbrechen")),
            ),
            Container(
              padding: EdgeInsets.all(12),
              child:
                  // ignore: deprecated_member_use
                  FlatButton(
                      onPressed: () {
                        applyEdits(
                          index,
                          newClicks,
                        );
                      },
                      child: Text("Bestätigen")),
            ),
          ],
          content: StatefulBuilder(
            builder: (context, setState) => Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Text(users[index].name),
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 30, bottom: 20),
                    child: Text("Kaffeeanzahl ändern"),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Color(0xFF004E98),
                            ),
                            onPressed: () {
                              setState(() =>
                                  newClicks > 0 ? newClicks-- : newClicks = 0);
                            },
                          ),
                        ),
                        Container(
                          child: Text(
                            "$newClicks",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Container(
                          child: IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF004E98),
                            ),
                            onPressed: () {
                              setState(() => newClicks++);
                            },
                          ),
                        ),
                      ],
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
