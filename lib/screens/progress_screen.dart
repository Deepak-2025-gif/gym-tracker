import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/exercise.dart';
import '../providers/progress_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/exercise_provider.dart';
import 'exercise_progress_detail_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final exerciseProvider = context.read<ExerciseProvider>();
    final categories = exerciseProvider.categories;
    setState(() {
      _categories = ['All', ...categories.map((c) => c.name).toList()];
      _selectedCategory = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    final currentProfile = profileProvider.currentProfile;

    if (currentProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Progress')),
        body: const Center(child: Text('No profile selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Progress List
          Expanded(
            child: _buildProgressList(context, currentProfile.id),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList(BuildContext context, String profileId) {
    final exerciseProvider = context.read<ExerciseProvider>();
    final progressProvider = context.read<ProgressProvider>();

    // Get exercises based on selected category
    final allExercises = exerciseProvider.getAllExercises();
    final exercises = _selectedCategory == 'All'
        ? allExercises
        : allExercises
            .where((e) => exerciseProvider.categories
                .any((c) => c.id == e.categoryId && c.name == _selectedCategory))
            .toList();

    if (exercises.isEmpty) {
      return const Center(
        child: Text('No exercises in this category'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _buildProgressCard(
          context,
          exercise,
          profileId,
          progressProvider,
        );
      },
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    Exercise exercise,
    String profileId,
    ProgressProvider progressProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(exercise.name),
        subtitle: FutureBuilder(
          future: progressProvider.calculateProgressForExercise(
            exercise.id,
            profileId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }

            if (!snapshot.hasData || !snapshot.data!.hasData) {
              return const Text('No data logged');
            }

            final metrics = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PR: ${metrics.prWeightDisplay} × ${metrics.prRepsDisplay}',
                ),
                Text(
                  '${metrics.totalSets} sets • Avg: ${metrics.avgWeightDisplay} kg',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            );
          },
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseProgressDetailScreen(
                exerciseId: exercise.id,
                exerciseName: exercise.name,
              ),
            ),
          );
        },
      ),
    );
  }
}

