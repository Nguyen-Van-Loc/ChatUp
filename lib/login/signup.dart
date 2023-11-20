import 'dart:io';
import 'dart:math';
import 'package:chatup/api/apis.dart';
import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/components/logo.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/main.dart';
import 'package:chatup/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  File? image;
  String? linkImage;
  File? imageBackround;
  String? linkImageBackround;
  bool checkEye = false;
  Random random = Random();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repasswordController = TextEditingController();
  String emailErr="";
  String passErr="";
  String usernameErr="";
  String repassErr="";
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repasswordController.dispose();
  }
  FocusNode text1=FocusNode();
  FocusNode text2=FocusNode();
  FocusNode text3=FocusNode();
  FocusNode text4=FocusNode();
  void onSignUp() async {
    setState(() {
      usernameErr = validateUsername(nameController.text);
    });
    if (usernameErr.isEmpty) {
      setState(() {
        emailErr = validateEmail(emailController.text);
      });
      if (emailErr.isEmpty) {
        setState(() {
          passErr = validatePassword(passwordController.text);
        });
        if (passErr.isEmpty) {
          setState(() {
            repassErr = validateRePassword(
                passwordController.text, repasswordController.text);
          });
          if (repassErr.isEmpty) {
            EasyLoading.show(status:"loading...");
            await addUser();
            navigateToPageRe(context, () =>const HomePage());
            EasyLoading.dismiss();
          }
        }
      }
    }
  }
  Future<void> uploadImageBackround() async {
    int randomNumber = random.nextInt(7) + 1;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      final assetImage = await rootBundle.load('assets/image/backround$randomNumber.jpg');
      Reference storageRef = FirebaseStorage.instance.ref().child('images/$userId/logoBackround.png');
      await storageRef.putData(assetImage.buffer.asUint8List());
      String downloadURL = await FirebaseStorage.instance
          .ref()
          .child("images/$userId/logoBackround.png")
          .getDownloadURL();
      setState(() {
        linkImageBackround = downloadURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(centerTitle: true, title: const Text("Sign up")),
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Logo(width: 150, heigth: 150, radius: 50),
            SignUpContainer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {dialogSupport(context);},
                  icon: Image.asset("assets/image/facebook.png"),
                  iconSize: 50,
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {signGG(context);},
                  icon: Image.asset("assets/image/google.png"),
                  iconSize: 50,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget SignUpContainer()  => Column(
    children: [
      TextField(
        focusNode: text1,
        onSubmitted: (value) {
          text1.unfocus();
          FocusScope.of(context).requestFocus(text2);
        },
        style: const TextStyle(fontSize: 18),
        controller: nameController,
        decoration: InputDecoration(
            errorText: usernameErr.isNotEmpty ? usernameErr : null,
            errorStyle: const TextStyle(fontSize: 16),
            hintText: "Username",
            prefixIcon: const Icon(
              Icons.person_outline,
              size: 30,
            )),
      ),
      const SizedBox(
        height: 30,
      ),
      TextField(
        focusNode: text2,
        onSubmitted: (value) {
          text2.unfocus();
          FocusScope.of(context).requestFocus(text3);
        },
        style: const TextStyle(fontSize: 18),
        controller: emailController,
        decoration: InputDecoration(
            errorText: emailErr.isNotEmpty ? emailErr : null,
            errorStyle: const TextStyle(fontSize: 16),
            hintText: "Email",
            prefixIcon: const Icon(
              Icons.email_outlined,
              size: 30,
            )),
      ),
      const SizedBox(
        height: 30,
      ),
      TextField(
        focusNode: text3,
        onSubmitted: (value) {
          text3.unfocus();
          FocusScope.of(context).requestFocus(text4);
        },
        controller: passwordController,
        obscureText: !checkEye,
        decoration: InputDecoration(
            errorText: passErr.isNotEmpty ? passErr : null,
            errorStyle: const TextStyle(fontSize: 16),
            suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    checkEye = !checkEye;
                  });
                },
                child: checkEye
                    ? const Icon(CupertinoIcons.eye_fill)
                    : const Icon(CupertinoIcons.eye_slash_fill)),
            hintText: "Password",
            prefixIcon: const Icon(Icons.lock_outline, size: 30)),
      ), const SizedBox(
        height: 30,
      ),
      TextField(
        focusNode: text4,
        onSubmitted: (value) {
          onSignUp();
        },
        controller: repasswordController,
        obscureText: !checkEye,
        decoration: InputDecoration(
            errorText: repassErr.isNotEmpty ? repassErr : null,
            errorStyle: const TextStyle(fontSize: 16),
            suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    checkEye = !checkEye;
                  });
                },
                child: checkEye
                    ? const Icon(CupertinoIcons.eye_fill)
                    : const Icon(CupertinoIcons.eye_slash_fill)),
            hintText: "Repassword",
            prefixIcon: const Icon(Icons.lock_outline, size: 30)),
      ),
      const SizedBox(
        height: 30,
      ),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(vertical: 17, horizontal: 100),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          onPressed: () {
            setState(() {
              onSignUp();
            });
          },
          child: Text(
            "Sign up",
            style: textFontWhite18,
          )),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have on account ? ",
            style: TextStyle(fontSize: 15),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Sign in",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ))
        ],
      ),
    ],
  );

  Future<void> addUser() async {
    final ap = Provider.of<Auth_Provide>(context, listen: false);
    try {
      await ap.SignUpWithEmail(context, emailController.text, passwordController.text);
      await uploadImage();
      await uploadImageBackround();
      SignUp(email: emailController.text,name: nameController.text,avatar: linkImage,imageBr: linkImageBackround);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        EasyLoading.showError("Email is already in use");
      }
    } catch (e) {
      print("$e 4143141");
    }
    EasyLoading.dismiss();
  }
  Future<void> uploadImage() async {
    User? user = APIs.auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      final assetImage = await rootBundle.load('assets/image/logo_user.png');
      Reference storageRef = APIs.storage.ref().child('images/$userId/logo.png');
      await storageRef.putData(assetImage.buffer.asUint8List());
      String downloadURL = await FirebaseStorage.instance
          .ref()
          .child("images/$userId/logo.png")
          .getDownloadURL();
      linkImage = downloadURL;
    }
  }

}
