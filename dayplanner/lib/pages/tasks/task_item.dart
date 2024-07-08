import 'dart:convert';

class TaskItem {
  int id = 0;
  int minsRequired = 0;
  String task = "{Empty}";
  TaskType taskType = TaskType.today;
  int colorIndex = 0;
  bool isDone = false;

  TaskItem({
    required this.id,
    required this.minsRequired,
    required this.task,
    required this.taskType,
    required this.colorIndex,
    required this.isDone,
  });

  String toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'minsRequired': minsRequired,
      'task': task,
      'taskType': taskType.toString().split('.').last,
      'colorIndex': colorIndex,
      'isDone': isDone,
    };
    return jsonEncode(data);
  }

  factory TaskItem.fromJson(Map<String, dynamic> data) {
    return TaskItem(
      id: data['id'],
      minsRequired: data['minsRequired'],
      task: data['task'],
      taskType: TaskType.values
          .firstWhere((e) => e.toString() == 'TaskType.${data['taskType']}'),
      colorIndex: data['colorIndex'],
      isDone: data['isDone'],
    );
  }
}

enum TaskType {
  today,
  tomorrow,
  upcoming,
  forceadd,
}
