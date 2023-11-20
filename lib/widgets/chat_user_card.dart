import 'package:chatup/Screen/chatScreen.dart';
import 'package:chatup/api/apis.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/model/chat_user.dart';
import 'package:chatup/model/messages.dart';
import 'package:chatup/utils/mydate.dart';
import 'package:chatup/utils/utils.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Messages? message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navigateToPage(
            context,
            () => ChatsScreen(
                  user: widget.user,
                ));
      },
      child: StreamBuilder(
        stream: APIs.getLastMessage(widget.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          final data = snapshot.data?.docs;
          final list = data!.map((e) => Messages.fromJson(e.data())).toList();
          if (list.isNotEmpty) message = list[0];
          return Column(children: [
            ListTile(
              key: UniqueKey(),
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.avatar),
                    radius: 30,
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: SizedBox(
                        height: 15,
                        width: 15,
                        child: StreamBuilder(
                          stream: APIs.getUserInfo(widget.user),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.docs;
                            final list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];
                            return Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: list.isNotEmpty
                                    ? list[0].isOnline
                                        ? colorText
                                        : null
                                    : null,
                              ),
                            );
                          },
                        ),
                      ))
                ],
              ),
              title: Text(
                widget.user.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: message != null &&
                          message!.read.isEmpty &&
                          message!.fromId != APIs.user.uid
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Row(
                children: [
                  if (message != null && message!.type == Type.image)
                    Row(children: [
                      Icon(
                        message != null &&
                                message!.read.isEmpty &&
                                message!.fromId != APIs.user.uid
                            ? Icons.image_rounded
                            : Icons.image_outlined,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Image",
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: message != null &&
                                  message!.read.isEmpty &&
                                  message!.fromId != APIs.user.uid
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      )
                    ])
                  else
                    Text(
                      message != null ? message!.msg : widget.user.about,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: message != null &&
                                message!.read.isEmpty &&
                                message!.fromId != APIs.user.uid
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                ],
              ),
              trailing: message == null
                  ? null
                  : message!.read.isEmpty && message!.fromId != APIs.user.uid
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: colorText,
                          ),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(
                            context: context,
                            time: message!.sent,
                          ),
                          style: TextStyle(
                            fontWeight: message!.read.isEmpty &&
                                    message!.fromId != APIs.user.uid
                                ? FontWeight.bold
                                : FontWeight.w100,
                          ),
                        ),
            ),
            const Divider(
              height: 0,
              indent: 80,
              thickness: 1,
              endIndent: 15,
            )
          ]);
        },
      ),
    );
  }
}

class ChatUserCardItem extends StatefulWidget {
  const ChatUserCardItem({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatUserCardItem> createState() => _ChatUserCardStateItem();
}

class _ChatUserCardStateItem extends State<ChatUserCardItem> {
  Messages? message;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: APIs.getLastMessage(widget.user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        final data = snapshot.data?.docs;
        final list = data!.map((e) => Messages.fromJson(e.data())).toList();
        if (list.isNotEmpty) message = list[0];
        return Column(
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    navigateToPage(
                        context,
                        () => ChatsScreen(
                              user: widget.user,
                            ));
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.avatar),
                    radius: 30,
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: StreamBuilder(
                        stream: APIs.getUserInfo(widget.user),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.docs;
                          final list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];
                          return Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: list.isNotEmpty
                                  ? list[0].isOnline
                                      ? colorText
                                      : null
                                  : null,
                            ),
                          );
                        },
                      ),
                    ))
              ],
            ),
            Text(widget.user.name)
          ],
        );
      },
    );
  }
}
