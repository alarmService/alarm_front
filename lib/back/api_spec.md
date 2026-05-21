# Alarm Demo API 명세서

## Base URL
https://alarm-demo-af881-default-rtdb.firebaseio.com

## 인증
현재 테스트 모드 - 인증 없이 호출 가능
(추후 Firebase Anonymous Auth ID 토큰을 ?auth={token} 으로 추가)

## DB 구조
demoRoom/
├── alarmActive  : boolean  - 알람 활성 여부
├── dismissed    : boolean  - 알람 해제 여부
├── sender       : string   - 보낸 쪽 (A)
├── receiver     : string   - 받는 쪽 (B)
└── updatedAt    : number   - 밀리초 타임스탬프

## 엔드포인트

### 1. 상태 조회
GET /demoRoom.json
Response:
{
  "alarmActive": false,
  "dismissed": false,
  "sender": "A",
  "receiver": "B",
  "updatedAt": 1716267840000
}

### 2. 알람 보내기 (A폰)
PATCH /demoRoom.json
Body:
{
  "alarmActive": true,
  "dismissed": false,
  "sender": "A",
  "receiver": "B",
  "updatedAt": 현재타임스탬프
}

### 3. 알람 끄기 (B폰)
PATCH /demoRoom.json
Body:
{
  "alarmActive": false,
  "dismissed": true,
  "updatedAt": 현재타임스탬프
}