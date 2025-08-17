# Talk to AI Backend API 文档

本文档详细描述了Talk to AI后端API，供前端团队对接使用。

## 基础信息

- **Base URL**: `http://localhost:8000/api/v1`
- **认证方式**: Bearer Token
- **数据格式**: JSON

## 认证 API

### 创建匿名用户

**请求**

```
POST /auth/anonymous
```

**响应**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**使用示例**

```bash
curl -X 'POST' \
  'http://localhost:8000/api/v1/auth/anonymous' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json'
```

## 场景 API


### 获取场景列表

**请求**

```
GET /scenarios/?skip=0&limit=100
```

**参数**
- `skip` (可选): 跳过的记录数，默认为0
- `limit` (可选): 返回的最大记录数，默认为100

**响应**

```json
[
  {
    "title": "我的自定义场景",
    "description": "我自己创建的场景",
    "location": "任意地点",
    "time_of_day": "早上",
    "characters": [
      "角色1",
      "角色2"
    ],
    "id": 1,
    "created_at": "2023-01-01T00:00:00",
    "updated_at": "2023-01-01T00:00:00"
  }
]
```

### 创建新场景

**请求**

```
POST /scenarios/
```

**请求体**

```json
{
  "title": "我的新场景",
  "description": "我自己创建的场景",
  "location": "任意地点",
  "time_of_day": "早上",
  "characters": [
    "角色1",
    "角色2"
  ]
}
```

**响应**

```json
{
  "title": "我的新场景",
  "description": "我自己创建的场景",
  "location": "任意地点",
  "time_of_day": "早上",
  "characters": [
    "角色1",
    "角色2"
  ],
  "id": 1,
  "created_at": "2023-01-01T00:00:00",
  "updated_at": "2023-01-01T00:00:00"
}
```

### 获取场景详情

**请求**

```
GET /scenarios/{scenario_id}
```

**参数**
- `scenario_id`: 场景ID

**响应**

```json
{
  "title": "我的新场景",
  "description": "我自己创建的场景",
  "location": "任意地点",
  "time_of_day": "早上",
  "characters": [
    "角色1",
    "角色2"
  ],
  "id": 1,
  "created_at": "2023-01-01T00:00:00",
  "updated_at": "2023-01-01T00:00:00"
}
```

### 更新场景

**请求**

```
PUT /scenarios/{scenario_id}
```

**参数**
- `scenario_id`: 场景ID

**请求体**

```json
{
  "title": "更新后的场景",
  "location": "新地点"
}
```

**响应**

```json
{
  "title": "更新后的场景",
  "description": "我自己创建的场景",
  "location": "新地点",
  "time_of_day": "早上",
  "characters": [
    "角色1",
    "角色2"
  ],
  "id": 3,
  "created_at": "2023-01-01T00:00:00",
  "updated_at": "2023-01-02T00:00:00"
}
```

### 删除场景

**请求**

```
DELETE /scenarios/{scenario_id}
```

**参数**
- `scenario_id`: 场景ID

**响应**

```json
{
  "message": "Scenario deleted successfully"
}
```

## 对话 API

### 创建新对话

**请求**

```
POST /conversations/
```

**请求体**

```json
{
  "scenario_id": 1,
  "user_id": "anon_1234567890abcdef"
}
```

**响应**

```json
{
  "scenario_id": 1,
  "user_id": "anon_1234567890abcdef",
  "id": 1,
  "status": "active",
  "started_at": "2023-01-01T00:00:00",
  "ended_at": null,
  "scenario": {
    "title": "餐厅点餐",
    "description": "在餐厅点餐的场景对话练习",
    "location": "餐厅",
    "time_of_day": "中午",
    "characters": [
      "顾客",
      "服务员"
    ],
    "id": 1,
    "created_at": "2023-01-01T00:00:00",
    "updated_at": "2023-01-01T00:00:00"
  },
  "messages": []
}
```

### 获取对话详情

**请求**

```
GET /conversations/{conversation_id}
```

**参数**
- `conversation_id`: 对话ID

**响应**

```json
{
  "scenario_id": 1,
  "user_id": "anon_1234567890abcdef",
  "id": 1,
  "status": "active",
  "started_at": "2023-01-01T00:00:00",
  "ended_at": null,
  "scenario": {
    "title": "餐厅点餐",
    "description": "在餐厅点餐的场景对话练习",
    "location": "餐厅",
    "time_of_day": "中午",
    "characters": [
      "顾客",
      "服务员"
    ],
    "id": 1,
    "created_at": "2023-01-01T00:00:00",
    "updated_at": "2023-01-01T00:00:00"
  },
  "messages": [
    {
      "conversation_id": 1,
      "sender": "user",
      "content": "Привет",
      "audio_url": "/storage/audio/voice_1_1640995200.wav",
      "audio_duration": 2.5,
      "is_thinking": false,
      "id": 1,
      "timestamp": "2023-01-01T00:01:00"
    }
  ]
}
```

