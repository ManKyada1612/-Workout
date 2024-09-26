import 'package:sqflite/sqflite.dart';
import 'package:workouttracker/model/workout_model.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'workout.db');
    print("Database path: $path");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        print("Creating database...");
        return db.execute(
          'CREATE TABLE workouts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, value INTEGER, type TEXT, date TEXT, isDone INTEGER DEFAULT 0)',
        );
      },
    );
  }

  Future<void> insertWorkout(Workout workout) async {
    final db = await database;
    print('Inserting workout: ${workout.toMap()}');
    await db.insert('workouts', workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateWorkout(Workout workout) async {
    final db = await database;
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<List<Workout>> getWorkoutsByDate(DateTime date) async {
    final db = await database;

    // Convert date to the start and end of the day
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) {
      return Workout.fromMap(maps[i]);
    });
  }

  Future<List<Workout>> getTodaysWorkouts() async {
    final db = await database;
    final DateTime now = DateTime.now();

    // Format today's date as YYYY-MM-DD
    final String today =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Use SQLite's date() function to compare only the date part
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'date(date) = ?', // 'date(date)' truncates time from the date
      whereArgs: [today], // Compare with today's date (YYYY-MM-DD)
    );

    // Convert the results into a list of Workout objects
    return List.generate(maps.length, (i) {
      return Workout(
        id: maps[i]['id'],
        name: maps[i]['name'],
        value: maps[i]['value'],
        date: DateTime.parse(maps[i]['date']),
        type: maps[i]['type'],
        isDone: maps[i]['isDone'] == 1, // Convert int to bool
      );
    });
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workouts');
    return List.generate(maps.length, (i) {
      return Workout.fromMap(maps[i]);
    });
  }
}
