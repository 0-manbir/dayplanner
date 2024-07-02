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

  static Future<void> loadDataLocal() async {
    if (prefs.containsKey(prefsTasksTodayName)) {
      for (String taskJson in prefs.getStringList(prefsTasksTodayName)!) {
        tasksToday.add(TaskItem.fromJson(jsonDecode(taskJson)));
      }
    } else {
      prefs.setStringList(prefsTasksTodayName, []);
    }
    if (prefs.containsKey(prefsTasksTomorrowName)) {
      for (String taskJson in prefs.getStringList(prefsTasksTomorrowName)!) {
        tasksTomorrow.add(TaskItem.fromJson(jsonDecode(taskJson)));
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
}
