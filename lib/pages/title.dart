import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import '../back/alarm_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isAlarmSet = false;
  final AlarmService _alarmService = AlarmService();

  @override
  void initState() {
    super.initState();

    _checkAndRequestPermissions();

    // 앱이 포그라운드(켜져 있는 상태)일 때 메시지 수신 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final alarmSettings = AlarmSettings(
        id: 1,
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        notificationSettings: const NotificationSettings(
          title: '알람',
          body: 'A가 알람을 보냈습니다. (포그라운드)',
          stopButton: '알람 중지',
        ),
      );
      await Alarm.set(alarmSettings: alarmSettings);
      if (mounted) {
        setState(() => _isAlarmSet = true);
      }
    });
  }

  Future<void> _checkAndRequestPermissions() async {
    // 1. 알림 권한 (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    // 2. 정확한 알람 시간 설정 권한 (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    // 3. 다른 앱 위에 표시 (백그라운드에서 화면을 깨우고 알람을 띄울 때 필수)
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
    // 4. 배터리 최적화 무시 (백그라운드에서 FCM 수신 지연 방지 및 알람 보장)
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  // Sender 버튼 동작
  Future<void> _onSenderPressed() async {
    try {
      await _alarmService.sendAlarm();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('A폰: 알람 전송 성공')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('A폰: 알람 전송 실패 - $e')));
      }
    }
  }

  // Receiver 버튼 동작
  Future<void> _onReceiverPressed() async {
    try {
      // B폰은 자신의 FCM 토큰을 서버에 등록해야 A폰으로부터 알람을 받을 수 있습니다.
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _alarmService.registerToken(token);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('B폰: 토큰 등록 성공 (Receiver 준비 완료)')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('B폰: FCM 토큰을 가져오지 못했습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('B폰: 토큰 등록 실패 - $e')));
      }
    }
  }

  // 원격 알람 끄기 버튼 동작
  Future<void> _onStopRemoteAlarmPressed() async {
    try {
      await _alarmService.dismissAlarm();
      // 현재 울리고 있는 로컬 알람도 함께 중지합니다.
      await Alarm.stop(1);
      setState(() => _isAlarmSet = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('원격 알람 끄기 성공')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('원격 알람 끄기 실패 - $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 8,
            ),
            onPressed: _onStopRemoteAlarmPressed,
            child: const Icon(Icons.alarm_off, size: 100), // 가운데 큰 알람 해제 그림 아이콘
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'receiverBtn',
              onPressed: _onReceiverPressed,
              tooltip: 'Receiver (B폰 - 수신 등록)',
              child: const Icon(Icons.inbox), // 수신(받기) 아이콘
            ),
            FloatingActionButton(
              heroTag: 'senderBtn',
              onPressed: _onSenderPressed,
              tooltip: 'Sender (A폰 - 알람 전송)',
              child: const Icon(Icons.send), // 송신(보내기) 아이콘
            ),
          ],
        ),
      ),
    );
  }
}
