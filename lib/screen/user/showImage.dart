import 'package:chatup/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:photo_view/photo_view.dart';

class ShowImage extends StatefulWidget {
  const ShowImage({super.key, required this.linkImage});

  final String linkImage;

  @override
  State<ShowImage> createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  // final FlutterLocalNotificationsPlugin _notificationsPlugin =
  // FlutterLocalNotificationsPlugin();

  // void initLocalNotification(BuildContext context,) async {
  //   var androidInit = const AndroidInitializationSettings("@mipmap/ic_launcher");
  //   var settings = InitializationSettings(android: androidInit);
  //   await _notificationsPlugin.initialize(
  //     settings,
  //     onDidReceiveNotificationResponse: (payload) {
  //     },
  //   );
  // }
  // Future onSelectNotification(String? payload) async {
  //   // Handle notification tap here if needed
  // }
  // void updateNotificationProgress(double progress) {
  //   AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     Random.secure().nextInt(100000).toString(),
  //     "Hi",
  //     importance: Importance.max,
  //   );
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     channel.id,
  //     channel.name,
  //     channelDescription: "your channel description",
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     ticker: "ticker",
  //     icon: "@mipmap/ic_launcher",
  //   );
  //
  //   var platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );
  //   _notificationsPlugin.show(
  //     0,
  //     'Downloading Image',
  //     '$_progress% complete',
  //     platformChannelSpecifics,
  //     payload: 'item x',
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PhotoView(imageProvider: NetworkImage(widget.linkImage)),
        Positioned(
            top: 20,
            left: 10,
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white))),
        Positioned(
            top: 20,
            right: 10,
            child: IconButton(
                onPressed: () {
                  showButtonDowload(
                    context,
                    () {
                      print("ok1");
                    },
                    () {
                      print("ok2");
                    },
                    () {
                      Navigator.pop(context);
                      DowloadImage();
                    },
                  );
                },
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                ))),
      ],
    ));
  }

  DowloadImage() {
    FileDownloader.downloadFile(
      url: widget.linkImage,
      name: "logo.png",
      onProgress: (fileName, progress) {
        setState(() {
        });
        // updateNotificationProgress(progress);
      },
      onDownloadCompleted: (path) {
        setState(() {
          EasyLoading.showSuccess("Saved image $path successfully");
          // _notificationsPlugin.cancel(0);
        });
      },
      onDownloadError: (path) {
        setState(() {
          EasyLoading.showError("Saved image $path failed");
          // _notificationsPlugin.cancel(0);
        });
      },
    );
  }
}
