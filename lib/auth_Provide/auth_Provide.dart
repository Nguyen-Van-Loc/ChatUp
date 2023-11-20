import 'dart:io';

import 'package:chatup/api/apis.dart';
import 'package:chatup/main.dart';
import 'package:chatup/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth_Provide extends ChangeNotifier {
  Future<void> SignUpWithEmail(
      BuildContext context, String email, String password) async {
    try {
      final UserCredential() = await APIs.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        EasyLoading.showError("Email đã được sử dụng");
      }
    } catch (e) {
      print(e);
    }
    EasyLoading.dismiss();
  }

  Future<bool> SignInWithEmail(
      BuildContext context, String email, String password) async {
    EasyLoading.show(status: "loading...");
    try {
      final UserCredential() = await APIs.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      EasyLoading.dismiss();
      return true;
    } catch (e) {
      await Future.delayed(Duration(seconds: 3));
      EasyLoading.dismiss();
      EasyLoading.showError("Email or password is incorrect");
    }
    return false;
  }
}

class getUser extends ChangeNotifier {
  List<Map<String, dynamic>> _data = [];

  List<Map<String, dynamic>> get data => _data;
  void clearUserData() {
    _data.clear();
    notifyListeners();
  }
  Future<void> fetchData() async {
    try {
      User? user = APIs.auth.currentUser;
      if (user != null) {
        final email = user.email;
        final querySnapshot = await APIs.firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        _data = querySnapshot.docs.map((doc) {
          final Map<String, dynamic> data = doc.data();
          final String key = doc.id;
          return {"key": key, "data": data};
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi lấy dữ liệu từ Firestore: $e');
      }
    }
  }
}

signGG(BuildContext context) {
  EasyLoading.show(status: "loading...");
  _signInWithGoogle().then((value) async {
    EasyLoading.dismiss();
    if (value != null) {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      String? email = value.user!.email;
      Future<bool> checkUserExists(String email) async {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await APIs
            .firestore
            .collection("users")
            .where("email", isEqualTo: email)
            .get();
        return querySnapshot.docs.isNotEmpty;
      }
      if (googleUser != null) {
        bool userExists = await checkUserExists(email!);
        if(!userExists){
          SignUp(email: value.user!.email,name: value.user!.displayName,avatar: value.user!.photoURL,imageBr: "https://i.imgur.com/2KWGlnS.jpg");
        }
        navigateToPageRe(context, () => const HomePage());
      }
    }
  });
}

Future<UserCredential?> _signInWithGoogle() async {
  try {
    await InternetAddress.lookup("google.com");
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return null;
    }
    else {
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  } catch (e) {
    print("_signInWithGoogle: $e");
    EasyLoading.dismiss();
    EasyLoading.showError("Something Went Wrong (Check Internet!)");
    return null;
  }
}
class getFriendUser extends ChangeNotifier {
  List<Map<String, dynamic>> _data = [];

  List<Map<String, dynamic>> get data => _data;
  Future<void> fetchDataFriend(String id) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final List<Map<String, dynamic>> products = [];
        final productsQuery = await APIs.firestore
            .collection('users')
            .doc(id)
            .collection('friend')
            .get();
        for (final productDoc in productsQuery.docs) {
          final String productKey = productDoc.id;
          final Map<String, dynamic> productData =
          productDoc.data();
          products.add({"key": productKey, "data": productData});

        }_data = products;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi lấy dữ liệu từ Firestore: $e');
      }
    }
  }
}
