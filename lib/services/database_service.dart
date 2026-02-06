import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/exercise.dart';
import '../models/workout_set.dart';
import '../models/profile.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gym_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        createdAt TEXT NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        icon TEXT,
        color TEXT
      )
    ''');

    // Exercises table
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        description TEXT,
        youtubeVideoId TEXT,
        defaultWeight REAL,
        defaultReps INTEGER,
        isCustom BOOLEAN DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');

    // Workout Sets table
    await db.execute('''
      CREATE TABLE workout_sets (
        id TEXT PRIMARY KEY,
        profileId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (profileId) REFERENCES profiles(id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises(id) ON DELETE CASCADE
      )
    ''');
  }

  // Category Operations
  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name');
    return [for (final map in maps) Category.fromMap(map)];
  }

  // Exercise Operations
  Future<void> insertExercise(Exercise exercise) async {
    final db = await database;
    await db.insert('exercises', exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Exercise>> getExercisesByCategory(String categoryId) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'isCustom ASC, name ASC',
    );
    return [for (final map in maps) Exercise.fromMap(map)];
  }

  Future<void> updateExercise(Exercise exercise) async {
    final db = await database;
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<void> deleteExercise(String exerciseId) async {
    final db = await database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<Exercise?> getExerciseById(String exerciseId) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [exerciseId],
    );
    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  // Workout Set Operations
  Future<void> insertWorkoutSet(WorkoutSet set) async {
    final db = await database;
    await db.insert('workout_sets', set.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WorkoutSet>> getWorkoutSetsByExercise(String exerciseId) async {
    final db = await database;
    final maps = await db.query(
      'workout_sets',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      orderBy: 'date DESC',
    );
    return [for (final map in maps) WorkoutSet.fromMap(map)];
  }

  Future<List<WorkoutSet>> getRecentWorkoutSets(
      String exerciseId, int limit) async {
    final db = await database;
    final maps = await db.query(
      'workout_sets',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      orderBy: 'date DESC',
      limit: limit,
    );
    return [for (final map in maps) WorkoutSet.fromMap(map)];
  }

  Future<List<WorkoutSet>> getWorkoutSetsByDate(
      String exerciseId, DateTime date) async {
    final db = await database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59)
        .toIso8601String();

    final maps = await db.query(
      'workout_sets',
      where: 'exerciseId = ? AND date >= ? AND date <= ?',
      whereArgs: [exerciseId, startOfDay, endOfDay],
      orderBy: 'date DESC',
    );
    return [for (final map in maps) WorkoutSet.fromMap(map)];
  }

  Future<void> deleteWorkoutSet(String setId) async {
    final db = await database;
    await db.delete(
      'workout_sets',
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  Future<Map<String, WorkoutSet?>> getLastWorkoutSetForEachExercise(
      String categoryId) async {
    final db = await database;
    final exercises =
        await db.query('exercises', where: 'categoryId = ?', whereArgs: [categoryId]);

    final result = <String, WorkoutSet?>{};
    for (final exercise in exercises) {
      final sets = await db.query(
        'workout_sets',
        where: 'exerciseId = ?',
        whereArgs: [exercise['id']],
        orderBy: 'date DESC',
        limit: 1,
      );
      result[exercise['id'] as String] =
          sets.isNotEmpty ? WorkoutSet.fromMap(sets.first) : null;
    }
    return result;
  }

  Future<List<WorkoutSet>> getAllWorkoutSets() async {
    final db = await database;
    final maps = await db.query('workout_sets', orderBy: 'date DESC');
    return [for (final map in maps) WorkoutSet.fromMap(map)];
  }

  // Profile Operations
  Future<void> createProfile(Profile profile) async {
    final db = await database;
    await db.insert('profiles', profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<List<Profile>> getAllProfiles() async {
    final db = await database;
    final maps = await db.query('profiles', orderBy: 'createdAt DESC');
    return [for (final map in maps) Profile.fromMap(map)];
  }

  Future<Profile?> getProfileByName(String name) async {
    final db = await database;
    final maps =
        await db.query('profiles', where: 'name = ?', whereArgs: [name]);
    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> profileNameExists(String name) async {
    final profile = await getProfileByName(name);
    return profile != null;
  }

  // Workout Set Operations with Profile Filter
  Future<void> insertWorkoutSetWithProfile(
      WorkoutSet set, String profileId) async {
    final db = await database;
    final map = set.toMap();
    map['profileId'] = profileId;
    await db.insert('workout_sets', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WorkoutSet>> getRecentWorkoutSetsForProfile(
      String exerciseId, String profileId, int limit) async {
    final db = await database;
    final maps = await db.query(
      'workout_sets',
      where: 'exerciseId = ? AND profileId = ?',
      whereArgs: [exerciseId, profileId],
      orderBy: 'date DESC',
      limit: limit,
    );
    return [for (final map in maps) WorkoutSet.fromMap(map)];
  }

  Future<void> seedInitialCategories() async {
    final db = await database;
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM categories');
    final categoryCount = Sqflite.firstIntValue(count) ?? 0;

    if (categoryCount == 0) {
      final categories = [
        Category(id: '1', name: 'Chest', icon: '💪', color: '#FF6B6B'),
        Category(id: '2', name: 'Shoulders', icon: '🏋️', color: '#4ECDC4'),
        Category(id: '3', name: 'Back', icon: '🔙', color: '#45B7D1'),
        Category(id: '4', name: 'Biceps', icon: '💪', color: '#FFA07A'),
        Category(id: '5', name: 'Triceps', icon: '💪', color: '#98D8C8'),
        Category(id: '6', name: 'Legs', icon: '🦵', color: '#F7DC6F'),
        Category(
            id: '7', name: 'Core/Abs', icon: '🎯', color: '#BB8FCE'),
      ];

      for (final category in categories) {
        await insertCategory(category);
      }
    }
  }

  Future<void> seedInitialExercises() async {
    final db = await database;
    final count = await db.rawQuery(
        'SELECT COUNT(*) as count FROM exercises WHERE isCustom = 0');
    final exerciseCount = Sqflite.firstIntValue(count) ?? 0;

    if (exerciseCount == 0) {
      final exercises = [
        // Chest
        Exercise(
          id: 'ex_1',
          name: 'Bench Press',
          categoryId: '1',
          description: 'Classic chest exercise',
          defaultWeight: 60,
          defaultReps: 8,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_2',
          name: 'Incline Dumbbell Press',
          categoryId: '1',
          description: 'Upper chest focus',
          defaultWeight: 30,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_3',
          name: 'Chest Flyes',
          categoryId: '1',
          description: 'Isolation exercise',
          defaultWeight: 25,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_4',
          name: 'Push-ups',
          categoryId: '1',
          description: 'Bodyweight exercise',
          defaultWeight: 0,
          defaultReps: 15,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_5',
          name: 'Cable Crossover',
          categoryId: '1',
          description: 'Cable machine exercise',
          defaultWeight: 40,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),

        // Shoulders
        Exercise(
          id: 'ex_6',
          name: 'Shoulder Press',
          categoryId: '2',
          description: 'Main shoulder builder',
          defaultWeight: 40,
          defaultReps: 8,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_7',
          name: 'Lateral Raises',
          categoryId: '2',
          description: 'Shoulder width exercise',
          defaultWeight: 15,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_8',
          name: 'Front Raises',
          categoryId: '2',
          description: 'Front delt exercise',
          defaultWeight: 15,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_9',
          name: 'Reverse Flyes',
          categoryId: '2',
          description: 'Rear delt exercise',
          defaultWeight: 15,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_10',
          name: 'Shrugs',
          categoryId: '2',
          description: 'Trap builder',
          defaultWeight: 80,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),

        // Back
        Exercise(
          id: 'ex_11',
          name: 'Bent Over Rows',
          categoryId: '3',
          description: 'Classic back builder',
          defaultWeight: 80,
          defaultReps: 8,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_12',
          name: 'Pull-ups',
          categoryId: '3',
          description: 'Bodyweight exercise',
          defaultWeight: 0,
          defaultReps: 8,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_13',
          name: 'Lat Pulldowns',
          categoryId: '3',
          description: 'Machine exercise',
          defaultWeight: 80,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_14',
          name: 'Barbell Rows',
          categoryId: '3',
          description: 'Heavy back exercise',
          defaultWeight: 100,
          defaultReps: 6,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_15',
          name: 'Reverse Pec Deck',
          categoryId: '3',
          description: 'Rear delt and back',
          defaultWeight: 50,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),

        // Biceps
        Exercise(
          id: 'ex_16',
          name: 'Barbell Curls',
          categoryId: '4',
          description: 'Classic bicep builder',
          defaultWeight: 40,
          defaultReps: 8,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_17',
          name: 'Dumbbell Curls',
          categoryId: '4',
          description: 'Dumbbell exercise',
          defaultWeight: 20,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_18',
          name: 'Cable Curls',
          categoryId: '4',
          description: 'Cable machine exercise',
          defaultWeight: 35,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_19',
          name: 'Hammer Curls',
          categoryId: '4',
          description: 'Neutral grip exercise',
          defaultWeight: 20,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_20',
          name: 'Preacher Curls',
          categoryId: '4',
          description: 'Isolation exercise',
          defaultWeight: 25,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),

        // Triceps
        Exercise(
          id: 'ex_21',
          name: 'Tricep Dips',
          categoryId: '5',
          description: 'Bodyweight exercise',
          defaultWeight: 0,
          defaultReps: 8,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_22',
          name: 'Rope Pressdowns',
          categoryId: '5',
          description: 'Cable exercise',
          defaultWeight: 40,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_23',
          name: 'Close Grip Bench Press',
          categoryId: '5',
          description: 'Barbell exercise',
          defaultWeight: 60,
          defaultReps: 8,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_24',
          name: 'Overhead Extensions',
          categoryId: '5',
          description: 'Dumbbell exercise',
          defaultWeight: 25,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_25',
          name: 'Skull Crushers',
          categoryId: '5',
          description: 'Barbell exercise',
          defaultWeight: 40,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),

        // Legs
        Exercise(
          id: 'ex_26',
          name: 'Squats',
          categoryId: '6',
          description: 'King of leg exercises',
          defaultWeight: 100,
          defaultReps: 6,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_27',
          name: 'Leg Press',
          categoryId: '6',
          description: 'Machine exercise',
          defaultWeight: 200,
          defaultReps: 8,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_28',
          name: 'Leg Curls',
          categoryId: '6',
          description: 'Hamstring exercise',
          defaultWeight: 80,
          defaultReps: 10,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_29',
          name: 'Leg Extensions',
          categoryId: '6',
          description: 'Quad exercise',
          defaultWeight: 80,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_30',
          name: 'Calf Raises',
          categoryId: '6',
          description: 'Calf builder',
          defaultWeight: 100,
          defaultReps: 15,
          isCustom: false,
          createdAt: DateTime.now(),
        ),

        // Core/Abs
        Exercise(
          id: 'ex_31',
          name: 'Crunches',
          categoryId: '7',
          description: 'Basic ab exercise',
          defaultWeight: 0,
          defaultReps: 20,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_32',
          name: 'Planks',
          categoryId: '7',
          description: 'Isometric exercise',
          defaultWeight: 0,
          defaultReps: 60,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_33',
          name: 'Ab Wheel Rollouts',
          categoryId: '7',
          description: 'Advanced ab exercise',
          defaultWeight: 0,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_34',
          name: 'Cable Crunches',
          categoryId: '7',
          description: 'Cable exercise',
          defaultWeight: 50,
          defaultReps: 15,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
        Exercise(
          id: 'ex_35',
          name: 'Hanging Leg Raises',
          categoryId: '7',
          description: 'Lower ab exercise',
          defaultWeight: 0,
          defaultReps: 12,
          isCustom: false,
          createdAt: DateTime.now(),
        ),
      ];

      for (final exercise in exercises) {
        await insertExercise(exercise);
      }
    }
  }
}
