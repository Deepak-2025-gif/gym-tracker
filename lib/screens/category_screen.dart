import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/exercise.dart';
import '../providers/exercise_provider.dart';
import '../providers/workout_provider.dart';
import 'exercise_detail_screen.dart';
import 'add_custom_exercise_screen.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Exercise>> _exercisesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _exercisesFuture = Provider.of<ExerciseProvider>(context, listen: false)
        .getExercisesByCategory(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          // Exercises List
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: _exercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fitness_center,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No exercises yet'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            _navigateToAddExercise();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var exercises = snapshot.data!;
                var filteredExercises = Provider.of<ExerciseProvider>(context)
                    .searchExercises(exercises, _searchQuery);

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return _buildExerciseTile(context, exercise);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddExercise,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
    );
  }

  Widget _buildExerciseTile(BuildContext context, Exercise exercise) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ExerciseDetailScreen(exercise: exercise),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.description ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (exercise.isCustom)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () {
                            _navigateToEditExercise(exercise);
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            _confirmDelete(context, exercise);
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToAddExercise() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddCustomExerciseScreen(category: widget.category),
      ),
    ).then((_) {
      setState(() {
        _exercisesFuture = Provider.of<ExerciseProvider>(context, listen: false)
            .getExercisesByCategory(widget.category.id);
      });
    });
  }

  void _navigateToEditExercise(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomExerciseScreen(
          category: widget.category,
          exercise: exercise,
        ),
      ),
    ).then((_) {
      setState(() {
        _exercisesFuture = Provider.of<ExerciseProvider>(context, listen: false)
            .getExercisesByCategory(widget.category.id);
      });
    });
  }

  void _confirmDelete(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete ${exercise.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ExerciseProvider>(context, listen: false)
                  .deleteExercise(exercise.id);
              Navigator.pop(context);
              setState(() {
                _exercisesFuture =
                    Provider.of<ExerciseProvider>(context, listen: false)
                        .getExercisesByCategory(widget.category.id);
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
