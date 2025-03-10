import 'package:arkes_chat_app/main.dart';
import 'package:arkes_chat_app/screens/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Permission not granted');
    }
  }

  final firebaseFirestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> uploadFcmToken() async {
    try {
      await FirebaseMessaging.instance.getToken().then((token) async {
        print('getToken :: ${token}');
        await firebaseFirestore
            .collection('users')
            .doc(_currentUser!.uid)
            .update({'notificationToken': token});
      });
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        print('onTokenRefresh :: ${token}');
        await firebaseFirestore
            .collection('users')
            .doc(_currentUser!.uid)
            .update({'notificationToken': token});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          print("🔔 Notification clicked with payload: ${response.payload}");
          _handleNotificationClick(response.payload!);
        }
      },
    );
    //  Xử lý khi app mở từ thông báo (app bị đóng hoàn toàn)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print(
          "🔔 App opened from terminated state with message: ${message.data}",
        );
        _handleNotificationClick(jsonEncode(message.data));
      }
    });

    //  Xử lý khi app chạy nền và người dùng nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🔔 App opened from background with message: ${message.data}");
      _handleNotificationClick(jsonEncode(message.data));
    });
  }

  void _handleNotificationClick(String payload) {
    Map<String, dynamic> data = jsonDecode(payload);
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              userName:
                  data['username'], // userName của người khác(trường hợp này là người dùng hiện tại) username của currentId
              imageUrl:
                  data['imgUrl'], // tưogn tự userName, imageUrl của currentId
              chatId: data['chatId'], //id đoạn chat
              participantId:
                  data['participantId'], // người dùng nhận (ở đây là id của currentId)
              tokenNotificationParticipant: data['token'],
              currentUserName: data['currentUsername'], //
            ),
      ),
    );
  }

  showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Chanel Description',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_notification',
        );

    int notificationId = 1;
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  Future<bool> pushNotification({
    required String title,
    required String body,
    required String token,
    required String receiverId,
    required String chatId,
    required String currentId,
    required String userName,
    required String imgUrl,
    required String userToken,
    required String receiverUsername,
  }) async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(receiverId)
            .get();

    if (userDoc.exists && userDoc.data()!.containsKey('notificationToken')) {
      print('Bắt đầu gửi thông báo');

      // 🔹 **Tải Service Account JSON từ assets**
      final serviceAccountJson = await rootBundle.loadString(
        "assets/service_account.json",
      );

      final serviceAccount = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );

      // 🔹 **Xác thực OAuth 2.0**
      final client = await clientViaServiceAccount(serviceAccount, [
        'https://www.googleapis.com/auth/cloud-platform',
      ]);

      final url = Uri.parse(
        "https://fcm.googleapis.com/v1/projects/arkes-chat-app/messages:send",
      );

      // 🔹 **Cấu trúc thông báo đúng chuẩn FCM V1**
      final payload = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Mở app khi click
            },
          },
          'data': {
            'chatId': chatId,
            'username': userName,
            'imgUrl': imgUrl,
            'participantId': currentId,
            'token': userToken,
            'currentUsername': receiverUsername,
          },
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${client.credentials.accessToken.data}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send FCM message: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } else {
      print('❌ Không gửi được thông báo: User đã logout hoặc không có token');
      return false;
    }
  }
}
