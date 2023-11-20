import 'package:chatup/api/apis.dart';
import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/components/logo.dart';
import 'package:chatup/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailControler = TextEditingController();
  String errEmail = "";
  void onSend() async {
    setState(() {
      errEmail = validateEmail(emailControler.text);
    });
    if (errEmail.isEmpty) {
      EasyLoading.show(status: "loading...");
      await Future.delayed(const Duration(seconds: 3));
      EasyLoading.dismiss();
      APIs.auth.sendPasswordResetEmail(email: emailControler.text);
      EasyLoading.showSuccess("Success");
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailControler.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(centerTitle: true, title: const Text("Forgot Password")),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Logo(width: 150, heigth: 150, radius: 50),
            Column(
              children: [
                TextField(
                  onSubmitted: (value) {
                    onSend();
                  },
                  style: const TextStyle(fontSize: 18),
                  controller: emailControler,
                  decoration: InputDecoration(
                      errorText: errEmail.isNotEmpty ? errEmail : null,
                      errorStyle: TextStyle(fontSize: 16),
                      hintText: "Email",
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: 30,
                      )),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(

                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 17, horizontal: 100),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    onPressed: () {
                      setState(() {
                        onSend();
                      });
                    },
                    child: Text(
                      "Reset Password",
                      style: TextStyle(fontSize: 18),
                    )),
              ],
            ),
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
}
