import 'package:flutter_talk_master/models/scenario.dart';
import 'package:flutter_talk_master/models/message.dart';

class Conversation {
  final int id;
  final int scenarioId;
  final String userId;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Scenario scenario;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.scenarioId,
    required this.userId,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    required this.scenario,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<Message> messages = messagesList.map((m) => Message.fromJson(m)).toList();

    return Conversation(
      id: json['id'],
      scenarioId: json['scenario_id'],
      userId: json['user_id'],
      status: json['status'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      scenario: Scenario.fromJson(json['scenario']),
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario_id': scenarioId,
      'user_id': userId,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'scenario': scenario.toJson(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}