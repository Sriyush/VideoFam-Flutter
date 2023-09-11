

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreMethods {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future uploadUserDetailsToDb({
    required String phone,
  }) async {
    await firebaseFirestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "phoneNo": phone,
      "uid": FirebaseAuth.instance.currentUser?.uid,
    });
  }

  Future<void> postVideo({
    required String title,
    required String des,
    required String location,
    required String category,
    required String url,
    required String? profileImageUrl,
    required String? userPhoneNumber,
  }) async {
    DateTime time = DateTime.now();
    String timestamp = time.millisecondsSinceEpoch.toString();
    Map<String,dynamic> data = {
      "postId": timestamp,
      "title": title,
      "des": des,
      "location": location,
      "videoUrl": url,
      'category': category,
      "profileImageUrl": profileImageUrl,
      "userPhoneNumber": userPhoneNumber,
    };
    await firebaseFirestore.collection("posts").doc("$timestamp").set(data);
  }

}

