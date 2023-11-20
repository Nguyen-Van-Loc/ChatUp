// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chatup/auth_Provide/auth_Provide.dart';
import 'package:chatup/model/chat_user.dart';
import 'package:chatup/model/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  static String? token;
  static User get user => auth.currentUser!;
  static ChatUser? me;
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy("sent", descending: true)
        .snapshots();
  }
  static Future<void> sendMessager(
      ChatUser chatUser, String msg, Type type,BuildContext context) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Messages message = Messages(
      toId: chatUser.id,
      msg: msg,
      read: "",
      type: type,
      fromId: user.uid,
      sent: time,
    );
    final ref = firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(context,chatUser, type == Type.text ? msg : 'image'));
  }

  static Future<void> updateMesageReadStatus(Messages messages) async {
    firestore
        .collection("chats/${getConversationID(messages.fromId)}/messages/")
        .doc(messages.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .limit(1)
        .orderBy("sent", descending: true)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser user, File? file,BuildContext context) async {
    final ext = file!.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationID(user.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      if (kDebugMode) {
        print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      }
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessager(user, imageUrl, Type.image, context);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        token = t;
      }
    });
    await firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': token,
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
      }
      if (kDebugMode) {
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: ${message.notification}');
        }
      }
    });
  }
  static Future<void> sendPushNotification(BuildContext context,
      ChatUser chatUser, String msg) async {
    final item =Provider.of<getUser>(context,listen: false);
    item.fetchData();

    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": item.data[0]["data"]["name"],
          "body": msg,
          "android_channel_id": "chats"
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAEgLoUWQ:APA91bHpfu6UYWp13dD1DUaO3Vvjih34rYIZaAUhKLQeNEfVa4W5o3x8iKXt8j5GUdn5g9bmfHgVhfFywsuA5ZmyTerKMALy2VuqRq3G6s25F9DLZIrqIWLNcM5Jh1ZrZmKbNBgKaixK'
          },
          body: jsonEncode(body));
      if (kDebugMode) {
        print('Response status: ${res.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${res.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('\nsendPushNotificationE: $e');
      }
    }
  }
  static Future<void> deleteMessage(Messages message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }
  static Future<void> updateMessage(Messages message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
class NotificationServices {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if (kDebugMode) {
        print(event.notification!.title);
        print(event.notification!.body);
        print(event.data["key"]);
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, event);
        showNotification(event);
      } else {
        showNotification(event);
      }
    });
  }

  void initLocalNotification(BuildContext context, RemoteMessage message) async {
    var androidInit = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var settings = InitializationSettings(android: androidInit);
    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        handleMessager(context, message);
      },
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      "Chats",
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: "your channel description",
      importance: Importance.high,
      priority: Priority.high,
      ticker: "ticker",
      icon: "@mipmap/ic_launcher",
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero, () {
      _notificationsPlugin.show(
        1,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  void requestNotificationServices() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    } else {
    }
  }

  void setUpInteractMessenger(BuildContext context) async {
    RemoteMessage? initialMessenger = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessenger != null) {
      handleMessager(context, initialMessenger);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessager(context, event);
    });
  }

  void handleMessager(BuildContext context, RemoteMessage message) {
    if (message.data["id"] == 1) {

    }
  }

}


