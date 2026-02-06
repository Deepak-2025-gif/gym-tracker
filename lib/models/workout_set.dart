class WorkoutSet {
  final String id;
  final String exerciseId;
  final double weight;
  final int reps;
  final DateTime date;
  final String? notes;
  final String? profileId;

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    required this.date,
    this.notes,
    this.profileId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'weight': weight,
      'reps': reps,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'] as String,
      exerciseId: map['exerciseId'] as String,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      profileId: map['profileId'] as String?,
    );
  }
}
