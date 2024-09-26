class Workout {
  int id;
  String name;
  int value; // Value between 0-100
  String type;
  DateTime date;
  bool isDone; // Add this property to track completion

  Workout({
    required this.id,
    required this.name,
    required this.value,
    required this.type,
    required this.date,
    this.isDone = false, // Default to false (not done)
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'type': type,
      'date': date.toIso8601String(),
      'isDone': isDone
          ? 1
          : 0, // Convert isDone to an integer for storage (1 for true, 0 for false)
    };
  }

  static Workout fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      value: map['value'],
      type: map['type'],
      date: DateTime.parse(map['date']),
      isDone: map['isDone'] == 1, // Convert back from integer to bool
    );
  }
}
