import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/workout_set.dart';
import '../providers/progress_provider.dart';
import '../providers/profile_provider.dart';

class ExerciseProgressDetailScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;

  const ExerciseProgressDetailScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<ExerciseProgressDetailScreen> createState() =>
      _ExerciseProgressDetailScreenState();
}

class _ExerciseProgressDetailScreenState
    extends State<ExerciseProgressDetailScreen> {
  String _selectedMetric = 'weight'; // weight, reps, volume
  int _dataLimit = 20;

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.read<ProgressProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final currentProfile = profileProvider.currentProfile;

    if (currentProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercise Progress')),
        body: const Center(child: Text('No profile selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.exerciseName} Progress'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Metric Selector Tabs
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildMetricTab('Weight', 'weight'),
                  _buildMetricTab('Reps', 'reps'),
                  _buildMetricTab('Volume', 'volume'),
                ],
              ),
            ),
            // Chart
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder(
                  future: _getChartData(
                    progressProvider,
                    widget.exerciseId,
                    currentProfile.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox(
                        height: 300,
                        child: Center(child: Text('No data available')),
                      );
                    }

                    return SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 5,
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final data =
                                      snapshot.data as List<FlSpot>;
                                  if (value.toInt() < 0 ||
                                      value.toInt() >= data.length) {
                                    return const Text('');
                                  }
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineBarData(
                              spots: snapshot.data as List<FlSpot>,
                              isCurved: true,
                              barWidth: 2,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                              color: Colors.deepPurple,
                            ),
                          ],
                          minX: 0,
                          maxX: (snapshot.data as List<FlSpot>).length
                              .toDouble() - 1,
                          minY: 0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Data Limit Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Last '),
                  Expanded(
                    child: Slider(
                      value: _dataLimit.toDouble(),
                      min: 5,
                      max: 100,
                      divisions: 19,
                      label: '$_dataLimit sets',
                      onChanged: (value) {
                        setState(() {
                          _dataLimit = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('$_dataLimit sets'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats Section
            FutureBuilder(
              future: progressProvider.calculateProgressForExercise(
                widget.exerciseId,
                currentProfile.id,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }

                final metrics = snapshot.data;
                if (metrics == null || !metrics.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No workout data for ${widget.exerciseName} yet',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            'Personal Record Weight',
                            metrics.prWeightDisplay,
                          ),
                          _buildStatRow(
                            'Personal Record Reps',
                            metrics.prRepsDisplay,
                          ),
                          _buildStatRow(
                            'Average Weight',
                            '${metrics.avgWeightDisplay} kg',
                          ),
                          _buildStatRow(
                            'Average Reps',
                            metrics.avgRepsDisplay,
                          ),
                          _buildStatRow(
                            'Total Volume',
                            '${metrics.volumeDisplay} kg',
                          ),
                          _buildStatRow(
                            'Total Sets',
                            '${metrics.totalSets}',
                          ),
                          if (metrics.lastWorkoutDate != null)
                            _buildStatRow(
                              'Last Workout',
                              _formatDate(metrics.lastWorkoutDate!),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Recent Sets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Sets',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<WorkoutSet>>(
                    future: progressProvider.getAllWorkoutSetsForExercise(
                      widget.exerciseId,
                      currentProfile.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No sets logged yet');
                      }

                      final sets = snapshot.data!.take(10).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sets.length,
                        itemBuilder: (context, index) {
                          final set = sets[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${set.weight} kg × ${set.reps} reps',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(set.date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (set.notes != null)
                                    Expanded(
                                      child: Text(
                                        set.notes!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTab(String label, String value) {
    final isSelected = _selectedMetric == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMetric = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.deepPurple : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.deepPurple : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<List<FlSpot>> _getChartData(
    ProgressProvider provider,
    String exerciseId,
    String profileId,
  ) async {
    if (_selectedMetric == 'weight') {
      final data = await provider.getWeightProgression(
        exerciseId,
        profileId,
        limit: _dataLimit,
      );
      return data
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();
    } else if (_selectedMetric == 'reps') {
      final data = await provider.getRepsProgression(
        exerciseId,
        profileId,
        limit: _dataLimit,
      );
      return data
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();
    } else {
      final data = await provider.getVolumeProgression(
        exerciseId,
        profileId,
        limit: _dataLimit,
      );
      return data
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }
}
