import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AlarmService {
  // Firebase Realtime Database REST API 기본 URL
  final String baseUrl = 'https://alarm-demo-af881-default-rtdb.firebaseio.com';

  // 현재 로그인된 익명 사용자의 ID 토큰 발급
  // REST API 인증에 ?auth={token} 으로 사용됨
  Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    return token ?? '';
  }

  // GET /demoRoom.json
  // Firebase에서 현재 알람 상태를 읽어오는 함수
  Future<Map<String, dynamic>?> fetchDemoRoom() async {
    final token = await _getIdToken();
    final url = Uri.parse('$baseUrl/demoRoom.json?auth=$token');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (response.body == 'null') return null;
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('GET 실패: ${response.body}');
    }
  }

  // PATCH /demoRoom.json
  // A폰이 알람을 보내는 함수
  // alarmActive: true, dismissed: false 로 상태 변경
  Future<void> sendAlarm() async {
    final token = await _getIdToken();
    final url = Uri.parse('$baseUrl/demoRoom.json?auth=$token');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'alarmActive': true,
        'dismissed': false,
        'sender': 'A',
        'receiver': 'B',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('PATCH 실패: ${response.body}');
    }
  }

  // PATCH /demoRoom.json
  // B폰이 알람을 끄는 함수
  // alarmActive: false, dismissed: true 로 상태 변경
  Future<void> dismissAlarm() async {
    final token = await _getIdToken();
    final url = Uri.parse('$baseUrl/demoRoom.json?auth=$token');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'alarmActive': false,
        'dismissed': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('PATCH 실패: ${response.body}');
    }
  }
}
