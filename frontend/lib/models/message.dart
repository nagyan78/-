class Message {
  final int id;
  final int conversationId;
  final String sender;
  final String content;
  final String? audioUrl;
  final double? audioDuration;
  final bool isThinking;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.audioUrl,
    required this.audioDuration,
    required this.isThinking,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      sender: json['sender'],
      content: json['content'],
      audioUrl: json['audio_url'],
      audioDuration: json['audio_duration']?.toDouble(),
      isThinking: json['is_thinking'] ?? false, // 默认值为false
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender': sender,
      'content': content,
      'audio_url': audioUrl,
      'audio_duration': audioDuration,
      'is_thinking': isThinking,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}