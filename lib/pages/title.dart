import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isAlarmSet = false;

  Future<void> _setAlarm() async {
    // 안드로이드 알림 및 정확한 알람 권한 요청
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();

    // 1분 뒤로 알람 시간 설정
    final alarmTime = DateTime.now().add(const Duration(seconds: 10));
    final alarmSettings = AlarmSettings(
      id: 1,
      dateTime: alarmTime,
      assetAudioPath: 'assets/alarm.mp3', // 주의: 프로젝트에 해당 파일이 있어야 에러가 나지 않습니다.
      loopAudio: true,
      vibrate: true,
      notificationSettings: const NotificationSettings(
        title: '알람',
        body: '10초가 지났습니다!!',
        stopButton: '알람 중지',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    setState(() => _isAlarmSet = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('10초 뒤 알람이 설정되었습니다.')));
  }

  // Sender 버튼 동작 (기능 비워둠)
  void _onSenderPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sender (A폰) 버튼 클릭됨 - API 호출 구현 예정')),
    );
  }

  // Receiver 버튼 동작 (기능 비워둠)
  void _onReceiverPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receiver (B폰) 버튼 클릭됨 - API 호출 구현 예정')),
    );
  }

  // 원격 알람 끄기 버튼 동작 (기능 비워둠)
  void _onStopRemoteAlarmPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('알람 끄기 버튼 클릭됨 - API 호출 구현 예정')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_isAlarmSet ? '10초 뒤 알람이 설정되었습니다!' : '등록된 알람이 없습니다.'),
            if (_isAlarmSet) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Alarm.stop(1);
                  setState(() => _isAlarmSet = false);
                },
                child: const Text('알람 취소/중지'),
              ),
            ],
            const SizedBox(height: 40),
            const Divider(endIndent: 40, indent: 40),
            const SizedBox(height: 20),
            const Text(
              '네트워크 통신 테스트 (기능 비워둠)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onSenderPressed,
              child: const Text('Sender (A폰)'),
            ),
            ElevatedButton(
              onPressed: _onReceiverPressed,
              child: const Text('Receiver (B폰)'),
            ),
            ElevatedButton(
              onPressed: _onStopRemoteAlarmPressed,
              child: const Text('원격 알람 끄기'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setAlarm,
        tooltip: 'Set Alarm',
        child: const Icon(Icons.alarm_add),
      ),
    );
  }
}
