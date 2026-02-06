class Exercise {
  final String id;
  final String name;
  final String categoryId;
  final String? description;
  final String? youtubeVideoId;
  final double defaultWeight;
  final int defaultReps;
  final bool isCustom;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.name,
    required this.categoryId,
    this.description,
    this.youtubeVideoId,
    required this.defaultWeight,
    required this.defaultReps,
    required this.isCustom,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'description': description,
      'youtubeVideoId': youtubeVideoId,
      'defaultWeight': defaultWeight,
      'defaultReps': defaultReps,
      'isCustom': isCustom ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      categoryId: map['categoryId'] as String,
      description: map['description'] as String?,
      youtubeVideoId: map['youtubeVideoId'] as String?,
      defaultWeight: (map['defaultWeight'] as num).toDouble(),
      defaultReps: map['defaultReps'] as int,
      isCustom: (map['isCustom'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? description,
    String? youtubeVideoId,
    double? defaultWeight,
    int? defaultReps,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      defaultReps: defaultReps ?? this.defaultReps,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
