class Scenario {
  final int id;
  final String title;
  final String description;
  final String location;
  final String timeOfDay;
  final List<String> characters;
  final String? template; // 使template字段可为空
  final DateTime createdAt;
  final DateTime updatedAt;

  Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.timeOfDay,
    required this.characters,
    this.template, // 移除required并设置默认值为null
    required this.createdAt,
    required this.updatedAt,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      timeOfDay: json['time_of_day'],
      characters: List<String>.from(json['characters']),
      template: json['template'], // 允许为null
      // 处理可能不存在的时间字段
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'time_of_day': timeOfDay,
      'characters': characters,
      'template': template,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}