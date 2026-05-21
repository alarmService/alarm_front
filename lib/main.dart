import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart' as alarm_pkg;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'back/firebase_options.dart';
import 'pages/title.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 백그라운드에서 알람 즉시 울림
  await alarm_pkg.Alarm.set(
    alarmSettings: alarm_pkg.AlarmSettings(
      id: 1,
      dateTime: DateTime.now().add(const Duration(seconds: 1)),
      assetAudioPath: 'assets/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      notificationSettings: const alarm_pkg.NotificationSettings(
        title: '알람',
        body: 'A가 알람을 보냈습니다.',
        stopButton: '알람 중지',
      ),
    ),
  );
}

Future<void> main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // alarm 패키지 초기화
  await alarm_pkg.Alarm.init();

  // 백그라운드 FCM 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Simple Alarm'),
    );
  }
}
