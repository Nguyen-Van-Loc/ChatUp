import 'dart:io';

import 'package:chatup/Screen/user/changePassword.dart';
import 'package:chatup/Screen/user/image_page.dart';
import 'package:chatup/Screen/user/information_User.dart';
import 'package:chatup/Screen/user/showImage.dart';
import 'package:chatup/api/apis.dart';
import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SelectUser extends StatefulWidget {
  const SelectUser({super.key});

  @override
  State<SelectUser> createState() => _SelectUserState();
}

class _SelectUserState extends State<SelectUser> {
  File? avatarCamera;
  File? avataGallery;
  File? backroundCamera;
  File? backroundGallery;
  String? avatar;
  String? backround;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final item = Provider.of<getUser>(context, listen: false);
    item.fetchData();
  }
  Future<bool>checkGoogleSignIn() async {
    bool isGoogleSignIn =APIs.user.providerData.any((info) => info.providerId == 'google.com');
    if (isGoogleSignIn) {
      return true;
    } else {
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    final item = Provider.of<getUser>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.data[0]["data"]["name"],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buttonNext(
              text: "Information",
              onTap: () =>
                  navigateToPage(context, () => Information_User(id: item.data[0]["data"]["id"],)),
            ),
            buttonNext(
              text: "Change your avatar",
              onTap: () {
                showButtonShet(
                    context: context,
                    ontapImage: () async {
                      Navigator.pop(context);
                      final image = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImagePickPage(multiple: false),
                          ));
                      if (image == null) return;
                      File imageGalleryFile = await uint8ListToFile(image);
                      XFile imageGa = XFile(imageGalleryFile.path);
                      final cropped = await Imagehelper().cropBackRound(
                          file: imageGa, cropStyle: CropStyle.circle);
                      if (cropped != null) {
                        setState(() {
                          avataGallery = File(cropped.path);
                        });
                      }
                      updateAvatar();
                    },
                    ontapCamera: () async {
                      Navigator.pop(context);
                      final file = await Imagehelper().pickImageCamera();
                      if (file.toString().isNotEmpty) {
                        final cropped = await Imagehelper().cropBackRound(
                            file: file!, cropStyle: CropStyle.rectangle);
                        if (cropped != null) {
                          setState(() {
                            avatarCamera = File(cropped.path);
                          });
                        }
                      }
                      updateAvatar();
                    },
                    ontapShowImage: () {
                      Navigator.pop(context);
                      navigateToPage(
                          context,
                              () => ShowImage(
                            linkImage: item.data[0]["data"]["avatar"],
                          ));
                    });
              },
            ),
            buttonNext(
              text: "Change wallpaper",
              onTap: () {
                showButtonShetBackround(
                    context: context,
                    ontapImage: () async {
                      Navigator.pop(context);
                      final image = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImagePickPage( multiple: false),
                          ));
                      if (image == null) return;
                      File imageGalleryFile = await uint8ListToFile(image);
                      XFile imageGa = XFile(imageGalleryFile.path);
                      final cropped = await Imagehelper().cropBackRound(
                          file: imageGa, cropStyle: CropStyle.rectangle);
                      if (cropped != null) {
                        setState(() {
                          backroundGallery = File(cropped.path);
                        });
                      }
                      updateBackround();
                    },
                    ontapCamera: () async {
                      Navigator.pop(context);
                      final file = await Imagehelper().pickImageCamera();
                      if (file.toString().isNotEmpty) {
                        final cropped = await Imagehelper().cropBackRound(
                            file: file!, cropStyle: CropStyle.rectangle);
                        if (cropped != null) {
                          setState(() {
                            backroundCamera = File(cropped.path);
                          });
                        }
                      }
                      updateBackround();
                    },
                    ontapShowImage: () {
                      Navigator.pop(context);
                      navigateToPage(
                          context,
                              () => ShowImage(
                            linkImage: item.data[0]["data"]
                            ["backgroundImage"],
                          ));
                    });
              },
            ),
            buttonNext(
              text: "Update your introduction section",
              onTap: () {
                navigateToPage(
                    context,
                        () => Introduction(
                      data: item.data[0],
                    ));
              },
            ),
            buttonNext(
              text: "Change Password",
              onTap: (){
                navigateToPage(context, () => const VerifyAccount());
              }
            )
          ],
        ),
      ),
    );
  }
  updateAvatar() async {
    EasyLoading.show(status: "loading...");
    await uploadAvatar();
    final item = Provider.of<getUser>(context, listen: false);
    await item.fetchData();
    APIs.firestore.collection("users").doc(item.data[0]["key"]).update({
      "updateAt": DateTime.now(),
      "avatar": avatar,
    });
    EasyLoading.dismiss();
    EasyLoading.showSuccess("Update successful");
  }

  updateBackround() async {
    EasyLoading.show(status: "loading...");
    await uploadBackround();
    final item = Provider.of<getUser>(context, listen: false);
    await item.fetchData();
    APIs.firestore.collection("users").doc(item.data[0]["key"]).update({
      "updateAt": DateTime.now(),
      "backgroundImage": backround,
    });
    EasyLoading.dismiss();
    EasyLoading.showSuccess("Update successful");
  }

  Future<void> uploadAvatar() async {
    User? user = APIs.auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      Reference storageRef =
      APIs.storage.ref().child('images/$userId/logo.png');
      if (avatarCamera != null) await storageRef.putFile(avatarCamera!);
      if (avataGallery != null) await storageRef.putFile(avataGallery!);
      String downloadURL = await storageRef.getDownloadURL();
      setState(() {
        avatar = downloadURL;
      });
    }
  }

  Future<void> uploadBackround() async {
    User? user = APIs.auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      Reference storageRef =
      APIs.storage.ref().child('images/$userId/logoBackround.png');
      if (backroundCamera != null) await storageRef.putFile(backroundCamera!);
      if (backroundGallery != null) await storageRef.putFile(backroundGallery!);
      String downloadURL = await storageRef.getDownloadURL();
      setState(() {
        backround = downloadURL;
      });
    }
  }

  Widget buttonNext({String? text, Function()? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            child: Text(
              text!,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        const Divider(
          height: 0,
          indent: 20,
          thickness: 1,
          endIndent: 20,
        )
      ],
    );
  }
}

