import 'package:flutter/material.dart';
import 'package:workouttracker/model/workout_model.dart';
import 'package:workouttracker/services/workout_db.dart';
import 'package:workouttracker/view/chartScreen/chart.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage>
    with SingleTickerProviderStateMixin {
  List<Workout> workouts = [];
  List<int> filteredValues = List.filled(7, 0);
  List<String> workoutTypes = [
    'All',
    'Cardio',
    'Strength',
    'Flexibility',
    'Balance',
    'Endurance',
    'HIIT',
    'Unknown'
  ];

  late AnimationController _controller;
  late Animation<double> _animation;
  Future<void> _loadWorkouts() async {
    workouts = await DBHelper().getWorkouts();
    _filterWorkouts();
    _controller.forward();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadWorkouts();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _filterWorkouts() {
    DateTime today = DateTime.now();

    filteredValues = List.filled(workoutTypes.length, 0);

    workouts
        .where((workout) =>
            workout.date.year == today.year &&
            workout.date.month == today.month &&
            workout.date.day == today.day)
        .forEach((workout) {
      int index = workoutTypes.indexOf(workout.type);
      if (index != -1) {
        filteredValues[index] += workout.value;
      } else {
        filteredValues[workoutTypes.indexOf('Unknown')] += workout.value;
      }
    });

    if (filteredValues.every((value) => value == 0)) {
      print('No workouts for today!');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Workout Chart')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: filteredValues.isEmpty
                  ? Center(child: Text('No workouts to display!'))
                  : AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: BarChartPainter(
                              filteredValues, _animation.value, workoutTypes),
                          child: Container(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
