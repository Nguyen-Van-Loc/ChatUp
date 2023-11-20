import 'package:chatup/Screen/user/profile.dart';
import 'package:chatup/api/apis.dart';
import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/login/login.dart';
import 'package:chatup/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.only(top: 10, left: 10),
                child: const Text(
                  "Settings",
                  style: textFont,
                )),
            const Divider(),
            const SettingsWidget(),
          ],
        ),
      ),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<getUser>(context, listen: false).fetchData();
  }
  void dialogsupport(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(
            child: Text("Support center",
                style: TextStyle(fontFamily: "LibreBodoni-Medium")),
          ),
          content:
          const Text("If you have any questions, please contact \nHotline: 19001006."),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Confirm"),
              ),
            )
          ],
        ));
  }
  void dialogSupport(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(
            child: Text("Support center",
                style: TextStyle(fontFamily: "LibreBodoni-Medium")),
          ),
          content:
          const Text("The skill are improving !."),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Confirm"),
              ),
            )
          ],
        ));
  }
  @override
  Widget build(BuildContext context) {
    final item = Provider.of<getUser>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20,
        ),
        CircleAvatar(
          backgroundImage: NetworkImage(
              item.data.isEmpty ? "" : item.data[0]["data"]["avatar"]),
          radius: 70,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            item.data.isEmpty ? "" : item.data[0]["data"]["name"],
            style: const TextStyle(fontSize: 30),
          ),
        ),
        Divider(
          thickness: 2,
          color: colorText,
        ),
        const SizedBox(
          height: 20,
        ),
        cusmtom(
            onPress: () {dialogSupport(context);},
            text: "Chats",
            iconData: CupertinoIcons.chat_bubble_text_fill),
        cusmtom(
            onPress: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const Profile(),
                  ));
            },
            text: "Accout",
            iconData: Icons.person),
        cusmtom(
            onPress: () {dialogSupport(context);},
            text: "Notifications",
            iconData: Icons.notifications_none_sharp),
        cusmtom(
            onPress: () {dialogsupport(context);}, text: "Help", iconData: Icons.help_outline_sharp),
        cusmtom(
            onPress: () async {
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut();
                APIs.auth = FirebaseAuth.instance;
                EasyLoading.show(status: "loading...");
                await Future.delayed(const Duration(seconds: 3));
                EasyLoading.dismiss();
                navigateToPageRe(context, () => const Login());
              });
            },
            text: "Log Out",
            iconData: Icons.exit_to_app),
      ],
    );
  }

  Widget cusmtom({required Function() onPress,
    required String text,
    required IconData iconData}) {
    return InkWell(
      onTap: onPress,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Row(
            children: [
              Icon(
                iconData,
                color: colorText,
                size: 30,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                text,
                style: const TextStyle(fontSize: 15),
              )
            ],
          )),
    );
  }
}
