import 'package:flutter/material.dart';
import 'package:workouttracker/view/chartScreen/ChartPage%20.dart';
import 'package:workouttracker/view/homeScreen/homePage.dart';
import 'package:workouttracker/view/workoutListScreen/workout_list_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      routes: {
        '/workoutList': (context) => WorkoutListPage(),
        '/chartPage': (context) => ChartPage(),
      },
    );
  }
}
