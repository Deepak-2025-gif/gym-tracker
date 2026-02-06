import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import '../services/database_service.dart';

class ExerciseProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Category> _categories = [];
  Map<String, List<Exercise>> _exercisesByCategory = {};
  Map<String, WorkoutSet?> _lastWorkoutSets = {};
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  ExerciseProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    await _dbService.seedInitialCategories();
    await _dbService.seedInitialExercises();
    await loadCategories();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _dbService.getAllCategories();
    notifyListeners();
  }

  Future<List<Exercise>> getExercisesByCategory(String categoryId) async {
    if (_exercisesByCategory.containsKey(categoryId)) {
      return _exercisesByCategory[categoryId]!;
    }

    final exercises = await _dbService.getExercisesByCategory(categoryId);
    _exercisesByCategory[categoryId] = exercises;
    notifyListeners();
    return exercises;
  }

  Future<void> addCustomExercise(Exercise exercise) async {
    await _dbService.insertExercise(exercise);
    if (_exercisesByCategory.containsKey(exercise.categoryId)) {
      _exercisesByCategory[exercise.categoryId]!.add(exercise);
    }
    notifyListeners();
  }

  Future<void> updateExercise(Exercise exercise) async {
    await _dbService.updateExercise(exercise);
    if (_exercisesByCategory.containsKey(exercise.categoryId)) {
      final index = _exercisesByCategory[exercise.categoryId]!
          .indexWhere((e) => e.id == exercise.id);
      if (index != -1) {
        _exercisesByCategory[exercise.categoryId]![index] = exercise;
      }
    }
    notifyListeners();
  }

  Future<void> deleteExercise(String exerciseId) async {
    await _dbService.deleteExercise(exerciseId);
    for (var exercises in _exercisesByCategory.values) {
      exercises.removeWhere((e) => e.id == exerciseId);
    }
    notifyListeners();
  }

  Future<void> loadLastWorkoutSets(String categoryId) async {
    _lastWorkoutSets =
        await _dbService.getLastWorkoutSetForEachExercise(categoryId);
    notifyListeners();
  }

  WorkoutSet? getLastWorkoutSet(String exerciseId) {
    return _lastWorkoutSets[exerciseId];
  }

  Future<Exercise?> getExerciseById(String exerciseId) async {
    return await _dbService.getExerciseById(exerciseId);
  }

  List<Exercise> searchExercises(
      List<Exercise> exercises, String query) {
    if (query.isEmpty) {
      return exercises;
    }
    return exercises
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Exercise> getAllExercises() {
    final all = <Exercise>[];
    for (final category in _categories) {
      final exercises = _exercisesByCategory[category.id];
      if (exercises != null) {
        all.addAll(exercises);
      }
    }
    return all;
  }
}
