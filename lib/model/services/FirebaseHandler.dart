import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaffeekanne_web/model/data/Users.dart';

class FirebaseHandler {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future readData({String document, String collection}) async {
    if (document != null && collection == null) {
      return await firebaseFirestore.collection("userdata").doc(document).get();
    } else if (collection == null && document == null) {
      return await firebaseFirestore.collection("userdata").get();
    } else if (collection != null && document == null) {
      return await firebaseFirestore.collection(collection).get();
    } else {
      return await firebaseFirestore.collection(collection).doc(document).get();
    }
  }

  Future readKey() async {
    return await firebaseFirestore.collection("security").doc("key").get();
  }

  Future writeData(
      {String collection, String document, Map<String, dynamic> data}) async {
    await firebaseFirestore
        .collection(collection)
        .doc(document)
        .set(data, SetOptions(merge: true));
  }

  Future resetClicks() async {
    List<Users> users = [];
    await readData().then((value) {
      List tmp = [];
      tmp = value.docs.map((doc) => doc.data()).toList();
      tmp.forEach((element) {
        users.add(new Users(
          name: element['name'],
        ));
      });
      users.forEach((element) async {
        await writeData(
            collection: "userdata",
            document: element.name,
            data: <String, dynamic>{
              'clicks': 0,
              'paymentRequired': false,
              'paidAt': 0
            });
      });
    });
  }

  Future deleteDocument(String document) async {
    await firebaseFirestore.collection("userdata").doc(document).delete();
  }

  Future addDocument(
      {String collection, String document, Map<String, dynamic> data}) async {
    if (collection != null) {
      await firebaseFirestore.collection(collection).doc(document).set(data);
    }
    await firebaseFirestore.collection("userdata").doc(document).set(data);
  }

  Future readMonth() async {
    return await firebaseFirestore.collection("security").doc("month").get();
  }
}
