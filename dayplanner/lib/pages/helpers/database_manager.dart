import 'dart:convert';
import 'package:dayplanner/pages/planner/planner_section_item.dart';
import 'package:dayplanner/pages/planner/planner_section_slot_item.dart';
import 'package:dayplanner/pages/tasks/task_item.dart';
import 'package:dayplanner/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseManager {
  static late DateTime lastActiveDate;

  static late SharedPreferences prefs;
  static late bool onlineMode;

  static List<TaskItem> tasksToday = [];
  static List<TaskItem> tasksTomorrow = [];
  static List<TaskItem> tasksUpcoming = [];

  static int tasksTodayDurationMinutes = 0;
  static int tasksTodayLeft = 0;
  static int tasksTomorrowDurationMinutes = 0;
  static int tasksTomorrowLeft = 0;

  static List<SectionItem> plannerSections = [];

  static String SUPABASE_URL = "";
  static String SUPABASE_ANON_KEY = "";

  static Future<void> loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(prefsLastActiveDate)) {
      lastActiveDate = DateTime.parse(prefs.getString(prefsLastActiveDate)!);
    } else {
      prefs.setString(prefsLastActiveDate, DateTime.now().toString());
      lastActiveDate = DateTime.now();
    }

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

  // LOAD DATA------------------------------------------------------------------------------------------------------
  static Future<void> loadData() async {
    tasksToday.clear();
    tasksTomorrow.clear();
    tasksUpcoming.clear();
    tasksTodayLeft = 0;
    tasksTomorrowLeft = 0;
    tasksTodayDurationMinutes = 0;
    tasksTomorrowDurationMinutes = 0;
    plannerSections.clear();

    if (onlineMode) {
      await loadDataSupabase();
    } else {
      await loadDataLocal();
    }

    if (lastActiveDate.day != DateTime.now().day) {
      lastActiveDate = DateTime.now();
      prefs.setString(prefsLastActiveDate, lastActiveDate.toString());

      await removeDone(TaskType.today);

      for (int i = 0; i < tasksTomorrow.length; i++) {
        tasksTomorrow[i].taskType = TaskType.today;
      }

      tasksToday += tasksTomorrow;
      tasksTomorrow.clear();

      await removeAll(TaskType.tomorrow);
      _updatePrefs(TaskType.today, tasksToday);
    }

    print("Data Loaded");
    print("Total Tasks Today: ${tasksToday.length}");
    print("Total Tasks Tomorrow: ${tasksTomorrow.length}");
    print("Total Tasks Upcoming: ${tasksUpcoming.length}");
  }

  static late TaskItem localDataTaskItem;

  static Future<void> loadDataLocal() async {
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

    if (prefs.containsKey(prefsPlannerSections)) {
      List<String> sections = prefs.getStringList(prefsPlannerSections)!;
      for (String section in sections) {
        plannerSections.add(SectionItem.fromJson(jsonDecode(section)));
      }
    } else {
      prefs.setStringList(prefsPlannerSections, []);
    }
  }

  static Future<void> loadDataSupabase() async {
    // TODO Implement Supabase data loading logic here
  }

  // ADD A TASK------------------------------------------------------------------------------------------------------
  static Future<void> addTask(TaskItem taskItem, TaskType taskType) async {
    if (taskItem.task == "") return;

    for (TaskItem task in _getTaskList(taskType)) {
      if (task.id == taskItem.id) return;
    }

    if (onlineMode) {
      await addTaskSupabase(taskItem, taskType);
    } else {
      await addTaskLocal(taskItem, taskType);
    }
  }

  static Future<void> addTaskLocal(TaskItem taskItem, TaskType taskType) async {
    TaskItem updatedItem = taskItem;
    updatedItem.taskType = taskType;
    updatedItem.task = updatedItem.task.trim();

    String prefsTasksName = _getPrefsName(taskType);

    List<String> temp = prefs.getStringList(prefsTasksName)!;
    temp.add(updatedItem.toJson());
    prefs.setStringList(prefsTasksName, temp);
  }

  static Future<void> addTaskSupabase(
      TaskItem taskItem, TaskType taskType) async {
    // TODO Implement Supabase data saving logic here
  }

  // REMOVE A TASK----------------------------------------------------------------------------------------------------
  static Future<void> removeTask(TaskItem taskItem, TaskType taskType) async {
    if (onlineMode) {
      return removeTaskSupabase(taskItem, taskType);
    } else {
      return removeTaskLocal(taskItem, taskType);
    }
  }

  static Future<void> removeTaskLocal(
      TaskItem taskItem, TaskType taskType) async {
    try {
      List<String> temp = prefs.getStringList(_getPrefsName(taskType))!;
      temp.removeWhere((element) => jsonDecode(element)["id"] == taskItem.id);

      prefs.setStringList(_getPrefsName(taskType), temp);
    } catch (e) {
      // print("error in removing task");
    }
  }

  static Future<void> removeTaskSupabase(
      TaskItem taskItem, TaskType taskType) async {
    // TODO Implement Supabase data saving logic here
  }

  // TASK COMPLETION TOGGLE-----------------------------------------------------------------------------------------------
  static Future<void> taskCompletionState(TaskItem taskItem) async {
    List<TaskItem> temp = _getTaskList(taskItem.taskType);

    for (int i = 0; i < temp.length; i++) {
      if (temp[i].id == taskItem.id) {
        temp[i].isDone = !temp[i].isDone;
        break;
      }
    }

    _updatePrefs(taskItem.taskType, temp);
  }

  // HEADER MORE OPTIONS---------------------------------------------------------------------------------------------------
  static Future<void> removeDone(TaskType taskType) async {
    List<TaskItem> taskList = _getTaskList(taskType);
    taskList.removeWhere((task) => task.isDone);
    await _updatePrefs(taskType, taskList);
  }

  static Future<void> removeAll(TaskType taskType) async {
    await _updatePrefs(taskType, []);
  }

  static void markUndone(TaskType taskType) {
    List<TaskItem> taskList = _getTaskList(taskType);

    for (TaskItem task in taskList) {
      if (task.isDone) {
        task.isDone = false;
      }
    }

    _updatePrefs(taskType, taskList);
  }

  // ADD A SECTION--------------------------------------------------------------------------------------------------------
  static void addSection(SectionItem sectionItem) {
    plannerSections.add(sectionItem);
    prefs.setStringList(
        prefsPlannerSections, plannerSections.map((e) => e.toJson()).toList());
  }

  static Future<void> removeSectionSlot(
      SectionItem section, SectionSlotItem slot) async {
    for (int i = 0; i < section.slots.length; i++) {
      SectionSlotItem slotItem =
          SectionSlotItem.fromJson(jsonDecode(section.slots[i]));
      if (slotItem.id == slot.id) {
        section.slots.removeAt(i);
        break;
      }
    }

    for (int i = 0; i < plannerSections.length; i++) {
      if (plannerSections[i].id == section.id) {
        plannerSections[i] = section;
        break;
      }
    }

    await prefs.setStringList(
        prefsPlannerSections, plannerSections.map((e) => e.toJson()).toList());
  }

  static void updateSectionSlots(
      SectionItem section, SectionSlotItem slot, List<String> tasks) {
    for (int i = 0; i < section.slots.length; i++) {
      SectionSlotItem slotItem =
          SectionSlotItem.fromJson(jsonDecode(section.slots[i]));
      if (slotItem.id == slot.id) {
        slotItem.tasks = tasks;
        section.slots[i] = slotItem.toJson();
        break;
      }
    }
    for (int i = 0; i < plannerSections.length; i++) {
      if (plannerSections[i].id == section.id) {
        plannerSections[i] = section;
        break;
      }
    }
    prefs.setStringList(
        prefsPlannerSections, plannerSections.map((e) => e.toJson()).toList());
  }

  static Future<void> removeTaskFromSlot(
      SectionItem section, SectionSlotItem slot, TaskItem taskItem) async {
    List<String> updatedTasks = slot.tasks;
    updatedTasks
        .removeWhere((element) => jsonDecode(element)["id"] == taskItem.id);

    DatabaseManager.updateSectionSlots(section, slot, updatedTasks);
  }

  static Future<void> slotTaskCompletionStatus(
      SectionItem section, SectionSlotItem slot, TaskItem taskItem) async {
    List<String> updatedTasks = slot.tasks;

    for (int i = 0; i < updatedTasks.length; i++) {
      if (jsonDecode(updatedTasks[i])["id"] == taskItem.id) {
        TaskItem temp = TaskItem.fromJson(jsonDecode(updatedTasks[i]));
        temp.isDone = !temp.isDone;
        updatedTasks[i] = temp.toJson();
        break;
      }
    }
    DatabaseManager.updateSectionSlots(section, slot, updatedTasks);
  }

  // HELPERS---------------------------------------------------------------------------------------------------------------
  static List<TaskItem> _getTaskList(TaskType taskType) {
    switch (taskType) {
      case TaskType.today:
        return tasksToday;
      case TaskType.tomorrow:
        return tasksTomorrow;
      case TaskType.upcoming:
        return tasksUpcoming;
      case TaskType.forceadd:
        return [];
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
      case TaskType.forceadd:
        return "";
    }
  }

  static Future<void> _updatePrefs(
      TaskType taskType, List<TaskItem> taskList) async {
    String prefsTasksName = _getPrefsName(taskType);
    List<String> taskListJson = taskList.map((task) => task.toJson()).toList();
    if (onlineMode) {
    } else {
      await prefs.setStringList(prefsTasksName, taskListJson);
    }
  }

  static Future<void> updateSlots(SectionItem item, List<String> slots) async {
    item.slots = slots;

    for (int i = 0; i < plannerSections.length; i++) {
      if (plannerSections[i].id == item.id) {
        plannerSections[i] = item;
        break;
      }
    }
  }
}
