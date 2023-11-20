import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/components/logo.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/login/forgot_password.dart';
import 'package:chatup/login/signup.dart';
import 'package:chatup/main.dart';
import 'package:chatup/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String emailErr = "";
  String passErr = "";
  String userrnameErr = "";
  String repassErr = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool checkEye = false;

  void onLogin() async {
    final ap = Provider.of<Auth_Provide>(context, listen: false);
    setState(() {
      emailErr = validateEmail(emailController.text);
    });
    if (emailErr.isEmpty) {
      setState(() {
        passErr = validatePassword(passwordController.text);
      });
      if (passErr.isEmpty) {
        bool check = await ap.SignInWithEmail(
            context, emailController.text, passwordController.text);
        if (check) {
          navigateToPageRe(context, () => HomePage());
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.text;
  }

  FocusNode text1 = FocusNode();
  FocusNode text2 = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    emailErr = "";
    passErr = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(centerTitle: true, title: const Text("Log in")),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Logo(width: 150, heigth: 150, radius: 50),
            LoginContaner(),
            LogoSignIn()
          ],
        ),
      ),
    );
  }
  Widget LoginContaner() {
    return Column(
      children: [
        TextField(
          keyboardType: TextInputType.emailAddress,
          focusNode: text1,
          onSubmitted: (value) {
            text1.unfocus();
            FocusScope.of(context).requestFocus(text2);
          },
          style: TextStyle(fontSize: 18),
          controller: emailController,
          decoration: InputDecoration(
              border: UnderlineInputBorder(),
              errorText: emailErr.isNotEmpty ? emailErr : null,
              errorStyle: TextStyle(fontSize: 16),
              hintText: "Email",
              suffixIcon: emailController.text.trim().isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        emailController.clear();
                      },
                      icon: Icon(Icons.clear),
                    )
                  : null,
              prefixIcon: Icon(
                Icons.email_outlined,
                size: 30,
              )),
        ),
        const SizedBox(
          height: 30,
        ),
        TextField(
          focusNode: text2,
          onSubmitted: (value) {
            onLogin();
          },
          controller: passwordController,
          obscureText: !checkEye,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
              border: UnderlineInputBorder(),
              errorText: passErr.isNotEmpty ? passErr : null,
              errorStyle: TextStyle(fontSize: 16),
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
        ),
        const SizedBox(
          height: 50,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 17, horizontal: 100),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            onPressed: () {
              setState(() {
                onLogin();
              });
            },
            child: Text(
              "Log in",
              style: textFontWhite18,
            )),
        const SizedBox(
          height: 10,
        ),
        TextButton(
            onPressed: () {
              navigateToPage(context, () => ForgotPassword());
            },
            child: const Text(
              "Forgot Password ?",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            )),
      ],
    );
  }
}

class LogoSignIn extends StatelessWidget {
  const LogoSignIn({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have on account ? ",
              style: TextStyle(fontSize: 15),
            ),
            TextButton(
                onPressed: () {
                  navigateToPage(context, () => Signup());
                },
                child: const Text(
                  "Sign up",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ))
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
    );
  }
}

