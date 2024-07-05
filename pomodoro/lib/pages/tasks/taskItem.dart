import 'dart:convert';

import 'package:flutter/material.dart';

class TaskItem {
  String task = "{Empty}";
  int minsRequired = 0;
  TaskType taskType = TaskType.today;
  int colorIndex = 0;
  bool isDone = false;

  TaskItem({
    required this.task,
    required this.minsRequired,
    required this.taskType,
    required this.colorIndex,
    required this.isDone,
  });

  // Convert Task object to JSON string
  String toJson() {
    final Map<String, dynamic> data = {
      'task': task,
      'minsRequired': minsRequired,
      'taskType': taskType.toString().split('.').last,
      'colorIndex': colorIndex,
      'isDone': isDone,
    };
    return jsonEncode(data);
  }

  // Create Task object from JSON string
  factory TaskItem.fromJson(Map<String, dynamic> data) {
    return TaskItem(
      task: data['task'],
      minsRequired: data['minsRequired'],
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
