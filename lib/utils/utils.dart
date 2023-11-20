import 'dart:io';

import 'package:chatup/api/apis.dart';
import 'package:chatup/config/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext context, String content) {
  return ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(content)));
}

Future<File?> pickImage(BuildContext context) async {
  File? image;
  final imagePicker = ImagePicker();
  try {
    final XFile? pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context, e.toString());
    print(e);
  }
  return image;
}

navigateToPage(BuildContext context, Function() function) {
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (context) => function(),
    ),
  );
}

SignUp(
    {required dynamic name,
    required dynamic email,
    required dynamic avatar,
    dynamic imageBr}) {
  APIs.firestore.collection("users").doc(APIs.auth.currentUser!.uid).set({
    "id": APIs.auth.currentUser!.uid,
    "name": name,
    "email": email,
    "created_at": DateTime.now().toString(),
    "avatar": avatar,
    "is_online": false,
    'push_token': "",
    'about': "",
    'dateOfBirth': "dd/mm/yyyy",
    "gender": "Male",
    "background": imageBr,
    "last_active": ''
  });
}

void navigateToPageRe(BuildContext context, Function() function) {
  Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(
        builder: (context) => function(),
      ),
      (route) => false);
}

void loading() async {
  EasyLoading.show(status: "loaidng...");
  await Future.delayed(const Duration(seconds: 3));
  EasyLoading.dismiss();
}

String validateEmail(String txt) {
  if (txt.isEmpty) {
    return "Email cannot be empty";
  }
  final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
  if (!emailRegExp.hasMatch(txt)) {
    return "Email invalidate";
  }
  return "";
}

String validateUsername(String txt) {
  if (txt.isEmpty) {
    return "Username cannot be empty";
  }
  return "";
}

String validatePassword(String txt) {
  if (txt.isEmpty) {
    return "Password cannot be empty";
  }
  if (txt.toString().trim().length < 6) {
    return "Password must not be less than 6 characters";
  }
  return "";
}

String validateRePassword(String txt, String txt1) {
  if (txt.isEmpty) {
    return "Repassword cannot be empty";
  }
  if (txt != txt1) {
    return "Re-enter the password does not match";
  }
  return "";
}

Future<void> showButtonShet(
    {BuildContext? context,
    Function()? ontapShowImage,
    Function()? ontapCamera,
    Function()? ontapImage}) {
  return showModalBottomSheet(
    context: context!,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.only(top: 20, left: 20),
        height: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Avatar",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: ontapShowImage,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.person_alt_circle,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "See representative photo",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
                const Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.grey,
                  indent: 40,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: ontapCamera,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.camera,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Take new photos",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
                const Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.grey,
                  indent: 40,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: ontapImage,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Select a photo on the device",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
                const Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.grey,
                  indent: 40,
                )
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showButtonShetBackround(
    {BuildContext? context,
    Function()? ontapShowImage,
    Function()? ontapCamera,
    Function()? ontapImage}) {
  return showModalBottomSheet(
    context: context!,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.only(top: 20, left: 20),
        height: 270,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cover Image",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: ontapShowImage,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.photo,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "See cover photo",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
                const Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.grey,
                  indent: 40,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: ontapCamera,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.camera,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Take new photos",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
                const Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.grey,
                  indent: 40,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: ontapImage,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Select a photo on the device",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
                const Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.grey,
                  indent: 40,
                )
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showButtonDowload(BuildContext context, Function() ontapCamera,
    Function() ontapImage, Function() onDowloadImage) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.only(top: 20, left: 20),
        height: 230,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: ontapCamera,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.camera,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Take new photos",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: ontapImage,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.photo,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Select a photo on the device",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: onDowloadImage,
                  child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.file_download_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Save Image",
                            style: textFont15,
                          )
                        ],
                      )),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class Imagehelper {
  Imagehelper({ImagePicker? imagePick, ImageCropper? imageCropper})
      : _imagePicker = imagePick ?? ImagePicker(),
        _imageCroppe = imageCropper ?? ImageCropper();
  final ImagePicker _imagePicker;
  final ImageCropper _imageCroppe;

  Future<XFile?> pickImageCamera(
      {ImageSource source = ImageSource.camera, int intquantity = 100}) async {

    return await _imagePicker.pickImage(
        source: source, imageQuality: intquantity);
  }


  Future<CroppedFile?> cropAvatar({
    required XFile file,
    CropStyle cropStyle = CropStyle.rectangle,
  }) async =>
      await _imageCroppe.cropImage(
          cropStyle: cropStyle,
          sourcePath: file.path,
          compressQuality: 100,
          uiSettings: [
            IOSUiSettings(),
            AndroidUiSettings(
                toolbarTitle: "Update Avatar",
                showCropGrid: false,
                lockAspectRatio: false),
          ]);

  Future<CroppedFile?> cropBackRound({
    required XFile file,
    CropStyle cropStyle = CropStyle.rectangle,
  }) async =>
      await _imageCroppe.cropImage(
          cropStyle: cropStyle,
          sourcePath: file.path,
          compressQuality: 100,
          uiSettings: [
            IOSUiSettings(),
            AndroidUiSettings(
                toolbarTitle: "Update Backround",
                showCropGrid: false,
                lockAspectRatio: false),
          ]);
}

Future<File> uint8ListToFile(Uint8List uint8List) async {
  try {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String filePath = '$tempPath/image.jpg';

    File file = File(filePath);
    await file.writeAsBytes(uint8List);

    return file;
  } catch (e) {
    print('Error converting Uint8List to File: $e');
    rethrow;
  }
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
