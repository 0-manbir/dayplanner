import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro/pages/helpers/database_manager.dart';
import 'package:pomodoro/pages/tasks/taskItem.dart';
import 'package:pomodoro/variables/colors.dart';
import 'package:pomodoro/variables/strings.dart';

class NewTaskWidget extends StatefulWidget {
  const NewTaskWidget({super.key});

  @override
  State<NewTaskWidget> createState() => _NewTaskWidgetState();
}

class _NewTaskWidgetState extends State<NewTaskWidget> {
  final TextEditingController newTaskController = TextEditingController();

  int _selectedTimeIndex = 5;

  final Map<String, int> timeDragStrings = {
    '1m': 1,
    '5m': 5,
    '10m': 10,
    '15m': 15,
    '20m': 20,
    '25m': 25,
    '30m': 30,
    '45m': 45,
    '1h': 60,
    '1h 15m': 75,
    '1h 30m': 90,
    '2h': 120,
    '2h 15m': 135,
    '2h 30m': 150,
  };

  String getStringFromIndex(int index) {
    return timeDragStrings.keys.elementAt(index);
  }

  int getMinutesFromIndex(int index) {
    return timeDragStrings.values.elementAt(index);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    newTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: textLight,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: taskName(),
              ),
              Container(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    taskTimeWidget(constraints.maxWidth),
                    Container(width: 4.0),
                    addTaskButton(),
                    Container(width: 4.0),
                    dragTaskButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    ;
  }

  Widget taskName() {
    return TextField(
      controller: newTaskController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      cursorColor: textDark,
      style: const TextStyle(
        fontFamily: fontfamily,
        color: textDark,
        fontSize: 18.0,
      ),
      decoration: InputDecoration(
        hintText: "new task (ctrl + n)",
        hintStyle: TextStyle(
          fontFamily: fontfamily,
          color: textDark.withOpacity(0.25),
          fontSize: 18.0,
        ),
      ),
      onSubmitted: (value) {},
    );
  }

  Widget taskTimeWidget(double maxWidth) {
    return Row(
      children: [
        getTimeNavButton(true),
        Container(
          width: maxWidth * 0.32,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Text(
              getStringFromIndex(_selectedTimeIndex),
              style: TextStyle(
                fontFamily: fontfamily,
                color: textDark.withOpacity(0.5),
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        getTimeNavButton(false),
      ],
    );
  }

  int navButtonHovering = -1;

  Widget getTimeNavButton(bool isLeft) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          navButtonHovering = isLeft ? 0 : 1;
        });
      },
      onExit: (event) {
        setState(() {
          navButtonHovering = -1;
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isLeft) {
              if (_selectedTimeIndex != 1) {
                _selectedTimeIndex--;
              }
            } else {
              if (_selectedTimeIndex != timeDragStrings.length - 1) {
                _selectedTimeIndex++;
              }
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.all(5.0),
          width: 30.0,
          height: 30.0,
          decoration: BoxDecoration(
            color: navButtonHovering == -1 ||
                    navButtonHovering == 0 && !isLeft ||
                    navButtonHovering == 1 && isLeft
                ? textLight
                : textDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Center(
            child: Icon(
              isLeft ? Icons.arrow_left_rounded : Icons.arrow_right_rounded,
              color: textDark.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget addTaskButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: () {
            // TODO add button clicked
            // TaskItem newTask = TaskItem(
            //   task: "",
            //   minsRequired: 0,
            //   taskType: TaskType.upcoming,
            //   isDone: false,
            // );
            // tasksUpcoming.add(newTask);
            // saveDataLocal();
          },
          child: Icon(
            Icons.today,
            color: textDark.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget dragTaskButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: () {
            // TODO drag task button clicked
          },
          child: Icon(
            Icons.drag_indicator_rounded,
            color: textDark.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  void addTask() {
    if (newTaskController.text == "") {
      return;
    }
    String newTask = TaskItem(
      task: newTaskController.text,
      minsRequired: getMinutesFromIndex(_selectedTimeIndex),
      taskType: TaskType.today,
      isDone: false,
    ).toJson();
  }
}
