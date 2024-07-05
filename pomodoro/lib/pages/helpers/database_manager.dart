import 'dart:convert';
import 'package:pomodoro/pages/tasks/taskItem.dart';
import 'package:pomodoro/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseManager {
  static late SharedPreferences prefs;
  static late bool onlineMode;

  static List<TaskItem> tasksToday = [];
  static List<TaskItem> tasksTomorrow = [];
  static List<TaskItem> tasksUpcoming = [];

  static int tasksTodayDurationMinutes = 0;
  static int tasksTodayLeft = 0;
  static int tasksTomorrowDurationMinutes = 0;
  static int tasksTomorrowLeft = 0;

  static String SUPABASE_URL = "";
  static String SUPABASE_ANON_KEY = "";

  static Future<void> loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(prefsAPIKey)) {
      SUPABASE_URL = prefs.getString(prefsAPIKey)!;
      SUPABASE_ANON_KEY = prefs.getString(prefsAPIKey)!;
    }

    onlineMode = SUPABASE_URL.isNotEmpty;

    if (onlineMode) {
      await Supabase.initialize(
        url: DatabaseManager.SUPABASE_URL,
        anonKey: DatabaseManager.SUPABASE_ANON_KEY,
      );
    }
  }

  static Future<void> loadData() async {
    tasksToday.clear();
    tasksTomorrow.clear();
    tasksUpcoming.clear();
    if (onlineMode) {
      await loadDataSupabase();
    } else {
      await loadDataLocal();
    }
  }

  static late TaskItem localDataTaskItem;

  static Future<void> loadDataLocal() async {
    tasksTodayLeft = 0;
    tasksTomorrowLeft = 0;
    tasksTodayDurationMinutes = 0;
    tasksTomorrowDurationMinutes = 0;

    // Load and process tasks for today
    if (prefs.containsKey(prefsTasksTodayName)) {
      List<TaskItem> todayTasks = [];
      List<TaskItem> doneTodayTasks = [];
      for (String taskJson in prefs.getStringList(prefsTasksTodayName)!) {
        localDataTaskItem = TaskItem.fromJson(jsonDecode(taskJson));
        if (!localDataTaskItem.isDone) {
          tasksTodayDurationMinutes += localDataTaskItem.minsRequired;
          tasksTodayLeft++;
          todayTasks.add(localDataTaskItem);
        } else {
          doneTodayTasks.add(localDataTaskItem);
        }
      }
      tasksToday = todayTasks + doneTodayTasks;
    } else {
      prefs.setStringList(prefsTasksTodayName, []);
    }

    // Load and process tasks for tomorrow
    if (prefs.containsKey(prefsTasksTomorrowName)) {
      List<TaskItem> tomorrowTasks = [];
      List<TaskItem> doneTomorrowTasks = [];
      for (String taskJson in prefs.getStringList(prefsTasksTomorrowName)!) {
        localDataTaskItem = TaskItem.fromJson(jsonDecode(taskJson));
        if (!localDataTaskItem.isDone) {
          tasksTomorrowDurationMinutes += localDataTaskItem.minsRequired;
          tasksTomorrowLeft++;
          tomorrowTasks.add(localDataTaskItem);
        } else {
          doneTomorrowTasks.add(localDataTaskItem);
        }
      }
      tasksTomorrow = tomorrowTasks + doneTomorrowTasks;
    } else {
      prefs.setStringList(prefsTasksTomorrowName, []);
    }

    // Load and process upcoming tasks
    if (prefs.containsKey(prefsTasksUpcomingName)) {
      List<TaskItem> upcomingTasks = [];
      List<TaskItem> doneUpcomingTasks = [];
      for (String taskJson in prefs.getStringList(prefsTasksUpcomingName)!) {
        localDataTaskItem = TaskItem.fromJson(jsonDecode(taskJson));
        if (!localDataTaskItem.isDone) {
          upcomingTasks.add(localDataTaskItem);
        } else {
          doneUpcomingTasks.add(localDataTaskItem);
        }
      }
      tasksUpcoming = upcomingTasks + doneUpcomingTasks;
    } else {
      prefs.setStringList(prefsTasksUpcomingName, []);
    }

    print("Local data loaded");
    print("tasksToday: ${tasksToday.length}");
    print("tasksTomorrow: ${tasksTomorrow.length}");
    print("tasksUpcoming: ${tasksUpcoming.length}");
  }

  static Future<void> loadDataSupabase() async {
    // TODO Implement Supabase data loading logic here
  }

  /* static Future<void> saveData1(TaskItem taskItem) async {
    // check if task already exists (with the same taskName).
    // if it does, append (1) to its name
    // TODO TEST THIS

    TaskItem updatedTaskItem = taskItem;

    for (TaskItem task in _getTaskList(taskItem.taskType)) {
      if (task.task == taskItem.task) {
        int number = 1;
        if (task.task.endsWith(")")) {
          try {
            number = int.parse(task.task.substring(
                task.task.lastIndexOf("(") + 1, task.task.lastIndexOf(")")));
          } catch (e) {
            number = 1;
          }
        }
        updatedTaskItem.task += " ($number)";
        break;
      }
    }

    if (onlineMode) {
      await saveDataSupabase(updatedTaskItem);
    } else {
      await saveDataLocal(updatedTaskItem);
    }
  }

  static Future<void> saveDataLocal(TaskItem taskItem) async {
    String task = taskItem.toJson();

    String prefsTasksName;

    if (taskItem.taskType == TaskType.today) {
      tasksToday.add(taskItem);
      prefsTasksName = prefsTasksTodayName;
    } else if (taskItem.taskType == TaskType.tomorrow) {
      tasksTomorrow.add(taskItem);
      prefsTasksName = prefsTasksTomorrowName;
    } else if (taskItem.taskType == TaskType.upcoming) {
      tasksUpcoming.add(taskItem);
      prefsTasksName = prefsTasksUpcomingName;
    } else {
      prefsTasksName = prefsTasksTodayName;
    }

    List<String> temp = prefs.getStringList(prefsTasksName)!;
    temp.add(task);

    prefs.setStringList(prefsTasksName, temp);
  }

  static Future<void> saveDataSupabase(TaskItem taskItem) async {
    // TODO Implement Supabase data saving logic here
  }
*/

  static Future<void> addTask(TaskItem taskItem, TaskType taskType) async {
    if (onlineMode) {
      return addTaskSupabase(taskItem, taskType);
    } else {
      return addTaskLocal(taskItem, taskType);
    }
  }

  static Future<void> addTaskSupabase(
      TaskItem taskItem, TaskType taskType) async {
    // TODO Implement Supabase data saving logic here
  }
  static Future<void> addTaskLocal(TaskItem taskItem, TaskType taskType) async {
    if (_getTaskList(taskType).contains(taskItem)) {
      return;
    }

    TaskItem updatedItem = taskItem;
    updatedItem.taskType = taskType;
    updatedItem.task = updatedItem.task.trim();

    String task = updatedItem.toJson();
    String prefsTasksName;

    if (taskType == TaskType.today) {
      tasksToday.add(updatedItem);
      prefsTasksName = prefsTasksTodayName;
    } else if (taskType == TaskType.tomorrow) {
      tasksTomorrow.add(updatedItem);
      prefsTasksName = prefsTasksTomorrowName;
    } else if (taskType == TaskType.upcoming) {
      tasksUpcoming.add(updatedItem);
      prefsTasksName = prefsTasksUpcomingName;
    } else {
      prefsTasksName = prefsTasksTodayName;
    }

    List<String> temp = prefs.getStringList(prefsTasksName)!;
    temp.add(task);
    prefs.setStringList(prefsTasksName, temp);
  }

  static Future<void> removeTask(TaskItem taskItem, TaskType taskType) async {
    if (onlineMode) {
      return removeTaskSupabase(taskItem, taskType);
    } else {
      return removeTaskLocal(taskItem, taskType);
    }
  }

  static Future<void> removeTaskSupabase(
      TaskItem taskItem, TaskType taskType) async {
    // TODO Implement Supabase data saving logic here
  }
  static Future<void> removeTaskLocal(
      TaskItem taskItem, TaskType taskType) async {
    try {
      List<String> temp = prefs.getStringList(_getPrefsName(taskType))!;

      for (String task in temp) {
        if (TaskItem.fromJson(jsonDecode(task)).task == taskItem.task) {
          temp.remove(task);
          break;
        }
      }
      prefs.setStringList(_getPrefsName(taskType), temp);
    } catch (e) {
      print("error in removing task");
    }
  }

  static Future<void> updateDatabaseTaskDone(
    TaskType taskType,
    int index,
    String updatedTaskJSON,
    bool appendAtEnd,
  ) async {
    if (onlineMode) {
      await updateDataTaskDoneSupabase(
          taskType, index, updatedTaskJSON, appendAtEnd);
    } else {
      await updateDataTaskDoneLocal(
          taskType, index, updatedTaskJSON, appendAtEnd);
    }
  }

  static Future<void> updateDataTaskDoneLocal(
    TaskType taskType,
    int index,
    String updatedTaskJSON,
    bool appendAtEnd,
  ) async {
    String prefsTasksName;

    if (taskType == TaskType.today) {
      prefsTasksName = prefsTasksTodayName;
    } else if (taskType == TaskType.tomorrow) {
      prefsTasksName = prefsTasksTomorrowName;
    } else if (taskType == TaskType.upcoming) {
      prefsTasksName = prefsTasksUpcomingName;
    } else {
      prefsTasksName = prefsTasksTodayName;
    }

    List<String> listToUpdate = prefs.getStringList(prefsTasksName)!;

    if (appendAtEnd) {
      listToUpdate.removeAt(index);

      if (!TaskItem.fromJson(jsonDecode(updatedTaskJSON)).isDone) {
        listToUpdate.insert(0, updatedTaskJSON);
      } else {
        listToUpdate.add(updatedTaskJSON);
      }
    } else {
      listToUpdate[index] = updatedTaskJSON;
    }

    prefs.setStringList(prefsTasksName, listToUpdate);
  }

  static Future<void> updateDataTaskDoneSupabase(
    TaskType taskType,
    int index,
    String updatedTaskJSON,
    bool appendAtEnd,
  ) async {
    // TODO Implement Supabase data updation upon task item done logic here
  }

  static Future<void> taskCompletionState(String taskJSON) async {
    await loadData();

    TaskItem taskItem = TaskItem.fromJson(jsonDecode(taskJSON));

    int index = 0;
    String updatedTaskString = taskJSON;

    for (TaskItem task in _getTaskList(taskItem.taskType)) {
      if (task.task == taskItem.task) {
        task.isDone = !task.isDone;
        updatedTaskString = task.toJson();
        break;
      }
      index++;
    }

    updateDatabaseTaskDone(taskItem.taskType, index, updatedTaskString, true);
  }

  static Future<void> reorderTask(
      TaskItem taskItem, TaskItem targetTaskItem) async {
    TaskType fromTaskType = taskItem.taskType;
    TaskType toTaskType = targetTaskItem.taskType;

    // Remove the task from the original list
    List<TaskItem> fromList = _getTaskList(fromTaskType);
    fromList.remove(taskItem);

    // Add the task to the new list at the specified position
    List<TaskItem> toList = _getTaskList(toTaskType);
    int targetIndex = toList.indexOf(targetTaskItem) + 1;
    toList.insert(targetIndex, taskItem);

    // Update SharedPreferences
    await _updatePrefs(fromTaskType, fromList);
    await _updatePrefs(toTaskType, toList);
  }

  static Future<void> _updatePrefs(
      TaskType taskType, List<TaskItem> taskList) async {
    String prefsTasksName;

    if (taskType == TaskType.today) {
      prefsTasksName = prefsTasksTodayName;
    } else if (taskType == TaskType.tomorrow) {
      prefsTasksName = prefsTasksTomorrowName;
    } else {
      prefsTasksName = prefsTasksUpcomingName;
    }

    List<String> taskListJson = taskList.map((task) => task.toJson()).toList();
    await prefs.setStringList(prefsTasksName, taskListJson);
  }

  static List<TaskItem> _getTaskList(TaskType taskType) {
    switch (taskType) {
      case TaskType.today:
        return tasksToday;
      case TaskType.tomorrow:
        return tasksTomorrow;
      case TaskType.upcoming:
        return tasksUpcoming;
    }
  }

  static String _getPrefsName(TaskType taskType) {
    switch (taskType) {
      case TaskType.today:
        return prefsTasksTodayName;
      case TaskType.tomorrow:
        return prefsTasksTomorrowName;
      case TaskType.upcoming:
        return prefsTasksUpcomingName;
    }
  }
}
