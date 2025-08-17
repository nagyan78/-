import 'package:flutter/material.dart';
import 'package:flutter_talk_master/models/scenario.dart';
import 'package:flutter_talk_master/services/api_service.dart';
import 'package:flutter_talk_master/screens/chat_screen.dart';
import 'dart:io'; // 添加网络异常支持
import 'dart:async'; // 添加超时异常支持

class CustomScenarioScreen extends StatefulWidget {
  const CustomScenarioScreen({Key? key}) : super(key: key);

  @override
  _CustomScenarioScreenState createState() => _CustomScenarioScreenState();
}

class _CustomScenarioScreenState extends State<CustomScenarioScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  // 控制器用于表单输入
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeOfDayController = TextEditingController();
  final TextEditingController _charactersController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    // 释放控制器资源
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _timeOfDayController.dispose();
    _charactersController.dispose();
    super.dispose();
  }

  // 提交自定义场景
  void _submitCustomScenario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 解析角色列表（用逗号分隔）
      List<String> characters = _charactersController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // 创建场景数据
      Map<String, dynamic> scenarioData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'time_of_day': _timeOfDayController.text,
        'characters': characters,
        'template': 'custom',
      };

      // 创建新场景
      Scenario newScenario = Scenario(
        id: 0, // ID将在服务器端生成
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        timeOfDay: _timeOfDayController.text,
        characters: characters,
        template: 'custom',
        // 移除时间字段，因为它们应该由服务器设置
        createdAt: DateTime(0), // 临时值，会被服务器返回的真实值替换
        updatedAt: DateTime(0), // 临时值，会被服务器返回的真实值替换
      );
      
      Scenario scenario = await _apiService.createCustomScenario(newScenario);

      // 导航到聊天界面
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(scenarioId: scenario.id, isCustomScenario: true),
          ),
        );
      }
    } catch (e) {
      String errorMessage = '创建场景失败';
      if (e is SocketException) {
        errorMessage = '网络连接错误，请检查网络连接或确保后端服务正在运行';
      } else if (e is TimeoutException) {
        errorMessage = '连接超时，请检查网络连接或确保后端服务正在运行';
      } else if (e.toString().contains('Failed to load')) {
        errorMessage = '加载数据失败，请检查网络连接';
      } else if (e.toString().contains('Failed to create')) {
        errorMessage = '创建场景失败，请重试';
      } else {
        errorMessage = '创建场景时发生错误: ${e.toString()}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建自定义场景'),
        backgroundColor: const Color(0xFF728A7A), // 更新导航栏背景色
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '创建您自己的俄语对话练习场景',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '请填写以下信息，AI将根据您提供的场景信息与您进行俄语对话练习',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              
              // 场景标题输入
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '场景标题 *',
                  border: OutlineInputBorder(),
                  hintText: '例如：在机场值机柜台',
                  helperText: '给这个对话练习场景起一个简洁明了的名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入场景标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 场景描述输入
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '场景描述 *',
                  border: OutlineInputBorder(),
                  hintText: '例如：您需要在机场值机柜台办理登机手续，与工作人员进行俄语对话',
                  helperText: '详细描述这个场景的背景和情境，帮助AI更好地理解对话环境',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入场景描述';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 地点输入
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '地点 *',
                  border: OutlineInputBorder(),
                  hintText: '例如：机场、餐厅、酒店前台',
                  helperText: '对话发生的具体地点',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入地点';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 时间输入
              TextFormField(
                controller: _timeOfDayController,
                decoration: const InputDecoration(
                  labelText: '时间 *',
                  border: OutlineInputBorder(),
                  hintText: '例如：早上、下午、晚上',
                  helperText: '对话发生的时间段',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入时间';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 角色输入
              TextFormField(
                controller: _charactersController,
                decoration: const InputDecoration(
                  labelText: '角色（用逗号分隔） *',
                  border: OutlineInputBorder(),
                  hintText: '例如：旅客, 值机员',
                  helperText: '参与对话的所有角色，至少需要两个角色，用逗号分隔',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入至少两个角色';
                  }
                  
                  // 检查是否至少有两个角色
                  List<String> characters = value
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                      
                  if (characters.length < 2) {
                    return '请至少输入两个角色，用逗号分隔';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCustomScenario,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF95A098), // 更新按钮背景色
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          '创建场景并开始对话',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '提示：创建场景后，AI将根据您提供的信息开始对话，您需要使用俄语进行回答。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}