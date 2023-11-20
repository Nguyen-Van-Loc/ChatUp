import 'package:chatup/components/blue_page.dart';
import 'package:chatup/components/let_start.dart';
import 'package:chatup/components/logo.dart';
import 'package:chatup/components/terms_and_conditions.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/login/login.dart';
import 'package:chatup/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Hello extends StatelessWidget {
  const Hello({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: BluePageCaffold(
          imagePath: "assets/image/bg.jpg",
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Logo(
                  width: 150,
                  heigth: 150,
                  radius: 50,
                ),
                Text(
                  "Hello",
                  style: TextStyle(
                      color: Colors.white.withOpacity(.8), fontSize: 60),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "WhatsApp is a Cross-platform",
                      style: textFontWhite18,
                    ),
                    Text("mobile messaging with friends",
                        style: textFontWhite18),
                    Text("all over the world", style: textFontWhite18),
                  ],
                ),
                TermsAndConditions(
                  onPressed: () {},
                ),
                LetsStart(
                  onPressed: () {
                      navigateToPage(context, () => const Login());
                  },
                )
              ],
            ),
          ),
        ));
  }
}
