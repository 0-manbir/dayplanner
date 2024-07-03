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
    if (prefs.containsKey(prefsTasksTodayName)) {
      for (String taskJson in prefs.getStringList(prefsTasksTodayName)!) {
        localDataTaskItem = TaskItem.fromJson(jsonDecode(taskJson));
        tasksToday.add(localDataTaskItem);
        if (!localDataTaskItem.isDone) {
          tasksTodayDurationMinutes += localDataTaskItem.minsRequired;
          tasksTodayLeft++;
        }
      }
    } else {
      prefs.setStringList(prefsTasksTodayName, []);
    }
    if (prefs.containsKey(prefsTasksTomorrowName)) {
      for (String taskJson in prefs.getStringList(prefsTasksTomorrowName)!) {
        localDataTaskItem = TaskItem.fromJson(jsonDecode(taskJson));
        tasksTomorrow.add(localDataTaskItem);
        if (!localDataTaskItem.isDone) {
          tasksTomorrowDurationMinutes += localDataTaskItem.minsRequired;
          tasksTomorrowLeft++;
        }
      }
    } else {
      prefs.setStringList(prefsTasksTomorrowName, []);
    }
    if (prefs.containsKey(prefsTasksUpcomingName)) {
      for (String taskJson in prefs.getStringList(prefsTasksUpcomingName)!) {
        tasksUpcoming.add(TaskItem.fromJson(jsonDecode(taskJson)));
      }
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

  static Future<void> saveData(TaskItem taskItem) async {
    // check if task already exists (with the same taskName).
    // if it does, append (1) to its name
    // TODO TEST THIS

    for (TaskItem task in taskItem.taskType == TaskType.today
        ? tasksToday
        : (taskItem.taskType == TaskType.tomorrow
            ? tasksTomorrow
            : tasksUpcoming)) {
      if (task.task == taskItem.task) {
        int number = 1;
        if (task.task.endsWith(")")) {
          try {
            number = int.parse(task.task.substring(
                task.task.lastIndexOf("(") + 1, task.task.lastIndexOf(")")));
          } catch (e) {
            number = 1;
          }
        } else {
          taskItem.task += " ($number)";
        }

        break;
      }
    }

    if (onlineMode) {
      await saveDataSupabase(taskItem);
    } else {
      await saveDataLocal(taskItem);
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

  static Future<void> updateDatabase(
    TaskType taskType,
    int index,
    String updatedTaskJSON,
    bool appendAtEnd,
  ) async {
    if (onlineMode) {
      await updateDataSupabase(taskType, index, updatedTaskJSON, appendAtEnd);
    } else {
      await updateDataLocal(taskType, index, updatedTaskJSON, appendAtEnd);
    }
  }

  static Future<void> updateDataLocal(
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

  static Future<void> updateDataSupabase(
    TaskType taskType,
    int index,
    String updatedTaskJSON,
    bool appendAtEnd,
  ) async {
    // TODO Implement Supabase data updation logic here
  }

  static Future<void> taskCompletionState(String taskJSON) async {
    await loadData();

    TaskItem taskItem = TaskItem.fromJson(jsonDecode(taskJSON));

    int index = 0;
    String updatedTaskString = taskJSON;

    for (TaskItem task in taskItem.taskType == TaskType.today
        ? tasksToday
        : (taskItem.taskType == TaskType.tomorrow
            ? tasksTomorrow
            : tasksUpcoming)) {
      if (task.task == taskItem.task) {
        task.isDone = !task.isDone;
        updatedTaskString = task.toJson();
        break;
      }
      index++;
    }

    updateDatabase(taskItem.taskType, index, updatedTaskString, true);
  }
}
