import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

class FirebaseHandler {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future readData([String document]) async {
    if (document != null) {
      return await firebaseFirestore.collection("userdata").doc(document).get();
    } else {
      return await firebaseFirestore.collection("userdata").get();
    }
  }

  Future writeData(String document, Map<String, dynamic> data) async {
    await firebaseFirestore.collection("userdata").doc(document).update(data);
  }
}
