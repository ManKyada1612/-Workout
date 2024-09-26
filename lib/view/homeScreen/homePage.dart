import 'package:flutter/material.dart';
import 'package:workouttracker/model/workout_model.dart';
import 'package:workouttracker/services/workout_db.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> workoutTypes = [
    'Cardio',
    'Strength',
    'Flexibility',
    'Balance',
    'Endurance',
    'HIIT',
  ];

  Map<String, bool> workoutStatus = {};
  Map<String, double> workoutValues = {};
  List<Workout> submittedWorkouts = [];
  List<Workout> todaysWorkouts = [];

  @override
  void initState() {
    super.initState();
    workoutStatus = {for (String type in workoutTypes) type: false};
    workoutValues = {for (String type in workoutTypes) type: 0};
    _fetchTodaysWorkouts();
  }

  void _fetchTodaysWorkouts() async {
    // Fetch today's workouts from the database
    List<Workout> todaysWorkoutsFromDB = await DBHelper().getTodaysWorkouts();
    setState(() {
      todaysWorkouts = todaysWorkoutsFromDB;

      for (Workout workout in todaysWorkouts) {
        workoutStatus[workout.name] = true;
        workoutValues[workout.name] = workout.value.toDouble();
        submittedWorkouts.add(workout);
      }
    });

    print("Today's Workouts: $todaysWorkouts");
  }

  void _saveOrUpdateWorkout(Workout workout) async {
    int workoutIndex = todaysWorkouts.indexWhere((w) => w.name == workout.name);

    if (workoutIndex == -1) {
      await DBHelper().insertWorkout(workout);
      setState(() {
        todaysWorkouts.add(workout);
        submittedWorkouts.add(workout);
        workoutStatus[workout.name] = true;
      });
    } else {
      await DBHelper().updateWorkout(workout);
      setState(() {
        todaysWorkouts[workoutIndex] = workout;
        submittedWorkouts[workoutIndex] = workout;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Workout Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Workout List'),
              onTap: () {
                Navigator.pushNamed(context, '/workoutList');
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Chart Page'),
              onTap: () {
                Navigator.pushNamed(context, '/chartPage');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: workoutTypes.length,
                itemBuilder: (context, index) {
                  String workoutType = workoutTypes[index];
                  bool workoutExists = todaysWorkouts
                      .any((workout) => workout.name == workoutType);

                  if (workoutExists) {
                    Workout todaysWorkout = todaysWorkouts
                        .firstWhere((workout) => workout.name == workoutType);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(workoutType),
                            Text('Done', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Value: ${todaysWorkout.value}'),
                            Slider(
                              value: todaysWorkout.value.toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: todaysWorkout.value.toString(),
                              onChanged: (double value) {
                                setState(() {
                                  workoutValues[workoutType] = value;
                                  todaysWorkout.value = value.toInt();
                                  _saveOrUpdateWorkout(todaysWorkout);
                                });
                              },
                            ),
                          ],
                        ),
                        trailing: TextButton(
                          child: Text('Edit'),
                          onPressed: () {
                            _saveOrUpdateWorkout(todaysWorkout);
                          },
                        ),
                      ),
                    );
                  } else {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(workoutType),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Value: ${workoutValues[workoutType] ?? 0}'),
                            Slider(
                              value: workoutValues[workoutType] ?? 0,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: (workoutValues[workoutType] ?? 0)
                                  .toStringAsFixed(0),
                              onChanged: (double value) {
                                setState(() {
                                  workoutValues[workoutType] = value;
                                });
                              },
                            ),
                          ],
                        ),
                        trailing: TextButton(
                          child: Text('Save'),
                          onPressed: () async {
                            setState(() {
                              Workout newWorkout = Workout(
                                id: DateTime.now().millisecondsSinceEpoch,
                                name: workoutType,
                                value: workoutValues[workoutType]!.toInt(),
                                date: DateTime.now(),
                                isDone: true,
                                type: workoutType,
                              );
                              submittedWorkouts.add(newWorkout);
                              workoutStatus[workoutType] = true;
                              _saveOrUpdateWorkout(newWorkout);
                            });
                            List<Workout> todaysWorkoutsFromDB =
                                await DBHelper().getTodaysWorkouts();
                            print(todaysWorkoutsFromDB.length);
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
