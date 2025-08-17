import 'dart:convert';
import 'dart:io';
import 'package:flutter_talk_master/models/scenario.dart';
import 'package:flutter_talk_master/models/conversation.dart';
import 'package:flutter_talk_master/models/message.dart';
import 'package:flutter_talk_master/models/report.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // 添加超时异常支持

class ApiService {
  // 开发环境使用本地后端
  static const String baseUrl = 'http://192.168.31.183:8000/api/v1'; // 使用本地IP地址访问后端服务
  static const String apiKey = 'YOUR_API_KEY_HERE'; // 在实际应用中，这应该从安全的地方获取
  
  String? _authToken;

  // 获取存储的认证令牌
  Future<String?> _getAuthToken() async {
    if (_authToken != null) {
      return _authToken;
    }
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  // 保存认证令牌
  Future<void> _saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 确保用户已认证
  Future<void> _ensureAuthenticated() async {
    final token = await _getAuthToken();
    if (token == null) {
      await createAnonymousUser();
    }
  }

  // 创建匿名用户
  Future<void> createAnonymousUser() async {
    final url = Uri.parse('$baseUrl/auth/anonymous');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10)); // 添加超时设置

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveAuthToken(data['access_token']);
      } else {
        throw Exception('Failed to create anonymous user: ${response.statusCode}, body: ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('网络连接错误，请检查网络连接或确保后端服务正在运行: $e');
    } on TimeoutException catch (e) {
      throw Exception('连接超时，请检查网络连接或确保后端服务正在运行: $e');
    } catch (e) {
      throw Exception('创建匿名用户时发生未知错误: $e');
    }
  }

  // 获取场景模板列表
  Future<List<Scenario>> getScenarioTemplates() async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/scenarios/templates/');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Scenario.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load scenarios: ${response.statusCode}, body: ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('网络连接错误，请检查网络连接或确保后端服务正在运行: $e');
    } on TimeoutException catch (e) {
      throw Exception('连接超时，请检查网络连接或确保后端服务正在运行: $e');
    } catch (e) {
      throw Exception('获取场景模板时发生未知错误: $e');
    }
  }

  // 创建自定义场景
  Future<Scenario> createCustomScenario(Scenario scenario) async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/scenarios/');
    
    final scenarioData = {
      'title': scenario.title,
      'description': scenario.description,
      'location': scenario.location,
      'time_of_day': scenario.timeOfDay,
      'characters': scenario.characters,
      'template': scenario.template, // 添加 template 字段
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(scenarioData),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Scenario.fromJson(data);
      } else {
        throw Exception('Failed to create scenario: ${response.statusCode}, response: ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('网络连接错误，请检查网络连接或确保后端服务正在运行: $e');
    } on TimeoutException catch (e) {
      throw Exception('连接超时，请检查网络连接或确保后端服务正在运行: $e');
    } catch (e) {
      throw Exception('创建自定义场景时发生未知错误: $e');
    }
  }

  // 创建新对话
  Future<Conversation> createConversation(int scenarioId) async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/conversations/');
    
    // 获取用户ID（在实际应用中应该从用户会话中获取）
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'anon_${DateTime.now().millisecondsSinceEpoch}';
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'scenario_id': scenarioId,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Conversation.fromJson(data);
    } else {
      throw Exception('Failed to create conversation: ${response.statusCode}');
    }
  }

  // 获取对话详情
  Future<Conversation> getConversation(int conversationId) async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/conversations/$conversationId');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Conversation.fromJson(data);
    } else {
      throw Exception('Failed to load conversation: ${response.statusCode}');
    }
  }

  // 添加文本消息到对话
  Future<Message> addTextMessage(int conversationId, String sender, String content) async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/conversations/$conversationId/messages/text');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'sender': sender,
        'content': content,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Message.fromJson(data);
    } else {
      throw Exception('Failed to add text message: ${response.statusCode}');
    }
  }

  // 添加语音消息到对话
  Future<Message> addVoiceMessage(int conversationId, String sender, String audioPath) async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/conversations/$conversationId/messages/voice');
    
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    
    // 添加音频文件
    final file = await http.MultipartFile.fromPath('audio', audioPath);
    request.files.add(file);
    
    // 添加发送者信息
    request.fields['sender'] = sender;
    
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final data = json.decode(respStr);
      return Message.fromJson(data);
    } else {
      throw Exception('Failed to add voice message: ${response.statusCode}, response: $respStr');
    }
  }

  // 获取消息列表
  Future<List<Message>> getMessages(int conversationId) async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/conversations/$conversationId/messages/');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }
  
  // 结束对话并生成报告
  Future<Report> endConversation(int conversationId) async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/conversations/$conversationId/end/');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Report.fromJson(data);
    } else {
      throw Exception('Failed to end conversation: ${response.statusCode}');
    }
  }
  
  // 根据对话ID获取报告
  Future<Report> getReportByConversationId(int conversationId) async {
    await _ensureAuthenticated(); // 确保已认证
    final token = await _getAuthToken();
    final url = Uri.parse('$baseUrl/reports/conversation/$conversationId');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Report.fromJson(data);
    } else {
      throw Exception('Failed to load report: ${response.statusCode}');
    }
  }
}