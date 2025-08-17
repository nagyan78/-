class Report {
  final int id;
  final int conversationId;
  final List<Highlight> highlights;
  final List<SentimentAnalysis> sentimentAnalysis;
  final List<Suggestion> suggestions;
  final int pronunciationScore;
  final int grammarScore;
  final int fluencyScore;
  final int overallScore;
  final DateTime generatedAt;

  Report({
    required this.id,
    required this.conversationId,
    required this.highlights,
    required this.sentimentAnalysis,
    required this.suggestions,
    required this.pronunciationScore,
    required this.grammarScore,
    required this.fluencyScore,
    required this.overallScore,
    required this.generatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    var highlightsList = json['highlights'] as List;
    List<Highlight> highlights = highlightsList.map((h) => Highlight.fromJson(h)).toList();

    var sentimentList = json['sentiment_analysis'] as List;
    List<SentimentAnalysis> sentimentAnalysis = sentimentList.map((s) => SentimentAnalysis.fromJson(s)).toList();

    var suggestionsList = json['suggestions'] as List;
    List<Suggestion> suggestions = suggestionsList.map((s) => Suggestion.fromJson(s)).toList();

    return Report(
      id: json['id'],
      conversationId: json['conversation_id'],
      highlights: highlights,
      sentimentAnalysis: sentimentAnalysis,
      suggestions: suggestions,
      pronunciationScore: json['pronunciation_score'],
      grammarScore: json['grammar_score'],
      fluencyScore: json['fluency_score'],
      overallScore: json['overall_score'],
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'highlights': highlights.map((h) => h.toJson()).toList(),
      'sentiment_analysis': sentimentAnalysis.map((s) => s.toJson()).toList(),
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'pronunciation_score': pronunciationScore,
      'grammar_score': grammarScore,
      'fluency_score': fluencyScore,
      'overall_score': overallScore,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

class Highlight {
  final String text;
  final DateTime timestamp;
  final String translation;

  Highlight({
    required this.text,
    required this.timestamp,
    required this.translation,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      translation: json['translation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'translation': translation,
    };
  }
}

class SentimentAnalysis {
  final DateTime timestamp;
  final double sentimentScore;
  final String text;

  SentimentAnalysis({
    required this.timestamp,
    required this.sentimentScore,
    required this.text,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysis(
      timestamp: DateTime.parse(json['timestamp']),
      sentimentScore: json['sentiment_score'].toDouble(),
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'sentiment_score': sentimentScore,
      'text': text,
    };
  }
}

class Suggestion {
  final String category;
  final String text;
  final int importance;

  Suggestion({
    required this.category,
    required this.text,
    required this.importance,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      category: json['category'],
      text: json['text'],
      importance: json['importance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'text': text,
      'importance': importance,
    };
  }
}