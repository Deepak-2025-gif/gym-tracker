import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_set.dart';
import '../services/database_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  Map<String, List<WorkoutSet>> _workoutSets = {};

  List<WorkoutSet>? getWorkoutSetsForExercise(String exerciseId) {
    return _workoutSets[exerciseId];
  }

  Future<void> logWorkoutSet(
    String exerciseId,
    double weight,
    int reps, {
    String? notes,
    required String profileId,
  }) async {
    const uuid = Uuid();
    final workoutSet = WorkoutSet(
      id: uuid.v4(),
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
      date: DateTime.now(),
      notes: notes,
      profileId: profileId,
    );

    await _dbService.insertWorkoutSet(workoutSet);

    if (!_workoutSets.containsKey(exerciseId)) {
      _workoutSets[exerciseId] = [];
    }
    _workoutSets[exerciseId]!.insert(0, workoutSet);
    notifyListeners();
  }

  Future<void> loadRecentSets(String exerciseId, String profileId, {int limit = 10}) async {
    final sets = await _dbService.getRecentWorkoutSetsForProfile(exerciseId, profileId, limit);
    _workoutSets[exerciseId] = sets;
    notifyListeners();
  }

  Future<void> deleteWorkoutSet(String setId) async {
    await _dbService.deleteWorkoutSet(setId);
    for (var sets in _workoutSets.values) {
      sets.removeWhere((s) => s.id == setId);
    }
    notifyListeners();
  }

  Future<List<WorkoutSet>> getAllWorkoutSets() async {
    return await _dbService.getAllWorkoutSets();
  }

  List<WorkoutSet>? getRecentSetsForExercise(String exerciseId) {
    return _workoutSets[exerciseId];
  }
}
