import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro/pages/helpers/database_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pomodoro/pages/tasks/newTaskWidget.dart';
import 'package:pomodoro/pages/tasks/taskItem.dart';
import 'package:pomodoro/variables/colors.dart';
import 'package:pomodoro/variables/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setSkipTaskbar(false);
    await windowManager.setOpacity(1);
    await windowManager.setAlwaysOnTop(false);
    await windowManager.center();
    await windowManager.setTitle("Pomodoro Timer");
    await windowManager.setMinimumSize(const Size(800, 500));
    await windowManager.setSize(const Size(1100, 700));
    await windowManager.show();
  });

  await DatabaseManager.loadSharedPrefs();
  await DatabaseManager.loadData();

  runApp(const MyApp());
}

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
            "${DateFormat.MMMM().format(DateTime.now())} ${DateTime.now().day}, ${DateTime.now().year}",
            style: const TextStyle(
              fontFamily: fontfamily,
              color: textLight,
            ),
          ),
          foregroundColor: background,
          backgroundColor: primary,
          elevation: 10.0,
          shadowColor: shadow,
        ),
        body: mainContent(),
      ),
    );
  }

  Widget mainContent() {
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
    return Column(
      children: [
        Expanded(
          child: Container(),
        ),
        const NewTaskWidget(),
      ],
    );
  }

  bool isHoveringTodayTasksMoreOptions = false;
  bool isHoveringTomorrowTasksMoreOptions = false;
  bool isHoveringUpcomingTasksMoreOptions = false;
  bool isHoveringRepeatingTasksMoreOptions = false;

  Widget tasksToday() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                "Today (${DatabaseManager.tasksToday.length})",
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
      ],
    );
  }

  Widget tasksTomorrow() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                "Tomorrow (${DatabaseManager.tasksTomorrow.length})",
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
      ],
    );
  }

  Widget tasksUpcoming() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                "Upcoming (${DatabaseManager.tasksUpcoming.length})",
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
      ],
    );
  }
}
