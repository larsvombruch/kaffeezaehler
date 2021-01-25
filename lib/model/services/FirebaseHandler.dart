import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaffeekanne_web/model/data/Users.dart';

class FirebaseHandler {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future readData([String document, String collection]) async {
    if (document != null) {
      return await firebaseFirestore.collection("userdata").doc(document).get();
    } else {
      return await firebaseFirestore.collection("userdata").get();
    }
  }

  Future readKey() async {
    return await firebaseFirestore.collection("security").doc("key").get();
  }

  Future writeData(
      [String collection, String document, Map<String, dynamic> data]) async {
    await firebaseFirestore.collection(collection).doc(document).update(data);
  }

  Future resetClicks() async {
    List<Users> users = [];
    await readData().then((value) async {
      List tmp = [];
      tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) {
        users.add(new Users(
          clicks: element['clicks'],
          name: element['name'],
          record: element['record'],
        ));
      });
      users.forEach((element) async {
        await writeData(
            "userdata", element.name, <String, dynamic>{'clicks': 0});
      });
    });
  }

  Future deleteDocument(String document) async {
    await firebaseFirestore.collection("userdata").doc(document).delete();
  }

  Future addDocument(String document, Map<String, dynamic> data) async {
    await firebaseFirestore.collection("userdata").doc(document).set(data);
  }

  Future readMonth() async {
    return await firebaseFirestore.collection("security").doc("month").get();
  }
}
