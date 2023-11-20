// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chatup/Screen/user/image_page.dart';
import 'package:chatup/Screen/user/information_User.dart';
import 'package:chatup/api/apis.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/model/chat_user.dart';
import 'package:chatup/model/messages.dart';
import 'package:chatup/utils/utils.dart';
import 'package:chatup/widgets/messager_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _controller = TextEditingController();
  bool showEmoji = false;
  FocusNode focusNode = FocusNode();
  bool isEmojiVisible = false;
  bool isKeyboardVisible = false;
  bool hasDataCheckExecuted = false,
      _isUploading = false;
  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((bool isKeyboardVisible) {
      if (mounted) {
        setState(() {
          this.isKeyboardVisible = isKeyboardVisible;
        });

        if (isKeyboardVisible && isEmojiVisible) {
          setState(() {
            isEmojiVisible = false;
          });
        }
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 248, 255),
      appBar: AppBar(
        leadingWidth: 50,
        titleSpacing: 0,
        title: Row(
          children: [
            InkWell(
              onTap: (){
                navigateToPage(context, () => Information_User(user: widget.user,));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.user.avatar),
                radius: 25,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(widget.user.name),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: APIs.getAllMessages(widget.user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                final data = snapshot.data?.docs ?? [];
                final List<Messages> list =
                data.map((e) => Messages.fromJson(e.data())).toList();
                if (snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: list.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return MessagerCard(
                        message:list[index],
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      "Say hi 👋 ",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
              },
            ),
          ),
          if (_isUploading)
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          const SizedBox(height: 10,),
          _chatInput(),
          Offstage(
            offstage: !isEmojiVisible,
            child: showEmojiPicker(),
          ),
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildIconButton(Icons.emoji_emotions, () async {
            if (isEmojiVisible) {
              focusNode.requestFocus();
            } else if (isKeyboardVisible) {
              await SystemChannels.textInput.invokeMethod('TextInput.hide');
              await Future.delayed(const Duration(milliseconds: 90));
            }
            if (isKeyboardVisible) {
              FocusScope.of(context).unfocus();
            }
            setState(() {
              isEmojiVisible = !isEmojiVisible;
            });
          }),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Type Something...",
              ),
            ),
          ),
          _buildIconButton(Icons.image, () async {
            final image = await Navigator.push<List<Uint8List>>(
              context,
              MaterialPageRoute(
                builder: (context) => const ImagePickPage(multiple: true),
              ),
            );
            if (image == null) return;
            for (var i in image) {
              File imageGalleryFile = await uint8ListToFile(i);
              XFile imageGa = XFile(imageGalleryFile.path);
              await APIs.sendChatImage(widget.user, File(imageGa.path),context);
            }
          }),
          _buildIconButton(Icons.camera_alt, () async {
            final file = await Imagehelper().pickImageCamera();
            if (file
                .toString()
                .isNotEmpty) {
              final cropped = await Imagehelper()
                  .cropBackRound(file: file!, cropStyle: CropStyle.rectangle);
              if (cropped != null) {
                setState(() => _isUploading = true);
                APIs.sendChatImage(widget.user, File(cropped.path),context);
                setState(() => _isUploading = false);
              } else {
                EasyLoading.showError("Cancelled");
              }
            }
          }),
          _buildIconButton(Icons.send, () {
            if (_controller.text.isNotEmpty) {
              APIs.sendMessager(widget.user, _controller.text, Type.text,context);
              _controller.text = "";
            }
          }),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return MaterialButton(
      minWidth: 0,
      padding: const EdgeInsets.all(5),
      shape: const CircleBorder(),
      onPressed: onPressed,
      child: Icon(
        icon,
        color: colorText,
      ),
    );
  }

  Widget showEmojiPicker() {
    return SizedBox(
      height: 313,
      child: EmojiPicker(
        textEditingController: _controller,
        config: Config(
          bgColor: const Color.fromARGB(255, 234, 248, 255),
          columns: 8,
          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
        ),
      ),
    );
  }
}
