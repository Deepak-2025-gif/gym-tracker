class ProgressMetrics {
  final String exerciseId;
  final String exerciseName;
  final double? personalRecordWeight;
  final int? personalRecordReps;
  final int totalSets;
  final double avgWeight;
  final double avgReps;
  final double totalVolume;
  final DateTime? lastWorkoutDate;
  final String? lastWorkoutTime;

  ProgressMetrics({
    required this.exerciseId,
    required this.exerciseName,
    this.personalRecordWeight,
    this.personalRecordReps,
    required this.totalSets,
    required this.avgWeight,
    required this.avgReps,
    required this.totalVolume,
    this.lastWorkoutDate,
    this.lastWorkoutTime,
  });

  bool get hasData => totalSets > 0;

  String get prWeightDisplay => personalRecordWeight != null
    ? '${personalRecordWeight!.toStringAsFixed(1)} kg'
    : 'N/A';

  String get prRepsDisplay => personalRecordReps != null
    ? '${personalRecordReps!} reps'
    : 'N/A';

  String get avgWeightDisplay => avgWeight.toStringAsFixed(1);

  String get avgRepsDisplay => avgReps.toStringAsFixed(1);

  String get volumeDisplay => totalVolume.toStringAsFixed(0);
}
