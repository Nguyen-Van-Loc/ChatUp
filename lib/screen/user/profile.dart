import 'dart:io';

import 'package:chatup/Screen/user/image_page.dart';
import 'package:chatup/api/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:chatup/Screen/user/selectUser.dart';
import 'package:chatup/Screen/user/showImage.dart';
import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? avatarCamera;
  File? avataGallery;
  File? backroundCamera;
  File? backroundGallery;
  String? avatar;
  String? backround;

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<getUser>(context);
    item.fetchData();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color(0xffF1F2F6),
          child:  Column(
              children: [
                Stack(alignment: Alignment.center, children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                            onTap: () {
                              showButtonShetBackround(context: context,ontapShowImage:  () {
                                Navigator.pop(context);
                                navigateToPage(
                                    context,
                                        () => ShowImage(
                                      linkImage: item.data[0]["data"]
                                      ["background"],
                                    ));
                              },ontapCamera:  () async {
                                Navigator.pop(context);
                                final file =
                                await Imagehelper().pickImageCamera();
                                if (file.toString().isNotEmpty) {
                                  final cropped = await Imagehelper()
                                      .cropBackRound(
                                      file: file!,
                                      cropStyle: CropStyle.rectangle);
                                  if (cropped != null) {
                                    setState(() {
                                      backroundCamera = File(cropped.path);
                                      updateBackround();
                                    });
                                  }else{
                                    EasyLoading.showError("Cancelled");
                                  }
                                }
                              },ontapImage:  () async {
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
                                    file: imageGa, cropStyle: CropStyle.rectangle);
                                if (cropped != null) {
                                  setState(() {
                                    backroundGallery = File(cropped.path);
                                  });
                                  updateBackround();
                                }else{
                                  EasyLoading.showError("Cancelled");
                                }
                              });
                            },
                            child:Image.network(
                              "${item.data[0]["data"]["background"]}",
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                      const SizedBox(
                        height: 70,
                      ),
                      Text(
                        item.data[0]["data"]["name"],
                        style: const TextStyle(fontSize: 22),
                      ),
                      item.data[0]["data"]["about"].toString().isEmpty
                          ? TextButton.icon(
                        onPressed: () {
                          navigateToPage(context,
                                  () => Introduction(data: item.data[0]));
                        },
                        label: const Text(
                          "Update your introduction !",
                          style: TextStyle(fontSize: 17),
                        ),
                        icon:
                        const Icon(Icons.mode_edit_outline_outlined),
                      )
                          : Text(
                        item.data[0]["data"]["about"],
                        style: const TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                          IconButton(
                              onPressed: () {
                                navigateToPage(
                                    context, () => const SelectUser());
                              },
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ))
                        ],
                      ),
                    ),
                  ),
                   InkWell(
                      onTap: () {
                        showButtonShet(context:  context,ontapShowImage:  () {
                          Navigator.pop(context);
                          navigateToPage(
                              context,
                                  () => ShowImage(
                                linkImage: item.data[0]["data"]["avatar"],
                              ));
                        },ontapCamera:  () async {
                          Navigator.pop(context);
                          final file = await Imagehelper().pickImageCamera();
                          if (file.toString().isNotEmpty) {
                            final cropped = await Imagehelper().cropAvatar(
                                file: file!, cropStyle: CropStyle.circle);
                            if (cropped != null) {
                              setState(() {
                                avatarCamera = File(cropped.path);
                              });
                              updateAvatar();
                            }
                            else{
                              EasyLoading.showError("Cancelled");
                            }
                          }

                        },ontapImage:  () async {
                          Navigator.pop(context);
                          final image = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ImagePickPage(multiple: false),
                              ));
                          if (image == null) return;
                          File imageGalleryFile = await uint8ListToFile(image);
                          XFile imageGa = XFile(imageGalleryFile.path);
                          final cropped = await Imagehelper().cropAvatar(
                              file: imageGa, cropStyle: CropStyle.circle);
                          if (cropped != null) {
                            setState(() {
                              avataGallery = File(cropped.path);
                            });
                            updateAvatar();
                          }
                          else{
                            EasyLoading.showError("Cancelled");
                          }

                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 145),
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(90),
                            image: DecorationImage(
                                image: NetworkImage(
                                    item.data[0]["data"]["avatar"]),
                                fit: BoxFit.cover)),
                      ),
                    ),
                ]),
              ],
            ),
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
      "background": backround,
    });
    EasyLoading.dismiss();
    EasyLoading.showSuccess("Update successful");
  }

  Future<void> uploadAvatar() async {
    User? user = APIs.auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      Reference storageRef =
      await APIs.storage.ref().child('images/$userId/logo.png');
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
      await APIs.storage.ref().child('images/$userId/logoBackround.png');
      if (backroundCamera != null) await storageRef.putFile(backroundCamera!);
      if (backroundGallery != null) await storageRef.putFile(backroundGallery!);
      String downloadURL = await storageRef.getDownloadURL();
      setState(() {
        backround = downloadURL;
      });
    }
  }
}
