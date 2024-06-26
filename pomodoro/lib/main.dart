// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro/variables/colors.dart';
import 'package:pomodoro/variables/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow().then((_) async {
    // await windowManager.setTitleBarStyle(TitleBarStyle.normal);

    await windowManager.setSkipTaskbar(false); // add this when minimised
    await windowManager.setOpacity(1); // add this when minimised
    await windowManager.setAlwaysOnTop(false); // add this when minimised

    // await windowManager.setIcon();
    await windowManager.center();
    await windowManager.setTitle("Pomodoro Timer");
    await windowManager.setMinimumSize(const Size(800, 500));
    await windowManager.setSize(const Size(1100, 700));
    await windowManager.show();
  });

  await loadSharedPrefs();

  // online mode
  if (SUPABASE_URL != "") {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
    );
  }

  onlineMode = SUPABASE_URL != "";

  tasksToday = [];
  tasksTomorrow = [];
  tasksUpcoming = [];

  if (onlineMode) {
    loadDataSupabase();
  } else {
    loadDataLocal();
  }

  runApp(const MyApp());
}

Future<void> loadSharedPrefs() async {
  prefs = await SharedPreferences.getInstance();

  if (prefs.containsKey(prefsAPIKey)) {
    SUPABASE_URL = prefs.getString(prefsAPIKey)!;
    SUPABASE_ANON_KEY = prefs.getString(prefsAPIKey)!;
  }
}

Future<void> loadDataLocal() async {
  if (prefs.containsKey(prefsTasksTodayName)) {
    for (String taskJson in prefs.getStringList(prefsTasksTodayName)!) {
      tasksToday.add(TaskItem.fromJson(jsonDecode(taskJson)));
    }
  }
  if (prefs.containsKey(prefsTasksTomorrowName)) {
    for (String taskJson in prefs.getStringList(prefsTasksTomorrowName)!) {
      tasksTomorrow.add(TaskItem.fromJson(jsonDecode(taskJson)));
    }
  }
  if (prefs.containsKey(prefsTasksUpcomingName)) {
    for (String taskJson in prefs.getStringList(prefsTasksUpcomingName)!) {
      tasksUpcoming.add(TaskItem.fromJson(jsonDecode(taskJson)));
    }
  }

  print(
      "local data loaded+++++++++++++++++++++++++++++++++++++++++++++++++++++");
  print("tasksToday: ${tasksToday.length}");
  print("tasksTomorrow: ${tasksTomorrow.length}");
  print("tasksUpcoming: ${tasksUpcoming.length}");
}

Future<void> loadDataSupabase() async {}

final supabase = Supabase.instance.client;
late SharedPreferences prefs;
late bool onlineMode;

late List<TaskItem> tasksToday;
late List<TaskItem> tasksTomorrow;
late List<TaskItem> tasksUpcoming;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro Timer',
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "${DateFormat.MMMM().format(DateTime.now())} ${DateTime.now().day.toString()}, ${DateTime.now().year.toString()}",
            style: TextStyle(
              fontFamily: fontfamily,
              color: textLight,
            ),
          ),
          foregroundColor: background,
          backgroundColor: primary,
          elevation: 10.0,
          shadowColor: shadow,
        ),
        body: main(),
      ),
    );
  }

  Widget main() {
    return Container(
      color: background,
      child: Row(
        children: [
          Expanded(
            child: newSession(),
          ),
          rowDivider(),
          Expanded(
            child: tasksToday(),
          ),
          rowDivider(),
          Expanded(
            child: tasksTomorrow(),
          ),
          rowDivider(),
          Expanded(
            child: tasksUpcoming(),
          ),
        ],
      ),
    );
  }

  Widget rowDivider() {
    return Container(
      color: divider,
      width: 2,
      height: MediaQuery.of(context).size.height,
    );
  }

  Widget newSession() {
    return Container();
  }

  bool isHoveringTodayTasksMoreOptions = false;
  bool isHoveringTomorrowTasksMoreOptions = false;
  bool isHoveringUpcomingTasksMoreOptions = false;

  Widget tasksToday() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),

          // Tasks Header----------------------------------
          child: Row(
            children: [
              Text(
                "Today (0)",
                style: TextStyle(
                  fontFamily: fontfamily,
                  color: textDark,
                  fontSize: 20.0,
                ),
              ),
              Expanded(child: Container()),
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    isHoveringTodayTasksMoreOptions = true;
                  });
                },
                onExit: (event) {
                  setState(() {
                    isHoveringTodayTasksMoreOptions = false;
                  });
                },
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: isHoveringTodayTasksMoreOptions
                          ? accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: textDark,
                      size: 26.0,
                    ),
                  ),
                  onTap: () {
                    // TODO today tasks options
                  },
                ),
              ),
            ],
          ),
        ),

        addNewTask(0, () {
          // TODO add new task today
        }),

        // Task View Today---------------------------------------
      ],
    );
  }

  Widget tasksTomorrow() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),

          // Tasks Header----------------------------------
          child: Row(
            children: [
              Text(
                "Tomorrow (0)",
                style: TextStyle(
                  fontFamily: fontfamily,
                  color: textDark,
                  fontSize: 20.0,
                ),
              ),
              Expanded(child: Container()),
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    isHoveringTomorrowTasksMoreOptions = true;
                  });
                },
                onExit: (event) {
                  setState(() {
                    isHoveringTomorrowTasksMoreOptions = false;
                  });
                },
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: isHoveringTomorrowTasksMoreOptions
                          ? accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: textDark,
                      size: 26.0,
                    ),
                  ),
                  onTap: () {
                    // TODO tomorrow tasks options
                  },
                ),
              ),
            ],
          ),
        ),

        addNewTask(1, () {
          // TODO add new task tomorrow
        }),

        // Task View Tomorrow---------------------------------------
      ],
    );
  }

  Widget tasksUpcoming() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),

          // Tasks Header----------------------------------
          child: Row(
            children: [
              Text(
                "Upcoming (0)",
                style: TextStyle(
                  fontFamily: fontfamily,
                  color: textDark,
                  fontSize: 20.0,
                ),
              ),
              Expanded(child: Container()),
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    isHoveringUpcomingTasksMoreOptions = true;
                  });
                },
                onExit: (event) {
                  setState(() {
                    isHoveringUpcomingTasksMoreOptions = false;
                  });
                },
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: isHoveringUpcomingTasksMoreOptions
                          ? accent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: textDark,
                      size: 26.0,
                    ),
                  ),
                  onTap: () {
                    // TODO upcoming tasks options
                  },
                ),
              ),
            ],
          ),
        ),

        addNewTask(2, () {
          // TODO add new task upcoming
        }),

        // Task View Upcoming---------------------------------------
      ],
    );
  }

  // which 'add new task' button is being hovered
  int hoveringAddNewTask = -1;

  Widget addNewTask(int index, Function onClick) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          hoveringAddNewTask = index;
        });
      },
      onExit: (event) {
        setState(() {
          hoveringAddNewTask = -1;
        });
      },
      child: Container(
        margin: EdgeInsets.all(12.0),
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: hoveringAddNewTask == index ? accent : secondary,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: GestureDetector(
          onTap: onClick(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: background,
              ),
              Container(width: 6.0),
              Text(
                "Add New Task",
                style: TextStyle(
                  fontFamily: fontfamily,
                  color: background,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
}
