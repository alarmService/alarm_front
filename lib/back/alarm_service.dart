import 'dart:convert';
import 'package:http/http.dart' as http;

class AlarmService {
  // Railway 서버 URL
  final String baseUrl = 'https://alarmserver-production.up.railway.app';

  // A폰: 알람 전송
  Future<void> sendAlarm() async {
    final url = Uri.parse('$baseUrl/alarm/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sender': 'A'}),
    );
    if (response.statusCode != 200) {
      throw Exception('전송 실패: ${response.body}');
    }
  }

  // B폰: 알람 끄기
  Future<void> dismissAlarm() async {
    final url = Uri.parse('$baseUrl/alarm/dismiss');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );
    if (response.statusCode != 200) {
      throw Exception('dismiss 실패: ${response.body}');
    }
  }

  // B폰: FCM 토큰 서버에 등록
  Future<void> registerToken(String token) async {
    final url = Uri.parse('$baseUrl/register-token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
    if (response.statusCode != 200) {
      throw Exception('토큰 등록 실패: ${response.body}');
    }
  }
}