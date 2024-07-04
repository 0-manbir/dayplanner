import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro/pages/helpers/database_manager.dart';
import 'package:pomodoro/variables/integers.dart';
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
        // TODO day planner
        Expanded(
          child: Container(),
        ),
        NewTaskWidget(
          notifyParent: refresh,
        ),
      ],
    );
  }

  void refresh() {
    setState(() {
      DatabaseManager.loadData();
    });
  }

  int hoveringTasksMoreOptions = -1;
  int droppingTaskType = -1;

  Widget tasksToday() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              tasksHeaderText(TaskType.today),
              Expanded(child: Container()),
              tasksHeaderMore(0, () {}),
            ],
          ),
        ),
        tasksDivider(false),
        taskBuilder(TaskType.today),
        DragTarget(
          builder: (BuildContext context, List<Object?> candidateData,
              List<dynamic> rejectedData) {
            return droppingTaskType == 0 ? dropHereWidget() : Container();
          },
          onAcceptWithDetails: (details) {
            setState(() {
              droppingTaskType = -1;
            });
            // TODO add task at start of taskType today
          },
          onWillAcceptWithDetails: (details) {
            droppingTaskType = 0;
            return true;
          },
          onLeave: (data) {
            droppingTaskType = -1;
          },
        ),
      ],
    );
  }