### 更新对话状态（暂停/结束）

**请求**

```
PUT /conversations/{conversation_id}
```

**参数**
- `conversation_id`: 对话ID

**请求体**

```json
{
  "status": "ended"
}
```

**响应**

```json
{
  "scenario_id": 1,
  "user_id": "anon_1234567890abcdef",
  "id": 1,
  "status": "ended",
  "started_at": "2023-01-01T00:00:00",
  "ended_at": "2023-01-01T00:05:00",
  "scenario": {
    "title": "餐厅点餐",
    "description": "在餐厅点餐的场景对话练习",
    "location": "餐厅",
    "time_of_day": "中午",
    "characters": [
      "顾客",
      "服务员"
    ],
    "template": "restaurant",
    "id": 1,
    "created_at": "2023-01-01T00:00:00",
    "updated_at": "2023-01-01T00:00:00"
  },
  "messages": []
}
```

### 添加文本消息到对话

**请求**

```
POST /conversations/{conversation_id}/messages/text
```

**参数**
- `conversation_id`: 对话ID

**表单数据**
- `sender`: 消息发送者 (user 或 ai)
- `content`: 文本内容

**响应**

```json
{
  "conversation_id": 1,
  "sender": "ai",
  "content": "Здравствуйте! У меня все хорошо, спасибо!",
  "audio_url": null,
  "audio_duration": null,
  "is_thinking": false,
  "id": 1,
  "timestamp": "2023-01-01T00:01:00"
}
```

### 添加语音消息到对话

**请求**

```
POST /conversations/{conversation_id}/messages/voice
```

**参数**
- `conversation_id`: 对话ID

**表单数据**
- `audio`: 音频文件（用户通过麦克风录制的俄语语音）
- `sender`: 消息发送者 (user)

**响应**

```json
{
  "conversation_id": 1,
  "sender": "ai",
  "content": "Привет, как дела?",  // 语音识别后的俄语文本
  "audio_url": "/storage/audio/voice_1_1640995200.wav",  // 音频文件存储路径
  "audio_duration": 2.5,  // 音频时长（秒）
  "is_thinking": false,
  "id": 1,
  "timestamp": "2023-01-01T00:01:00"
}
```

### 获取对话消息列表

**请求**

```
GET /conversations/{conversation_id}/messages/
```

**参数**
- `conversation_id`: 对话ID

**响应**

```json
[
  {
    "conversation_id": 1,
    "sender": "user",
    "content": "Привет, как дела?",
    "audio_url": "/storage/audio/voice_1_1640995200.wav",
    "audio_duration": 2.5,
    "is_thinking": false,
    "id": 1,
    "timestamp": "2023-01-01T00:01:00"
  },
  {
    "conversation_id": 1,
    "sender": "ai",
    "content": "Здравствуйте! У меня все хорошо, спасибо!",
    "audio_url": "/storage/audio/tts_a1b2c3d4.mp3",
    "audio_duration": 3.2,
    "is_thinking": false,
    "id": 2,
    "timestamp": "2023-01-01T00:01:05"
  }
]
```

### 更新消息状态（AI正在输入动画）

**请求**

```
PUT /conversations/messages/{message_id}
```

**参数**
- `message_id`: 消息ID

**请求体**

```json
{
  "is_thinking": true
}
```

**响应**

```json
{
  "conversation_id": 1,
  "sender": "ai",
  "content": "",
  "audio_url": null,
  "audio_duration": null,
  "is_thinking": true,
  "id": 3,
  "timestamp": "2023-01-01T00:02:00"
}
```

### 结束对话并生成报告

**请求**

```
POST /conversations/{conversation_id}/end/
```

**参数**
- `conversation_id`: 对话ID

**响应**

```json
{
  "conversation_id": 1,
  "highlights": [
    {
      "text": "Здравствуйте! У меня все хорошо, спасибо!",
      "timestamp": "2023-01-01T00:01:05",
      "translation": "你好！我很好，谢谢！"
    }
  ],
  "sentiment_analysis": [
    {
      "timestamp": "2023-01-01T00:01:00",
      "sentiment_score": 0.8,
      "text": "Привет, как дела?"
    }
  ],
  "suggestions": [
    {
      "category": "俄语",
      "text": "注意俄语的语法结构，特别是名词的性和数的变化",
      "importance": 3
    }
  ],
  "pronunciation_score": 85,
  "grammar_score": 78,
  "fluency_score": 82,
  "overall_score": 81,
  "id": 1,
  "generated_at": "2023-01-01T00:05:00"
}
```

