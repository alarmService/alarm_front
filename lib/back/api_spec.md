# Alarm Demo API 명세서

## Base URL
https://alarmserver-production.up.railway.app

## 인증
없음 (데모용)

## 엔드포인트

### 1. B폰 토큰 등록
POST /register-token
Body:
{
  "token": "FCM 토큰 문자열"
}
Response:
{ "success": true }

### 2. 알람 보내기 (A폰)
POST /alarm/send
Body:
{
  "sender": "A"
}
Response:
{ "success": true }

### 3. 알람 끄기 (B폰)
POST /alarm/dismiss
Body: {}
Response:
{ "success": true }