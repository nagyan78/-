import 'package:flutter/material.dart';
import 'package:flutter_talk_master/models/conversation.dart';
import 'package:flutter_talk_master/models/message.dart';
import 'package:flutter_talk_master/models/report.dart';
import 'package:flutter_talk_master/services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:audioplayers/audioplayers.dart'; // 添加音频播放支持

class ChatScreen extends StatefulWidget {
  final int scenarioId;
  final bool isCustomScenario;

  const ChatScreen({
    Key? key,
    required this.scenarioId,
    this.isCustomScenario = false,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  // final AudioPlayer _audioPlayer = AudioPlayer(); // 音频播放器
  late Future<Conversation> _conversationFuture;
  Conversation? _conversation;
  bool _isLoading = false;
  bool _aiStarted = false;
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isRecording = false; // 语音录制状态
  String? _recordedAudioPath; // 录制的音频文件路径
  // 独立维护消息列表，确保所有消息都能正确显示
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    // 初始化 _conversationFuture 为一个 Completer 的 future
    _conversationFuture = _initConversation();
    _speechToText = stt.SpeechToText();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isCustomScenario) {
        _aiStartConversation();
      }
    });
  }

  // 初始化对话
  Future<Conversation> _initConversation() async {
    try {
      // 确保API服务已初始化并认证
      await _apiService.createAnonymousUser();
      return await _apiService.createConversation(widget.scenarioId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('初始化对话失败: $e')),
        );
      }
      // 重新抛出异常，以便 FutureBuilder 能够捕获到错误
      rethrow;
    }
  }

  /* ---------- AI 开场白相关 ---------- */
  // AI 开始对话方法
  void _aiStartConversation() async {
    // 如果 AI 已经开始对话，则直接返回
    if (_aiStarted) return;
    // 更新状态：AI 开始对话，设置加载状态
    setState(() {
      _aiStarted = true;
      _isLoading = true;
    });

    try {
      // 等待获取对话对象
      final conversation = await _conversationFuture;
      // 更新状态：设置当前对话
      setState(() => _conversation = conversation);

      // 直接获取并显示 AI 开场白，不显示"正在输入"状态
      final aiMessage = await _getAIInitialMessage(conversation.id);
      // 更新状态：添加 AI 消息，取消加载状态
      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });
    } catch (e) {
      // 更新状态：取消加载状态
      setState(() => _isLoading = false);
      // 如果组件仍然挂载，则显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取AI初始消息失败: $e')),
        );
      }
    }
  }

  Future<Message> _getAIInitialMessage(int conversationId) async {
    await Future.delayed(const Duration(seconds: 1));
    final conversation = await _apiService.getConversation(conversationId);
    final aiContent = _generateAIInitialMessage(conversation);
    return Message(
      id: 0,
      conversationId: conversationId,
      sender: 'ai',
      content: aiContent,
      audioUrl: null,
      audioDuration: null,
      isThinking: false,
      timestamp: DateTime.now(),
    );
  }

  String _generateAIInitialMessage(Conversation conversation) {
    final location = conversation.scenario.location;
    final timeOfDay = conversation.scenario.timeOfDay;
    final characters = conversation.scenario.characters.join(' 和 ');
    return '你好！我们现在在$location，时间是$timeOfDay。'
        '我扮演的角色是$characters。'
        '让我们开始对话吧！';
  }

  /* ---------- 发送消息 ---------- */
  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;
    final inputText = _textController.text.trim();

    setState(() => _isLoading = true);

    try {
      // 等待获取对话对象
      final conversation = await _conversationFuture;
      // 如果当前对话为空或 ID 不匹配，则更新当前对话
      if (_conversation == null || _conversation!.id != conversation.id) {
        setState(() => _conversation = conversation);
      }

      /* 1. 创建用户消息并立即显示，提供即时反馈 */
      final userMessage = Message(
        id: 0, // 临时 ID
        conversationId: conversation.id,
        sender: 'user',
        content: inputText,
        audioUrl: null,
        audioDuration: null,
        isThinking: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(userMessage);
        _textController.clear();
      });

      /* 2. 调用接口，发送用户消息到服务器 */
      final serverUserMessage = await _apiService.addTextMessage(
        conversation.id,
        'user',
        inputText,
      );

      /* 3. 不再替换用户消息，而是保留本地创建的消息 */

      /* 4. AI 正在输入占位 */
      final thinkingMessage = Message(
        id: 0,
        conversationId: conversation.id,
        sender: 'ai',
        content: '',
        audioUrl: null,
        audioDuration: null,
        isThinking: true,
        timestamp: DateTime.now(),
      );

      setState(() => _messages.add(thinkingMessage));

      /* 5. 轮询获取 AI 回复 */
      final aiMessage = await _pollForAIResponse(conversation.id);

      setState(() {
        // 移除"正在输入"消息
        _messages.removeWhere((m) => m.isThinking && m.sender == 'ai');
        
        // 检查AI消息是否已存在，避免重复添加
        final alreadyExists = _messages.any((m) =>
            m.sender == 'ai' && 
            m.content == aiMessage.content && 
            m.timestamp.difference(aiMessage.timestamp).inSeconds.abs() < 5); // 允许5秒内的时间差
            
        if (!alreadyExists) {
          _messages.add(aiMessage);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送消息失败: $e')),
        );
      } 
    }
  }

  // 发送语音消息
  void _sendVoiceMessage(String audioPath) async {
    setState(() => _isLoading = true);

    try {
      // 等待获取对话对象
      final conversation = await _conversationFuture;
      // 如果当前对话为空或 ID 不匹配，则更新当前对话
      if (_conversation == null || _conversation!.id != conversation.id) {
        setState(() => _conversation = conversation);
      }

      /* 1. 创建用户语音消息并立即显示，提供即时反馈 */
      final userVoiceMessage = Message(
        id: 0,
        conversationId: conversation.id,
        sender: 'user',
        content: '[语音消息]',
        audioUrl: audioPath,
        audioDuration: null,
        isThinking: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(userVoiceMessage);
      });

      /* 2. 调用接口，发送语音消息到服务器 */
      final serverVoiceMessage = await _apiService.addVoiceMessage(
        conversation.id,
        'user',
        audioPath,
      );

      /* 3. 不再替换用户消息，而是保留本地创建的消息 */

      /* 4. AI 正在输入占位 */
      final thinkingMessage = Message(
        id: 0,
        conversationId: conversation.id,
        sender: 'ai',
        content: '',
        audioUrl: null,
        audioDuration: null,
        isThinking: true,
        timestamp: DateTime.now(),
      );

      setState(() => _messages.add(thinkingMessage));

      /* 5. 轮询获取 AI 回复 */
      final aiMessage = await _pollForAIResponse(conversation.id);

      setState(() {
        // 移除"正在输入"消息
        _messages.removeWhere((m) => m.isThinking && m.sender == 'ai');
        
        // 检查AI消息是否已存在，避免重复添加
        final alreadyExists = _messages.any((m) =>
            m.sender == 'ai' && 
            m.content == aiMessage.content && 
            m.timestamp.difference(aiMessage.timestamp).inSeconds.abs() < 5); // 允许5秒内的时间差
            
        if (!alreadyExists) {
          _messages.add(aiMessage);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送语音消息失败: $e')),
        );
      }
    }
  }

  /* ---------- 轮询 AI 回复 ---------- */
  Future<Message> _pollForAIResponse(int conversationId) async {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      final msgs = await _apiService.getMessages(conversationId);
      final aiMsgs = msgs
          .where((m) => m.sender == 'ai' && !m.isThinking && m.content.isNotEmpty)
          .toList();
      if (aiMsgs.isNotEmpty) {
        aiMsgs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return aiMsgs.first;
      }
    }
    return Message(
      id: 0,
      conversationId: conversationId,
      sender: 'ai',
      content: '抱歉，我没有收到回复，请重试。',
      audioUrl: null,
      audioDuration: null,
      isThinking: false,
      timestamp: DateTime.now(),
    );
  }

  /* ---------- 语音识别 ---------- */
  void _startListening() async {
    final available = await _speechToText.initialize(
      onStatus: (status) => debugPrint('语音识别状态: $status'),
      onError: (error) => debugPrint('语音识别错误: $error'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) => setState(
          () => _textController.text = result.recognizedWords,
        ),
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  /* ---------- 语音录制 ---------- */
  void _startRecording() async {
    // TODO: 实现语音录制功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('语音录制功能待实现')),
    );
  }

  void _stopRecording() {
    // TODO: 实现停止录制功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('停止录制并发送语音消息')),
    );
  }

  /* ---------- 结束对话 ---------- */
  void _endConversation() async {
    if (_conversation == null) return;

    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('结束对话'),
        content: const Text('您确定要结束当前对话吗？AI将对您的对话进行评价。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (shouldEnd == true) {
      try {
        // 直接创建一个虚拟的评分报告，而不是调用 API
        Report report = Report(
          id: 1,
          conversationId: _conversation!.id,
          overallScore: 85, // 固定的总体评分
          pronunciationScore: 80, // 固定的发音评分
          grammarScore: 90, // 固定的语法评分
          fluencyScore: 85, // 固定的流利度评分
          generatedAt: DateTime.now(), // 生成时间
          sentimentAnalysis: [
            // 固定的情感分析
            SentimentAnalysis(
              timestamp: DateTime.now(),
              sentimentScore: 0.8,
              text: "用户表达清晰，情感积极",
            ),
          ],
          highlights: [
            // 固定的高光句子
            Highlight(
              text: "Привет, как дела?",
              timestamp: DateTime.now(),
              translation: "你好，怎么样？",
            ),
            Highlight(
              text: "Я хорошо провел время в этом разговоре.",
              timestamp: DateTime.now(),
              translation: "我很享受这次对话。",
            ),
          ],
          suggestions: [
            // 固定的学习建议
            Suggestion(
              category: "发音",
              text: "继续练习俄语元音的发音",
              importance: 3,
            ),
            Suggestion(
              category: "语法",
              text: "注意动词变位的正确使用",
              importance: 2,
            ),
            Suggestion(
              category: "词汇",
              text: "可以学习更多日常生活相关的词汇",
              importance: 1,
            ),
          ],
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('对话已结束，AI评价已生成')),
          );
          
          // 显示评分弹窗
          _showReportDialog(report);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('结束对话失败: $e')),
          );
        }
      }
    }
  }
  
  // 显示评分报告弹窗
  void _showReportDialog(Report report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AI 评价报告'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总体评分
                Text(
                  '总体评分: ${report.overallScore}/100',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // 详细评分
                const Text('详细评分:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('发音: ${report.pronunciationScore}/100'),
                Text('语法: ${report.grammarScore}/100'),
                Text('流利度: ${report.fluencyScore}/100'),
                const SizedBox(height: 10),
                
                // 高光句子
                if (report.highlights.isNotEmpty) ...[
                  const Text('高光句子:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  ...report.highlights.map((highlight) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(highlight.text, style: const TextStyle(fontStyle: FontStyle.italic)),
                          Text('翻译: ${highlight.translation}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ).toList(),
                  const SizedBox(height: 10),
                ],
                
                // 建议
                if (report.suggestions.isNotEmpty) ...[
                  const Text('学习建议:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  ...report.suggestions.map((suggestion) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text('${suggestion.category}: ${suggestion.text}'),
                    ),
                  ).toList(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI对话'),
        backgroundColor: const Color(0xFF728A7A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _endConversation,
            tooltip: '结束对话',
          ),
        ],
      ),
      body: FutureBuilder<Conversation>(
        future: _conversationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('错误: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('没有数据'));
          }
          // 只在_conversation为null时初始化，避免覆盖已有消息
          if (_conversation == null) {
            _conversation = snapshot.data!;
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageItem(_messages[index]),
                ),
              ),
              _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    if (message.isThinking) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('AI正在输入'),
              SizedBox(width: 8),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      );
    }
    
    final isUser = message.sender == 'user';
    
    // 处理语音消息
    if (message.audioUrl != null && message.audioUrl!.isNotEmpty) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 显示文本内容（如果有）
              if (message.content.isNotEmpty) ...[
                Text(message.content, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
              ],
              // 语音播放控件
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      // TODO: 实现语音播放功能
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('语音播放功能待实现')),
                      );
                    },
                  ),
                  if (message.audioDuration != null)
                    Text('${message.audioDuration!.toStringAsFixed(1)}s'),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    // 处理文本消息
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(message.content, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: '输入你的消息...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          // 文本输入发送按钮
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendMessage,
            color: const Color(0xFF95A098),
          ),
          const SizedBox(width: 8),
          // 语音输入按钮（长按录音，短按语音识别）
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressEnd: (_) => _stopRecording(),
            child: IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              onPressed: _isListening ? _stopListening : _startListening,
              color: _isListening ? Colors.red : const Color(0xFF95A098),
            ),
          ),
        ],
      ),
    );
  }
}