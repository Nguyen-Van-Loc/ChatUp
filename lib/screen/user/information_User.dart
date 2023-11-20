import 'dart:io';
import 'dart:typed_data';
import 'package:chatup/Screen/user/image_page.dart';
import 'package:chatup/api/apis.dart';
import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/config/font.dart';
import 'package:chatup/model/chat_user.dart';
import 'package:chatup/widgets/customRadio.dart';
import 'package:chatup/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Information_User extends StatefulWidget {
  const Information_User({super.key, this.user, this.id});

  final String? id;
  final ChatUser? user;

  @override
  State<Information_User> createState() => _Information_UserState();
}

class _Information_UserState extends State<Information_User> {
  String title = "";
  Color? color;
  IconData? icon;

  Future<void> checkDocumentExists() async {
    DocumentSnapshot documentSnapshot = await APIs.firestore
        .collection("users")
        .doc(APIs.user.uid)
        .collection("friend")
        .doc(widget.user!.id)
        .get();
    if (documentSnapshot.exists) {
      title = "Remove";
      color = Colors.redAccent;
      icon = Icons.person_remove;
    } else {
      icon = Icons.person_add_alt_1;
      color = colorText;
      title = "Add";
    }
  }

  void removefriend() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete you ${widget.user!.name}"),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
                APIs.firestore
                    .collection("users")
                    .doc(APIs.user.uid)
                    .collection("friend")
                    .doc(widget.user!.id)
                    .delete();
                setState(() {
                  checkDocumentExists();
                });
                EasyLoading.showSuccess("Remove Success");
              },
            ),
          ],
        );
      },
    );
  }

  void addfriend() {
    APIs.firestore
        .collection("users")
        .doc(APIs.user.uid)
        .collection("friend")
        .doc(widget.user!.id)
        .set({
      "avatar": widget.user!.avatar,
      "about": widget.user!.about,
      "name": widget.user!.name,
      "createdAt": DateTime.now(),
      "is_online": widget.user!.isOnline,
      "id": widget.user!.id,
      "lastActive": widget.user!.lastActive,
      "email": widget.user!.email,
      "pushToken": "",
      "background": widget.user!.background,
      "dateOfBirth": widget.user!.dateOfBirth,
      "gender": widget.user!.gender,
    });
    EasyLoading.showSuccess("Add Success");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (APIs.user.uid == widget.id) return;
    checkDocumentExists();
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<getUser>(context);
    item.fetchData();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          color: const Color(0xffe0e0e0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(
                        APIs.user.uid == widget.id ||
                                APIs.user.uid == widget.user!.id
                            ? item.data[0]["data"]["background"]
                            : widget.user!.background,
                        fit: BoxFit.cover,
                      )),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                  Positioned(
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage(
                                    APIs.user.uid == widget.id ||
                                            APIs.user.uid == widget.user!.id
                                        ? item.data[0]["data"]["avatar"]
                                        : widget.user!.avatar)),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                                APIs.user.uid == widget.id ||
                                        APIs.user.uid == widget.user!.id
                                    ? item.data[0]["data"]["name"]
                                    : widget.user!.name,
                                style: textFontWhite18),
                          ],
                        ),
                      ))
                ],
              ),
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Personal information",
                          style: TextStyle(fontSize: 18),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    text(
                        textTitle: "Gender",
                        textContent: APIs.user.uid == widget.id ||
                                APIs.user.uid == widget.user!.id
                            ? item.data[0]["data"]["gender"]
                            : widget.user!.gender),
                    text(
                        textTitle: "Date of birth",
                        textContent: APIs.user.uid == widget.id ||
                                APIs.user.uid == widget.user!.id
                            ? item.data[0]["data"]["dateOfBirth"]
                            : widget.user!.dateOfBirth),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                        width: 350,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (title == "Remove") {
                              removefriend();
                            } else {
                              APIs.user.uid == widget.id ||
                                      APIs.user.uid == widget.user!.id
                                  ? navigateToPage(
                                      context,
                                      () => Edit_User(
                                            data: item.data[0],
                                          ))
                                  : addfriend();
                            }
                            if (APIs.user.uid == widget.id) {
                              return;
                            } else {
                              setState(() {
                                checkDocumentExists();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: APIs.user.uid == widget.id ||
                                    APIs.user.uid == widget.user!.id
                                ? Color(0xffe0e0e0)
                                : color,
                            shadowColor: Colors.transparent,
                          ),
                          label: Text(
                            APIs.user.uid == widget.id ||
                                    APIs.user.uid == widget.user!.id
                                ? "Edit"
                                : title,
                            style: TextStyle(
                                color: APIs.user.uid == widget.id ||
                                        APIs.user.uid == widget.user!.id
                                    ? Colors.black
                                    : Colors.white),
                          ),
                          icon: Icon(
                            APIs.user.uid == widget.id ||
                                    APIs.user.uid == widget.user!.id
                                ? Icons.mode_edit_outline_outlined
                                : icon,
                            color: APIs.user.uid == widget.id ||
                                    APIs.user.uid == widget.user!.id
                                ? Colors.black
                                : Colors.white,
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget text({String? textTitle, String? textContent}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 400,
            child: Row(
              children: [
                Expanded(child: Text(textTitle!, style: textFont15)),
                Expanded(
                  child: Text(textContent!, style: textFont15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(
            height: 0,
            thickness: 1,
          ),
        ],
      ),
    );
  }
}

class Edit_User extends StatefulWidget {
  const Edit_User({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Edit_User> createState() => _Edit_UserState();
}

class _Edit_UserState extends State<Edit_User> {
  bool check = false;
  final nameController = TextEditingController();
  final dateControler = TextEditingController();
  int _value = 1;
  File? imageCamera;
  Uint8List? imageGallery;
  String? avatar;
  String gender = "";

  void addDate() async {
    var datePicked = await DatePicker.showSimpleDatePicker(context,
        firstDate: DateTime(1900),
        lastDate: DateTime(2090),
        dateFormat: "dd-" "thg" "MM-yyyy",
        locale: DateTimePickerLocale.en_us,
        looping: true);
    String formattedDate = DateFormat("dd/MM/yyyy").format(datePicked!);
    dateControler.text = formattedDate;
  }

  addEditUser() async {
    EasyLoading.show(status: "loading...");
    if (_value == 1) {
      gender = "Male";
    } else {
      gender = "Female";
    }
    if (imageCamera != null && imageGallery != null) await uploadAvatar();
    APIs.firestore.collection("users").doc(widget.data["data"]["id"]).update({
      "updateAt": DateTime.now(),
      "avatar": avatar,
      "dateOfBirth": dateControler.text,
      "gender": gender,
      "name": nameController.text
    });
    EasyLoading.dismiss();
    EasyLoading.showSuccess("Update successful");
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
  }

  pickImageCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          imageCamera = File(image.path);
          imageGallery = null;
        });
      }
    } catch (e) {
      EasyLoading.showError("$e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = widget.data["data"]["name"];
    dateControler.text = widget.data["data"]["dateOfBirth"];
    if (widget.data["data"]["gender"] == "Male") {
      _value = 1;
    } else {
      _value = 2;
    }
    avatar = widget.data["data"]["avatar"];
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
  }

  Future<void> uploadAvatar() async {
    User? user = APIs.auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      Reference storageRef =
          APIs.storage.ref().child('images/$userId/logo.png');
      if (imageGallery != null) {
        File imageGalleryFile = await uint8ListToFile(imageGallery!);
        await storageRef.putFile(imageGalleryFile);
      }
      if (imageCamera != null) await storageRef.putFile(imageCamera!);
      String downloadURL = await storageRef.getDownloadURL();
      setState(() {
        avatar = downloadURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffececec),
        appBar: AppBar(
          title: const Text(
            "Edit information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 70,
                          child: Stack(
                            children: [
                              InkWell(
                                  onTap: () async {
                                    showButtonShet(
                                      context: context,
                                      ontapCamera: () {
                                        Navigator.pop(context);
                                        pickImageCamera();
                                      },
                                      ontapImage: () async {
                                        Navigator.pop(context);
                                        final image = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ImagePickPage(
                                                      multiple: false),
                                            ));
                                        if (image == null) return;
                                        setState(() {
                                          imageGallery = image;
                                          imageCamera = null;
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: imageCamera == null &&
                                                  imageGallery == null
                                              ? Colors.transparent
                                              : Colors.grey.withOpacity(.7),
                                        ),
                                        image: imageCamera != null ||
                                                imageGallery != null
                                            ? DecorationImage(
                                                fit: BoxFit.cover,
                                                image: imageGallery != null
                                                    ? MemoryImage(imageGallery!)
                                                        as ImageProvider
                                                    : FileImage(imageCamera!))
                                            : DecorationImage(
                                                image: NetworkImage(widget
                                                    .data["data"]["avatar"]),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      child: const SizedBox(
                                        height: 30,
                                        width: 30,
                                      ))),
                              const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CameraIconWidget())
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 130,
                          child: Column(
                            children: [
                              TextField(
                                onChanged: (text) {
                                  setState(() {});
                                },
                                controller: nameController,
                                keyboardType: TextInputType.name,
                                style: const TextStyle(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: "Username",
                                  suffixIcon: nameController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              nameController.clear();
                                            });
                                          },
                                        )
                                      : const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.black,
                                        ),
                                  border: const UnderlineInputBorder(),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    InkWell(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          addDate();
                                        },
                                        child: TextField(
                                          enabled: false,
                                          style: const TextStyle(
                                              color: Colors.black),
                                          controller: dateControler,
                                          decoration: const InputDecoration(
                                              hintText: "dd/mm/yyyy",
                                              suffixIcon: Icon(
                                                Icons.edit_outlined,
                                                color: Colors.black,
                                              )),
                                        )),
                                    const Divider(
                                      height: 0,
                                      thickness: 1,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  CustomRadio<int>(
                                    value: 1,
                                    groupValue: _value,
                                    title: const Text('Male'),
                                    onChanged: (value) =>
                                        setState(() => _value = value!),
                                  ),
                                  CustomRadio<int>(
                                    value: 2,
                                    groupValue: _value,
                                    title: const Text('Female'),
                                    onChanged: (value) =>
                                        setState(() => _value = value!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 25),
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: ElevatedButton(
                            onPressed: nameController.text.isNotEmpty
                                ? () {
                                    addEditUser();
                                  }
                                : null,
                            child: const Text(
                              "Save",
                              style: TextStyle(fontSize: 18),
                            )))
                  ],
                )),
          ),
        ));
  }
}

class CameraIconWidget extends StatefulWidget {
  const CameraIconWidget({super.key});

  @override
  _CameraIconWidgetState createState() => _CameraIconWidgetState();
}

class _CameraIconWidgetState extends State<CameraIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(
      begin: 10.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: Colors.grey)),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value / 10.0,
                child: const SizedBox(
                  width: 10.0,
                  height: 10.0,
                  child: Icon(
                    Icons.add_a_photo,
                    size: 5.0,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
