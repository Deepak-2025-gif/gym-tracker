import 'package:flutter/foundation.dart';
import '../models/progress_metrics.dart';
import '../models/workout_set.dart';
import '../services/database_service.dart';
import 'workout_provider.dart';

class ProgressProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final WorkoutProvider _workoutProvider;

  Map<String, ProgressMetrics> _exerciseProgress = {};
  bool _isLoading = false;

  ProgressProvider(this._workoutProvider) {
    _workoutProvider.addListener(_onWorkoutChanged);
  }

  void _onWorkoutChanged() {
    // When workout provider changes, refresh progress data
    refreshProgress();
  }

  Map<String, ProgressMetrics> get exerciseProgress => _exerciseProgress;
  bool get isLoading => _isLoading;

  /// Calculate progress metrics for a specific exercise and profile
  Future<ProgressMetrics?> calculateProgressForExercise(
    String exerciseId,
    String profileId,
  ) async {
    final sets = await _dbService.getRecentWorkoutSetsForProfile(
      exerciseId,
      profileId,
      10000, // Get all sets
    );

    if (sets.isEmpty) {
      return null;
    }

    // Calculate metrics
    double maxWeight = 0;
    int maxReps = 0;
    double totalWeight = 0;
    int totalReps = 0;
    double totalVolume = 0;
    DateTime? lastDate;

    for (final set in sets) {
      if (set.weight > maxWeight) {
        maxWeight = set.weight;
      }
      if (set.reps > maxReps) {
        maxReps = set.reps;
      }
      totalWeight += set.weight;
      totalReps += set.reps;
      totalVolume += set.weight * set.reps;
      if (lastDate == null || set.date.isAfter(lastDate)) {
        lastDate = set.date;
      }
    }

    final avgWeight = totalWeight / sets.length;
    final avgReps = totalReps / sets.length;

    // Get exercise name from workout provider
    String exerciseName = 'Exercise';
    final workoutSets = _workoutProvider.getWorkoutSetsForExercise(exerciseId);
    if (workoutSets != null && workoutSets.isNotEmpty) {
      exerciseName = 'Exercise $exerciseId'; // This could be enhanced with exercise service
    }

    return ProgressMetrics(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      personalRecordWeight: maxWeight > 0 ? maxWeight : null,
      personalRecordReps: maxReps > 0 ? maxReps : null,
      totalSets: sets.length,
      avgWeight: avgWeight,
      avgReps: avgReps,
      totalVolume: totalVolume,
      lastWorkoutDate: lastDate,
      lastWorkoutTime: lastDate != null
        ? '${lastDate.month}/${lastDate.day}/${lastDate.year}'
        : null,
    );
  }

  /// Get cached progress metrics for an exercise
  ProgressMetrics? getProgressMetrics(String exerciseId) {
    return _exerciseProgress[exerciseId];
  }

  /// Get weight progression data for charting
  Future<List<MapEntry<DateTime, double>>> getWeightProgression(
    String exerciseId,
    String profileId, {
    int limit = 50,
  }) async {
    final sets = await _dbService.getRecentWorkoutSetsForProfile(
      exerciseId,
      profileId,
      limit,
    );

    // Sort by date ascending for progression
    sets.sort((a, b) => a.date.compareTo(b.date));

    return sets
      .map((set) => MapEntry(set.date, set.weight))
      .toList();
  }

  /// Get reps progression data for charting
  Future<List<MapEntry<DateTime, int>>> getRepsProgression(
    String exerciseId,
    String profileId, {
    int limit = 50,
  }) async {
    final sets = await _dbService.getRecentWorkoutSetsForProfile(
      exerciseId,
      profileId,
      limit,
    );

    // Sort by date ascending for progression
    sets.sort((a, b) => a.date.compareTo(b.date));

    return sets
      .map((set) => MapEntry(set.date, set.reps))
      .toList();
  }

  /// Get volume progression data for charting
  Future<List<MapEntry<DateTime, double>>> getVolumeProgression(
    String exerciseId,
    String profileId, {
    int limit = 50,
  }) async {
    final sets = await _dbService.getRecentWorkoutSetsForProfile(
      exerciseId,
      profileId,
      limit,
    );

    // Sort by date ascending for progression
    sets.sort((a, b) => a.date.compareTo(b.date));

    return sets
      .map((set) => MapEntry(set.date, set.weight * set.reps))
      .toList();
  }

  /// Get all workout sets for an exercise and profile
  Future<List<WorkoutSet>> getAllWorkoutSetsForExercise(
    String exerciseId,
    String profileId,
  ) async {
    return await _dbService.getRecentWorkoutSetsForProfile(
      exerciseId,
      profileId,
      10000,
    );
  }

  /// Refresh all progress data
  Future<void> refreshProgress() async {
    notifyListeners();
  }

  @override
  void dispose() {
    _workoutProvider.removeListener(_onWorkoutChanged);
    super.dispose();
  }
}
