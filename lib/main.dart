import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/profile_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ProxyProvider<WorkoutProvider, ProgressProvider>(
          create: (_) => ProgressProvider(_.read<WorkoutProvider>()),
          update: (_, workoutProvider, previous) =>
            previous ?? ProgressProvider(workoutProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Gym Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ProfileSelectionScreen(),
      ),
    );
  }
}