## 报告 API

### 根据报告ID获取报告

**请求**

```
GET /reports/{report_id}
```

**参数**
- `report_id`: 报告ID

**响应**

```json
{
  "conversation_id": 1,
  "highlights": [
    {
      "text": "Здравствуйте! У меня все хорошо, спасибо!",
      "timestamp": "2023-01-01T00:01:05",
      "translation": "你好！我很好，谢谢！"
    }
  ],
  "sentiment_analysis": [
    {
      "timestamp": "2023-01-01T00:01:00",
      "sentiment_score": 0.8,
      "text": "Привет, как дела?"
    }
  ],
  "suggestions": [
    {
      "category": "俄语",
      "text": "注意俄语的语法结构，特别是名词的性和数的变化",
      "importance": 3
    }
  ],
  "pronunciation_score": 85,
  "grammar_score": 78,
  "fluency_score": 82,
  "overall_score": 81,
  "id": 1,
  "generated_at": "2023-01-01T00:05:00"
}
```

### 根据对话ID获取报告

**请求**

```
GET /reports/conversation/{conversation_id}
```

**参数**
- `conversation_id`: 对话ID

**响应**

```json
{
  "conversation_id": 1,
  "highlights": [
    {
      "text": "Здравствуйте! У меня все хорошо, спасибо!",
      "timestamp": "2023-01-01T00:01:05",
      "translation": "你好！我很好，谢谢！"
    }
  ],
  "sentiment_analysis": [
    {
      "timestamp": "2023-01-01T00:01:00",
      "sentiment_score": 0.8,
      "text": "Привет, как дела?"
    }
  ],
  "suggestions": [
    {
      "category": "俄语",
      "text": "注意俄语的语法结构，特别是名词的性和数的变化",
      "importance": 3
    }
  ],
  "pronunciation_score": 85,
  "grammar_score": 78,
  "fluency_score": 82,
  "overall_score": 81,
  "id": 1,
  "generated_at": "2023-01-01T00:05:00"
}
```

### 导出报告

**请求**

```
POST /reports/export/
```

**请求体**

```json
{
  "format": "pdf",
  "report_id": 1
}
```

**响应**

```json
{
  "file_path": "/exports/pdf/report_1_a1b2c3d4e5f.pdf",
  "message": "Report exported as PDF successfully",
  "download_url": "http://localhost:8000/exports/pdf/report_1_a1b2c3d4e5f.pdf"
}
```

## 离线缓存 API

### 保存离线对话

**请求**

```
POST /offline/save/
```

**请求头**
- Authorization: Bearer [token]

**请求体**

```json
{
  "scenario": {
    "id": 1,
    "title": "餐厅点餐"
  },
  "messages": [
    {
      "sender": "user",
      "content": "Привет",
      "timestamp": "2023-01-01T00:00:00"
    }
  ]
}
```

**响应**

```json
{
  "message": "Conversation saved for offline sync",
  "filename": "offline_conv_anon_1234567890abcdef_20230101_000000_123456.json"
}
```

### 获取离线对话列表

**请求**

```
GET /offline/list/
```

**请求头**
- Authorization: Bearer [token]

**响应**

```json
[
  {
    "scenario": {
      "id": 1,
      "title": "餐厅点餐"
    },
    "messages": [
      {
        "sender": "user",
        "content": "Привет",
        "timestamp": "2023-01-01T00:00:00"
      }
    ],
    "metadata": {
      "saved_at": "2023-01-01T00:00:00",
      "user_id": "anon_1234567890abcdef",
      "version": "1.0",
      "type": "conversation_data"
    }
  }
]
```

### 同步离线对话

**请求**

```
POST /offline/sync/
```

**请求头**
- Authorization: Bearer [token]

**响应**

```json
{
  "message": "Synced 1 conversations",
  "synced_conversations": [
    {
      "scenario": {
        "id": 1,
        "title": "餐厅点餐"
      },
      "messages": [
        {
          "sender": "user",
          "content": "Привет",
          "timestamp": "2023-01-01T00:00:00"
        }
      ],
      "metadata": {
        "saved_at": "2023-01-01T00:00:00",
        "user_id": "anon_1234567890abcdef",
        "version": "1.0",
        "type": "conversation_data"
      },
      "sync_status": "success",
      "synced_at": "2023-01-01T01:00:00"
    }
  ]
}
```

## 错误响应格式

所有错误响应都遵循以下格式：

```json
{
  "detail": "错误描述信息"
}
```

常见的HTTP状态码：
- `400`: 请求参数错误
- `401`: 未认证或认证失败
- `404`: 请求的资源不存在
- `500`: 服务器内部错误