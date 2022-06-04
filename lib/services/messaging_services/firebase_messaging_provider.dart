import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:peaman/peaman.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FirebaseMessagingProvider {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  // initialize and save device info of user to firestore
  static Future<void> initialize({
    required final String uid,
  }) async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    try {
      final _deviceInfo = DeviceInfoPlugin();
      String? _docId;
      String? _platForm;

      var file;
      var bigPictureStyleInformation;
      List<IOSNotificationAttachment> newattachments=[];
      String? avatar;

      if (Platform.isAndroid) {
        final _androidInfo = await _deviceInfo.androidInfo;

        if (_androidInfo.androidId.isNotEmpty) {
          _docId = _androidInfo.androidId;
        }
        _platForm = 'android';
      } else if (Platform.isIOS) {
        final _iosInfo = await _deviceInfo.iosInfo;

        if (_iosInfo.identifierForVendor.isNotEmpty) {
          _docId = _iosInfo.identifierForVendor;
        }
        _platForm = 'ios';
      }

      // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      //   print("onmessage.listen ontap");
      //
      //   RemoteNotification? notification = message.notification;
      //   // AndroidNotification? android = message.notification?.android;
      //   AppleNotification? appleNot = message.notification?.apple;
      //   avatar = appleNot!.imageUrl;
      //
      //   print(message.data);
      //   print("getinitiaonMessage.listen ontap");
      //
      //   if (Platform.isAndroid) {
      //
      //   } else if (Platform.isIOS) {
      //     if (avatar != null && avatar!.isNotEmpty) {
      //       final extension = p.extension(avatar!);
      //       final picturePath = await saveImage(Image.network(avatar!),extension);
      //       newattachments.add(IOSNotificationAttachment('${picturePath}'));
      //     }
      //   }
      //
      //   if (notification != null) {
      //     print("message from ${message.notification!.body}");
      //     print("message from ${message.notification!.title}");
      //     print("message from ${message.data}");
      //
      //     var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
      //         'your_channel_id', 'your channel name',
      //         channelDescription: 'your channel description',
      //         icon: 'logo_blue',
      //         color: Colors.indigo,
      //         playSound: false,
      //         enableVibration: false,
      //         importance: Importance.high,
      //         styleInformation: avatar != null && avatar!.isNotEmpty
      //             ? bigPictureStyleInformation
      //             : null,
      //         largeIcon: avatar != null && avatar!.isNotEmpty ? file : null,
      //         priority: Priority.high);
      //
      //     // @formatter:on
      //     var platformChannelSpecificsIos =
      //     new IOSNotificationDetails(
      //         presentSound: true,
      //         presentAlert: true,
      //         presentBadge: true,
      //         attachments: newattachments
      //     );
      //     var platformChannelSpecifics = new NotificationDetails(
      //         android: platformChannelSpecificsAndroid,
      //         iOS: platformChannelSpecificsIos);
      //
      //     flutterLocalNotificationsPlugin.show(
      //         notification.hashCode,
      //         notification.title,
      //         notification.body,
      //         platformChannelSpecifics,
      //         payload: json.encode(message),
      //     );
      //   }
      // });

      final _token = await _firebaseMessaging.getToken();
      final _deviceRef = PeamanReferenceHelper.devicesCol(uid: uid).doc(_docId);
      await _deviceRef.set({
        'id': _deviceRef.id,
        'token': _token,
        'platform': _platForm,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      print('Success: Initializing firebase messaging');
    } catch (e) {
      print(e);
      print('Error!!!: Initializing firebase messaging');
    }
  }

  // on listen message from firebase messaging service
  static Future<void> onlistenMessage({
    required final Future<void> Function(RemoteMessage) onMessage,
  }) async {
    try {
      final _initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

      if (_initialMessage != null) {
        onMessage(_initialMessage);
      }
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      var file;
      var bigPictureStyleInformation;
      List<IOSNotificationAttachment> newattachments=[];
      String? avatar;

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print("onmessage.listen ontap");

        RemoteNotification? notification = message.notification;
        // AndroidNotification? android = message.notification?.android;
        AppleNotification? appleNot = message.notification?.apple;
        avatar = appleNot!.imageUrl;

        print(message.data);
        print("getinitiaonMessage.listen ontap");

        if (Platform.isAndroid) {

        } else if (Platform.isIOS) {
          if (avatar != null && avatar!.isNotEmpty) {
            final extension = p.extension(avatar!);
            final picturePath = await saveImage(Image.network(avatar!),extension);
            newattachments.add(IOSNotificationAttachment('${picturePath}'));
          }
        }

        if (notification != null) {
          print("message from ${message.notification!.body}");
          print("message from ${message.notification!.title}");
          print("message from ${message.data}");

          var platformChannelSpecificsAndroid = new AndroidNotificationDetails(
              'your_channel_id', 'your channel name',
              channelDescription: 'your channel description',
              icon: 'logo_blue',
              color: Colors.indigo,
              playSound: false,
              enableVibration: false,
              importance: Importance.high,
              styleInformation: avatar != null && avatar!.isNotEmpty
                  ? bigPictureStyleInformation
                  : null,
              largeIcon: avatar != null && avatar!.isNotEmpty ? file : null,
              priority: Priority.high);

          // @formatter:on
          var platformChannelSpecificsIos =
          new IOSNotificationDetails(
              presentSound: true,
              presentAlert: true,
              presentBadge: true,
              attachments: newattachments
          );
          var platformChannelSpecifics = new NotificationDetails(
              android: platformChannelSpecificsAndroid,
              iOS: platformChannelSpecificsIos);

          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            platformChannelSpecifics,
            payload: json.encode(message),
          );
        }
      });
    } catch (e) {
      print(e);
      print('Error!!!: Receiving message from notification');
    }
  }


  // on recieved messages from firebase messaging service
  static Future<void> onReceivedMessage({
    required final Future<void> Function(RemoteMessage) onMessage,
  }) async {
    try {
      final _initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (_initialMessage != null) {
        onMessage(_initialMessage);
      }

      FirebaseMessaging.onMessageOpenedApp.listen(onMessage);
    } catch (e) {
      print(e);
      print('Error!!!: Receiving message from notification');
    }
  }

  // reset and delete device info of user from firestore
  static Future<void> reset({
    required final String uid,
  }) async {
    try {
      final _deviceInfo = DeviceInfoPlugin();
      final _androidInfo = await _deviceInfo.androidInfo;

      final _deviceRef = PeamanReferenceHelper.devicesCol(uid: uid)
          .doc(_androidInfo.androidId);

      await _deviceRef.delete();
      print('Success: Resetting firebase messaging');
    } catch (e) {
      print(e);
      print('Error!!!: Resetting firebase messaging');
    }
  }
}

Future<String> saveImage(Image image,String fileExtention) {
  final completer = Completer<String>();

  image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) async {
        final byteData =
        await imageInfo.image.toByteData(format: ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        final fileName = pngBytes.hashCode;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName$fileExtention';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        completer.complete(filePath);
      }));

  return completer.future;
}