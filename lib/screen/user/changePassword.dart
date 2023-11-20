import 'package:chatup/api/apis.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/login/login.dart';
import 'package:chatup/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

class VerifyAccount extends StatefulWidget {
  const VerifyAccount({super.key});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  final controller = TextEditingController();
  bool checkEye = false;
  String errPassOld = "";

  void check(String passOld) async {
    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: APIs.user.email!,
        password: passOld,
      );
      if (controller.text.length < 6) {
        setState(() {
          errPassOld = "Password must not be less than 6 characters";
        });
        return;
      }
      try {
        await APIs.user.reauthenticateWithCredential(credential);
        EasyLoading.show(status: "Verifying account");
        await Future.delayed(const Duration(seconds: 3));
        EasyLoading.dismiss();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (context) => const ChangePassword()));
      } catch (e) {
        setState(() {
          errPassOld = "Old password is not correct";
        });
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Account"),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Please enter your current password for verification",
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: controller,
                obscureText: !checkEye,
                onChanged: (text) {
                  setState(() {});
                },
                decoration: InputDecoration(
                    errorText:  errPassOld.isNotEmpty ? errPassOld : null,
                    hintText: "Please enter...",
                    border: OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => controller.clear(),
                          child: controller.text.isNotEmpty
                              ? Icon(Icons.clear)
                              : SizedBox.shrink(),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () => setState(() {
                            checkEye = !checkEye;
                          }),
                          child: checkEye
                              ? Icon(CupertinoIcons.eye_fill)
                              : Icon(CupertinoIcons.eye_slash_fill),
                        ),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    )),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.text.isNotEmpty? () {check(controller.text);}:null,
                  child: Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool checkpass = true;
  final passNewController = TextEditingController();
  final repassNewController = TextEditingController();
  String errPassNew = "",
      errRePassNew = "";

  void onPass() async {
    setState(() {
      errPassNew = validatePassword(passNewController.text);
    });
    if (errPassNew.isEmpty) {
      setState(() {
        errRePassNew = validateRePassword(
            repassNewController.text, passNewController.text);
      });
      if (errRePassNew.isEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        await user!.updatePassword(passNewController.text);
        EasyLoading.show(status: "loading...");
        await Future.delayed(const Duration(seconds: 3));
        EasyLoading.dismiss();
        EasyLoading.showSuccess(
            "Password change successful!\n Please log in to the application again.");
        await Future.delayed(const Duration(seconds: 3));
        await APIs.auth.signOut();
        navigateToPage(context, () =>const Login());
      }
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    passNewController.clear();
    repassNewController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter your new password",
                    style: TextStyle(
                        fontFamily: "LibreBodoni-Medium", fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passNewController,
                    obscureText: checkpass,
                    decoration: InputDecoration(
                        errorText: errPassNew.isNotEmpty ? errPassNew : null,
                        hintText: "Enter your new password",
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                checkpass = !checkpass;
                              });
                            },
                            child: checkpass
                                ? const Icon(CupertinoIcons.eye_slash)
                                : const Icon(CupertinoIcons.eye)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        )),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter a new password",
                    style: TextStyle(
                        fontFamily: "LibreBodoni-Medium", fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: repassNewController,
                    obscureText: checkpass,
                    decoration: InputDecoration(
                        errorText:
                        errRePassNew.isNotEmpty ? errRePassNew : null,
                        hintText: "Enter a new password",
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                checkpass = !checkpass;
                              });
                            },
                            child: checkpass
                                ? const Icon(CupertinoIcons.eye_slash)
                                : const Icon(CupertinoIcons.eye)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {
                onPass();
              },
              style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text(
                "Confirm",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "LibreBodoni-MediumItalic",
                    fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}