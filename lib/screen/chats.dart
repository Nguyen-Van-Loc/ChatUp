import 'package:chatup/Screen/user/information_User.dart';
import 'package:chatup/api/apis.dart';
import 'package:chatup/auth_Provide/auth_Provide.dart';

import 'package:chatup/config/font.dart';
import 'package:chatup/model/chat_user.dart';
import 'package:chatup/utils/utils.dart';
import 'package:chatup/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: const Text(
                      "Chats",
                      style: textFont,
                    )),
                MaterialButton(
                  padding: const EdgeInsets.only(top: 5),
                  minWidth: 0,
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Search(),
                        ));
                  },
                  child: const Icon(Icons.search_rounded),
                ),
              ],
            ),
            const Divider(
              thickness: 1,
            ),
            const Expanded(child: ChatWidget()),
          ],
        ),
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  List<ChatUser> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: StreamBuilder(
              stream: APIs.firestore
                  .collection("users")
                  .doc(APIs.user.uid)
                  .collection("friend")
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(
                        child: LoadingAnimationWidget.waveDots(
                            color: Colors.red, size: 30));
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data!.docs;
                    list =
                        data.map((e) => ChatUser.fromJson(e.data())).toList();
                    if (snapshot.data!.docs.isNotEmpty) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: list.length,
                        itemExtent: 70,
                        padding: const EdgeInsets.only(left: 10, right: 20),
                        itemBuilder: (context, index) {
                          if (snapshot.data!.docs.isNotEmpty) {
                            return ChatUserCardItem(user: list[index]);
                          }
                          return Container();
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "No Connections Found! ",
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5,
                        color: Colors.grey.withOpacity(.2),
                        offset: const Offset(1, 1),
                        spreadRadius: 4)
                  ],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: StreamBuilder(
                //doc(APIs.user.uid).collection("friend")
                stream: APIs.firestore
                    .collection("users")
                    .doc(APIs.user.uid)
                    .collection("friend")
                    .snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(
                          child: LoadingAnimationWidget.waveDots(
                              color: Colors.red, size: 30));
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data!.docs;
                      list =
                          data.map((e) => ChatUser.fromJson(e.data())).toList();
                      if (snapshot.data!.docs.isNotEmpty) {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data!.docs.isNotEmpty) {
                              return ChatUserCard(user: list[index]);
                            }
                            return Container();
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No Connections Found! ",
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final controller = TextEditingController();
  List<ChatUser> list = [];

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_sharp),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 60,
                    height: 35,
                    child: TextField(
                      onChanged: (text) {
                        setState(() {}
                        );
                      },
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  controller.clear();
                                },
                              )
                            : null,
                        hintText: "Search...",
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder(
                stream: APIs.firestore.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!.docs;
                  list = data.map((e) => ChatUser.fromJson(e.data())).toList();
                  list = list.where((user) =>
                      removeAccents(user.name.toLowerCase()).contains(removeAccents(controller.text.toLowerCase())))
                      .toList();
                  list = list.where((user) => user.id != APIs.auth.currentUser?.uid).toList();
                 if (list.isNotEmpty){
                  return ListView.builder(
                    itemCount: list.length,
                    physics: const BouncingScrollPhysics(),
                    itemExtent: 60,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          navigateToPage(
                              context,
                              () =>
                                  Information_User(user: list[index]));
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  NetworkImage(list[index].avatar),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(list[index].name),
                          ],
                        ),
                      );
                    },
                  );}else{return const Center(
                   child: Text(
                     "No Connections Found! ",
                     style: TextStyle(fontSize: 20),
                   ),
                 );}
                }
              )
            ),
          ],
        ),
      ),
    );
  }
}

String removeAccents(String input) {
  final accentMap = {
    'àáảãạăắằẳẵặâấầẩẫậ': 'a',
    'Cc': 'c',
    'Gg': "g",
    'Hh': 'h',
    'Kk': 'k',
    'Ll': 'l',
    'Mm': 'm',
    "Nn": 'n',
    "Pp": 'p',
    "Qq": 'q',
    "Rr": 'r',
    "Ss": 's',
    "Tt": 't',
    "Vv": 'v',
    "Xx": 'x',
    'èéẻẽẹêếềểễệ': 'e',
    'ìíỉĩị': 'i',
    'òóỏõọôốồổỗộơớờởỡợ': 'o',
    'ùúủũụưứừửữự': 'u',
    'ỳýỷỹỵ': 'y',
    'đĐDd': 'd',
    'ÀÁẢÃẠĂẮằẲẴẶÂẤẦẨẪẬ': 'A',
    'ÈÉẺẼẸÊẾỀỂỄỆ': 'E',
    'ÌÍỈĨỊ': 'I',
    'ÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ': 'O',
    'ÙÚỦŨỤƯỨỪỬỮỰ': 'U',
    'ỲÝỶỸỴ': 'Y',
    'Bb': "b"
  };

  String result = input.toLowerCase();

  for (var pattern in accentMap.keys) {
    for (var accentChar in pattern.characters) {
      result = result.replaceAll(accentChar, accentMap[pattern]!);
    }
  }

  return result;
}
