import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workouttracker/model/workout_model.dart';
import 'package:workouttracker/services/workout_db.dart';

class WorkoutListPage extends StatefulWidget {
  @override
  _WorkoutListPageState createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  List<Workout> workouts = [];
  List<Workout> filteredWorkouts = [];
  String selectedSegment = 'All';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    workouts = await DBHelper().getWorkouts();
    _filterWorkouts();
    setState(() {});
  }

  void _filterWorkouts() {
    if (selectedSegment == 'All') {
      filteredWorkouts = workouts;
    } else if (selectedSegment == 'Date' && selectedDate != null) {
      filteredWorkouts = workouts.where((workout) {
        return workout.date.year == selectedDate!.year &&
            workout.date.month == selectedDate!.month &&
            workout.date.day == selectedDate!.day;
      }).toList();
    }
  }

  Future<void> _updateWorkoutStatus(Workout workout, bool isDone) async {
    workout.isDone = isDone;
    await DBHelper().updateWorkout(workout);
    _filterWorkouts();
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedSegment = 'Date';
      });
      _filterWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Workout List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [
                selectedSegment == 'All',
                selectedSegment == 'Date',
              ],
              onPressed: (int index) {
                setState(() {
                  selectedSegment = index == 0 ? 'All' : 'Date';
                  if (selectedSegment == 'Date' && selectedDate != null) {
                    _filterWorkouts();
                  } else {
                    filteredWorkouts = workouts;
                  }
                });
              },
              children: [Text('All'), Text('Date')],
            ),
            SizedBox(height: 16),
            // Date selection button
            if (selectedSegment == 'Date') ...[
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text('Select Date'),
              ),
              SizedBox(height: 8),
              // Display the selected date
              if (selectedDate != null)
                Text(
                  'Selected Date: ${DateFormat.yMMMd().format(selectedDate!)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ],
            SizedBox(height: 16),

            filteredWorkouts.isEmpty
                ? Center(child: Text('No workouts available!'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = filteredWorkouts[index];
                        return ListTile(
                          title: Text(workout.name),
                          subtitle: Text(
                              'Value: ${workout.value} | Type: ${workout.type}'),
                          trailing: Checkbox(
                            value: workout.isDone,
                            onChanged: (bool? value) {
                              if (value != null) {
                                _updateWorkoutStatus(workout, value);
                              }
                            },
                          ),
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
