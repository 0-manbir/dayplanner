import 'dart:convert';

class TaskItem {
  String task = "{Empty}";
  int minsRequired = 0;
  TaskType taskType = TaskType.today;
  bool isDone = false;

  TaskItem({
    required this.task,
    required this.minsRequired,
    required this.taskType,
    required this.isDone,
  });

  // Convert Task object to JSON string
  String toJson() {
    final Map<String, dynamic> data = {
      'task': task,
      'minsRequired': minsRequired,
      'taskType': taskType.toString().split('.').last,
      'isDone': isDone,
    };
    return jsonEncode(data);
  }

  // Create Task object from JSON string
  factory TaskItem.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return TaskItem(
      task: data['task'],
      minsRequired: data['minsRequired'],
      taskType: TaskType.values
          .firstWhere((e) => e.toString() == 'TaskType.${data['taskType']}'),
      isDone: data['isDone'],
    );
  }
}

enum TaskType {
  today,
  tomorrow,
  upcoming,
  repeating,
}