// TODO fix this
  Widget dropHereWidget() {
    return Center(
      child: Container(
        color: textDark.withOpacity(0.2),
        height: 100,
        width: 100,
        child: const Center(
          child: Text(
            "Drop here",
            style: TextStyle(
              fontFamily: fontfamily,
              color: Colors.black54,
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget tasksTomorrow() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              tasksHeaderText(TaskType.tomorrow),
              Expanded(child: Container()),
              tasksHeaderMore(1, () {}),
            ],
          ),
        ),
        tasksDivider(false),
        taskBuilder(TaskType.tomorrow),
      ],
    );
  }

  Widget tasksUpcoming() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              tasksHeaderText(TaskType.upcoming),
              Expanded(child: Container()),
              tasksHeaderMore(2, () {}),
            ],
          ),
        ),
        tasksDivider(false),
        taskBuilder(TaskType.upcoming),
      ],
    );
  }

  Widget tasksHeaderText(TaskType taskType) {
    String text = "";

    switch (taskType) {
      case TaskType.today:
        text =
            "Today (${DatabaseManager.tasksTodayLeft} left • ${getStringFromMinutes(DatabaseManager.tasksTodayDurationMinutes)})";
        break;
      case TaskType.tomorrow:
        text =
            "Tomorrow (${DatabaseManager.tasksTomorrowLeft} left • ${getStringFromMinutes(DatabaseManager.tasksTomorrowDurationMinutes)})";
        break;
      case TaskType.upcoming:
        text = "Upcoming (${DatabaseManager.tasksUpcoming.length})";
        break;
    }

    return Text(
      text,
      style: TextStyle(
        fontFamily: fontfamily,
        color: textDark.withOpacity(0.7),
        fontSize: 18.0,
      ),
    );
  }

  Widget tasksHeaderMore(int index, Function onClick) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          hoveringTasksMoreOptions = index;
        });
      },
      onExit: (event) {
        setState(() {
          hoveringTasksMoreOptions = -1;
        });
      },
      child: GestureDetector(
        onTap: onClick(),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color:
                hoveringTasksMoreOptions == index ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Icon(
            Icons.more_horiz_rounded,
            color: textDark.withOpacity(0.7),
            size: 26.0,
          ),
        ),
      ),
    );
  }

  Widget taskBuilder(TaskType taskType) {
    int length = taskType == TaskType.today
        ? DatabaseManager.tasksToday.length
        : taskType == TaskType.tomorrow
            ? DatabaseManager.tasksTomorrow.length
            : DatabaseManager.tasksUpcoming.length;

    if (length == 0) {
      String noTasksMessage = "all tasks completed 🚀";

      // if (taskType == TaskType.today) {
      //   List<String> noTasksMessages = [
      //     "all tasks completed 🚀",
      //     "no more tasks here 🚀",
      //     "you're all set 🥳",
      //   ];
      //   noTasksMessage =
      //       noTasksMessages[Random().nextInt(noTasksMessages.length)];
      // } else if (taskType == TaskType.tomorrow) {
      //   List<String> noTasksMessages = [
      //     "no plans for tomorrow 🚀",
      //   ];
      //   noTasksMessage =
      //       noTasksMessages[Random().nextInt(noTasksMessages.length)];
      // } else if (taskType == TaskType.upcoming) {
      //   noTasksMessage = "no tasks scheduled 🚀";
      // }

      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                noTasksMessage,
                style: TextStyle(
                  fontFamily: fontfamily,
                  color: textDark.withOpacity(0.3),
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: length,
        itemBuilder: (BuildContext context, int index) {
          return taskWidget(
            taskType == TaskType.today
                ? DatabaseManager.tasksToday[index]
                : taskType == TaskType.tomorrow
                    ? DatabaseManager.tasksTomorrow[index]
                    : DatabaseManager.tasksUpcoming[index],
            taskType,
          );
        },
      ),
    );
  }

  String highlightedTaskName = "";

  Widget taskWidget(TaskItem taskItem, TaskType taskType) {
    return DragTarget<TaskItem>(
      builder: (BuildContext context, List<Object?> candidateData,
          List<dynamic> rejectedData) {
        return Draggable<TaskItem>(
          data: taskItem,
          feedback: SizedBox(
            height: 30,
            width: 250,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(100, 207, 207, 207),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: taskWidgetRowView(taskItem),
            ),
          ),
          childWhenDragging: Container(),
          child: Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onDoubleTap: () async {
                    await DatabaseManager.taskCompletionState(
                        taskItem.toJson());
                    setState(() {
                      DatabaseManager.loadData();
                    });
                  },
                  child: Tooltip(
                    waitDuration: taskHoverDuration,
                    preferBelow: false,
                    decoration:
                        BoxDecoration(color: textDark.withOpacity(0.35)),
                    message: taskItem.task,
                    child: Container(
                      child: taskWidgetRowView(taskItem),
                    ),
                  ),
                ),
              ),
              tasksDivider(highlightedTaskName == taskItem.task),
            ],
          ),
        );
      },
      onWillAcceptWithDetails: (data) {
        if (highlightedTaskName != taskItem.task) {
          setState(() {
            highlightedTaskName = taskItem.task;
          });
        }
        return true;
      },
      onAcceptWithDetails: (data) {
        // TODO update database
        setState(() {
          highlightedTaskName = "";
        });
      },
      onLeave: (data) {
        setState(() {
          highlightedTaskName = "";
        });
      },
    );
  }

  Widget taskWidgetRowView(TaskItem taskItem) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Row(
        children: [
          Container(width: 2.0),
          GestureDetector(
            child: Icon(
              Icons.drag_indicator_outlined,
              color: textDark.withOpacity(0.7),
              size: 18.0,
            ),
          ),
          Container(width: 4.0),
          Expanded(
            child: Text(
              taskItem.task,
              maxLines: maxLinesTaskView,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: fontfamily,
                color: taskCategoryColors[taskItem.colorIndex],
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                height: 1,
                decoration: taskItem.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: taskCategoryColors[taskItem.colorIndex],
              ),
            ),
          ),
          Text(
            getStringFromMinutes(taskItem.minsRequired),
            style: TextStyle(
              fontFamily: fontfamily,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
              color: textDark.withOpacity(0.7),
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget tasksDivider(bool isHighlighted) {
    return Container(
      height: 1.0,
      color: isHighlighted ? primary : textDark.withOpacity(0.1),
    );
  }

  String getStringFromMinutes(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;

    String out = "";

    if (hours > 0) {
      out += "${hours}h ";
    }
    if (mins > 0) {
      out += "${mins}m";
    }

    return out;
  }
}