class Introduction extends StatefulWidget {
  const Introduction({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  final controller = TextEditingController();

  void updateAbout() {
    APIs.firestore
        .collection("users")
        .doc(widget.data["data"]["id"])
        .update({"about": controller.text});
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.text = widget.data["data"]["about"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffececec),
      appBar: AppBar(
        title: Text(
          "Edit introduction",
          style: textFont15,
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                elevation: MaterialStateProperty.all(0),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                foregroundColor: MaterialStateProperty.all(
                    controller.text.trim().isEmpty
                        ? Colors.white54
                        : Colors.white)),
            onPressed: controller.text.trim().isEmpty
                ? null
                : () {
              updateAbout();
              EasyLoading.showSuccess("Update successful");
            },
            child: const Text("Save"),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                TextField(
                  controller: controller,
                  maxLines: 6,
                  style: textFont15,
                  maxLength: 100,
                  onChanged: (value) {
                    setState(() {});
                    if (controller.text.split('\n').length > 6) {
                      controller.text = controller.text.replaceAll('\n', '');
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(
                          offset: controller.text.length,
                        ),
                      );
                      EasyLoading.showError(
                          "Exceeded allowed number of newline characters");
                    }
                  },
                  decoration: const InputDecoration(
                      counterStyle: TextStyle(fontSize: 15),
                      hintText: "Add a self-introduction section",
                      contentPadding: EdgeInsets.all(20),
                      border: UnderlineInputBorder(borderSide: BorderSide.none)),
                ),
                if (controller.text.trim().isNotEmpty)
                  Positioned(
                    top: 5,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                      },
                    ),
                  ),
              ],
            ),
          )),
    );
  }
}
