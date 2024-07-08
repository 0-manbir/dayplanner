import 'package:flutter/material.dart';
import 'package:dayplanner/pages/helpers/database_manager.dart';
import 'package:dayplanner/pages/planner/day_planner.dart';
import 'package:dayplanner/variables/integers.dart';
import 'package:window_manager/window_manager.dart';
import 'package:dayplanner/pages/tasks/new_task_widget.dart';
import 'package:dayplanner/pages/tasks/task_item.dart';
import 'package:dayplanner/variables/colors.dart';
import 'package:dayplanner/variables/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setSkipTaskbar(false);
    await windowManager.setOpacity(1);
    await windowManager.setAlwaysOnTop(false);
    await windowManager.center();
    await windowManager.setTitle("dayplanner Timer");
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
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            appHeaderText,
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
          newSession(),
          rowDivider(),
          tasksToday(),
          rowDivider(),
          tasksTomorrow(),
          rowDivider(),
          tasksUpcoming(),
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
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: DayPlanner(
              notifyParent: refresh,
            ),
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {
      DatabaseManager.loadData();
    });
  }

  int willAcceptTaskIndex = -1;

  Widget tasksToday() {
    return Expanded(
      child: DragTarget<TaskItem>(
        builder: (BuildContext context, List<TaskItem?> candidateData,
            List<dynamic> rejectedData) {
          return Column(
            children: [
              Container(
                color: willAcceptTaskIndex == 0
                    ? textDark.withOpacity(0.2)
                    : background,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    tasksHeaderText(TaskType.today),
                    Expanded(child: Container()),
                    tasksHeaderMore(0),
                  ],
                ),
              ),
              tasksDivider(),
              taskBuilder(TaskType.today),
            ],
          );
        },
        onWillAcceptWithDetails: (data) => onWidgetWillDrop(0),
        onAcceptWithDetails: (data) => onWidgetDrop(data, TaskType.today),
        onLeave: (data) => onWidgetDragCancel(),
      ),
    );
  }

  Widget tasksTomorrow() {
    return Expanded(
      child: DragTarget<TaskItem>(
        builder: (BuildContext context, List<TaskItem?> candidateData,
            List<dynamic> rejectedData) {
          return Column(
            children: [
              Container(
                color: willAcceptTaskIndex == 1
                    ? textDark.withOpacity(0.2)
                    : background,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    tasksHeaderText(TaskType.tomorrow),
                    Expanded(child: Container()),
                    tasksHeaderMore(1),
                  ],
                ),
              ),
              tasksDivider(),
              taskBuilder(TaskType.tomorrow),
            ],
          );
        },
        onWillAcceptWithDetails: (data) => onWidgetWillDrop(1),
        onAcceptWithDetails: (data) => onWidgetDrop(data, TaskType.tomorrow),
        onLeave: (data) => onWidgetDragCancel(),
      ),
    );
  }

  Widget tasksUpcoming() {
    return Expanded(
      child: DragTarget<TaskItem>(
        builder: (BuildContext context, List<TaskItem?> candidateData,
            List<dynamic> rejectedData) {
          return Column(
            children: [
              Container(
                color: willAcceptTaskIndex == 2
                    ? textDark.withOpacity(0.2)
                    : background,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    tasksHeaderText(TaskType.upcoming),
                    Expanded(child: Container()),
                    tasksHeaderMore(2),
                  ],
                ),
              ),
              tasksDivider(),
              taskBuilder(TaskType.upcoming),
              Expanded(child: Container()),
              NewTaskWidget(
                notifyParent: refresh,
              ),
            ],
          );
        },
        onWillAcceptWithDetails: (data) => onWidgetWillDrop(2),
        onAcceptWithDetails: (data) => onWidgetDrop(data, TaskType.upcoming),
        onLeave: (data) => onWidgetDragCancel(),
      ),
    );
  }

  void onWidgetDrop(
      DragTargetDetails<TaskItem> data, TaskType dropInType) async {
    TaskItem taskItem = data.data;
    if (data.data.taskType != dropInType ||
        data.data.taskType == TaskType.forceadd) {
      await DatabaseManager.removeTask(taskItem, taskItem.taskType);
      await DatabaseManager.addTask(taskItem, dropInType);
    }

    setState(() {
      DatabaseManager.loadData();
      willAcceptTaskIndex = -1;
    });
  }

  void onWidgetDragCancel() {
    setState(() {
      willAcceptTaskIndex = -1;
    });
  }

  bool onWidgetWillDrop(int index) {
    if (willAcceptTaskIndex != index) {
      setState(() {
        willAcceptTaskIndex = index;
      });
    }
    return true;
  }

  Widget tasksHeaderText(TaskType taskType) {
    String totalMinutesToday =
        getStringFromMinutes(DatabaseManager.tasksTodayDurationMinutes);
    String totalMinutesTomorrow =
        getStringFromMinutes(DatabaseManager.tasksTomorrowDurationMinutes);
    String text = "";

    switch (taskType) {
      case TaskType.today:
        text =
            "Today (${DatabaseManager.tasksTodayLeft} left • ${totalMinutesToday == "" ? "0m" : totalMinutesToday})";
        break;
      case TaskType.tomorrow:
        text =
            "Tomrw (${DatabaseManager.tasksTomorrowLeft} left • ${totalMinutesTomorrow == "" ? "0m" : totalMinutesTomorrow})";
        break;
      case TaskType.upcoming:
        text = "Upcoming (${DatabaseManager.tasksUpcoming.length})";
        break;

      case TaskType.forceadd:
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

  Widget tasksHeaderMore(int index) {
    return PopupMenuButton<int>(
      tooltip: "more options",
      color: background,
      onSelected: (value) {
        TaskType taskType = index == 0
            ? TaskType.today
            : (index == 1 ? TaskType.tomorrow : TaskType.upcoming);
        switch (value) {
          case 0:
            DatabaseManager.removeDone(taskType);
            setState(() {
              DatabaseManager.loadData();
            });
            break;
          case 1:
            DatabaseManager.removeAll(taskType);
            setState(() {
              DatabaseManager.loadData();
            });
            break;
          case 2:
            DatabaseManager.markUndone(taskType);
            setState(() {
              DatabaseManager.loadData();
            });
            break;
        }
      },
      itemBuilder: (context) => [
        tasksHeaderMoreWidget(0, "Remove Done"),
        tasksHeaderMoreWidget(1, "Remove All"),
        tasksHeaderMoreWidget(2, "Mark All Undone"),
      ],
      icon: Icon(
        Icons.more_vert_rounded,
        color: textDark.withOpacity(0.7),
        size: 20.0,
      ),
    );
  }

  PopupMenuEntry<int> tasksHeaderMoreWidget(int value, String text) {
    return PopupMenuItem(
      value: value,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: fontfamily,
          fontWeight: FontWeight.normal,
          fontSize: 16.0,
        ),
      ),
    );
  }

  Widget taskBuilder(TaskType taskType) {
    int length = getListFromTaskType(taskType).length;

    if (length == 0) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          noTasksText,
          style: TextStyle(
            fontFamily: fontfamily,
            color: textDark.withOpacity(0.3),
            fontSize: 16.0,
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: length,
        itemBuilder: (BuildContext context, int index) {
          return taskWidget(
            getListFromTaskType(taskType)[index],
            taskType,
          );
        },
      ),
    );
  }

  Widget taskWidget(TaskItem taskItem, TaskType taskType) {
    return Draggable<TaskItem>(
      data: taskItem,
      feedback: SizedBox(
        width: 250,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(100, 207, 207, 207),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: taskWidgetRowView(taskItem, 1.0, false),
        ),
      ),
      childWhenDragging: taskWidgetRowView(taskItem, 0.1, true),
      child: taskWidgetRowView(taskItem, 1.0, true),
    );
  }

  Widget taskWidgetRowView(
    TaskItem taskItem,
    double opacity,
    bool taskDividerVisible,
  ) {
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onDoubleTap: () async {
              // Task Completed
              await DatabaseManager.taskCompletionState(taskItem);
              setState(() {
                DatabaseManager.loadData();
              });
            },
            onSecondaryTap: () async {
              // Delete Task
              await DatabaseManager.removeTask(taskItem, taskItem.taskType);
              setState(() {
                DatabaseManager.loadData();
              });
            },
            child: Tooltip(
              waitDuration: taskHoverDuration,
              preferBelow: false,
              decoration: BoxDecoration(color: textDark.withOpacity(0.35)),
              message: taskItem.task,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
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
                            decorationColor:
                                taskCategoryColors[taskItem.colorIndex],
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
                ),
              ),
            ),
          ),
        ),
        taskDividerVisible ? tasksDivider() : Container(),
      ],
    );
  }

  Widget tasksDivider() {
    return Container(
      height: 1.0,
      color: textDark.withOpacity(0.1),
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

  List<TaskItem> getListFromTaskType(TaskType taskType) {
    switch (taskType) {
      case TaskType.today:
        return DatabaseManager.tasksToday;
      case TaskType.tomorrow:
        return DatabaseManager.tasksTomorrow;
      case TaskType.upcoming:
        return DatabaseManager.tasksUpcoming;
      case TaskType.forceadd:
        return [];
    }
  }
}
