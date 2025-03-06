import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
      payload: 'Not present',
    );
  }

  Future<bool> pushNotification({
    required String title,
    required String body,
    required String token,
    required String receiverId,
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

      print('Nội dung JSON: $serviceAccountJson');
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
          'apns': {
            'payload': {
              'aps': {'sound': 'default'},
            },
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
      return false;
      print('❌ Không gửi được thông báo: User đã logout hoặc không có token');
    }
  }
}
