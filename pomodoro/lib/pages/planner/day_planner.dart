import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:dayplanner/pages/helpers/database_manager.dart';
import 'package:dayplanner/pages/planner/planner_section_item.dart';
import 'package:dayplanner/pages/planner/planner_section_slot_item.dart';
import 'package:dayplanner/pages/tasks/task_item.dart';
import 'package:dayplanner/variables/colors.dart';
import 'package:dayplanner/variables/integers.dart';
import 'package:dayplanner/variables/strings.dart';

class DayPlanner extends StatefulWidget {
  final Function notifyParent;
  const DayPlanner({super.key, required this.notifyParent});

  @override
  State<DayPlanner> createState() => _DayPlannerState();
}

class _DayPlannerState extends State<DayPlanner> {
  List<SectionItem> items = DatabaseManager.plannerSections;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        dayPlannerTemplate(items),
        divider(),
        dayPlannerList(),
        dayPlannerNewSlot(),
      ],
    );
  }

  SectionItem? selectedTemplate;

  Widget dayPlannerTemplate(List<SectionItem> items) {
    if (selectedTemplate == null && items.isNotEmpty) {
      selectedTemplate = items[0];
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(width: 8.0),
          templateSelector(items),
          Expanded(child: Container()),
          addNewTemplate(),
        ],
      ),
    );
  }

  Widget templateSelector(List<SectionItem> items) {
    return DropdownButton<SectionItem>(
      value: selectedTemplate,
      hint: const Text('Select a Template...'),
      dropdownColor: Colors.white,
      items: items.map((SectionItem item) {
        return DropdownMenuItem<SectionItem>(
          value: item,
          child: Text(item.name),
        );
      }).toList(),
      onChanged: (SectionItem? newValue) {
        setState(() {
          selectedTemplate = newValue;
        });
      },
    );
  }

  TextEditingController newTemplateNameController = TextEditingController();

  Widget addNewTemplate() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: background,
              contentPadding: const EdgeInsets.all(0),
              content: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(12.0),
                    height: MediaQuery.of(context).size.height / 3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          addNewTemplateTextField(),
                          Container(height: 16.0),
                          addNewTemplateButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(6.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: textDark.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: background,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  Widget addNewTemplateTextField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: newTemplateNameController,
        cursorColor: textDark,
        style: const TextStyle(
          fontFamily: fontfamily,
          color: textDark,
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          hintText: "name for the template...",
          hintStyle: TextStyle(
            fontFamily: fontfamily,
            color: textDark.withOpacity(0.25),
            fontSize: 18.0,
          ),
        ),
        onSubmitted: (value) {
          addNewTemplateFunc();
        },
      ),
    );
  }

  void addNewTemplateFunc() {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    SectionItem newTemplate = SectionItem(
      id: Random().nextInt(10000),
      name: newTemplateNameController.text,
      slots: [],
    );

    DatabaseManager.addSection(newTemplate);

    newTemplateNameController.clear();
    widget.notifyParent();
  }

  Widget addNewTemplateButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: addNewTemplateFunc,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: textDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: const Text(
            "Add New Template",
            style: TextStyle(
              fontFamily: fontfamily,
              color: background,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget dayPlannerList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: dayPlannerTemplateView(),
      ),
    );
  }

  Widget dayPlannerTemplateView() {
    if (selectedTemplate == null) return Container();

    SectionItem item = selectedTemplate!;

    if (item.slots.isEmpty) {
      return Text(
        "- no slot -",
        style: TextStyle(
          fontFamily: fontfamily,
          color: textDark.withOpacity(0.3),
          fontSize: 16.0,
        ),
      );
    }

    return ListView.builder(
      itemCount: item.slots.length,
      itemBuilder: (context, index) {
        return dayPlannerSlot(item.slots[index]);
      },
    );
  }

  // SLOTS-------------------------------------------------------------------------------------------------------------

  String slotHovering = "";

  Widget dayPlannerSlot(String slot) {
    SectionSlotItem slotItem = SectionSlotItem.fromJson(jsonDecode(slot));

    return DragTarget<TaskItem>(
      builder: (BuildContext context, List<TaskItem?> candidateData,
          List<dynamic> rejectedData) {
        return GestureDetector(
          onSecondaryTap: () async {
            await DatabaseManager.removeSectionSlot(
                selectedTemplate!, SectionSlotItem.fromJson(jsonDecode(slot)));
            await DatabaseManager.loadData();
            widget.notifyParent();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 6.0),
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            decoration: BoxDecoration(
              // color:
              //     slotHovering == slot ? textDark.withOpacity(0.1) : textLight,
              color:
                  slotHovering == slot ? textDark.withOpacity(0.1) : background,
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${slotItem.startTime}-${slotItem.endTime}",
                      style: const TextStyle(
                        fontFamily: fontfamily,
                        color: textDark,
                        fontSize: 14.0,
                      ),
                    ),
                    Container(
                      width: 16.0,
                    ),
                    slotItem.canAddTasks
                        ? Text(
                            formatTimeFromMinutes(
                                slotTasksDurationMinutes(slotItem)),
                            style: TextStyle(
                              fontFamily: fontfamily,
                              color: Color.lerp(
                                Colors.green[200],
                                Colors.red[200],
                                slotGradientValue(slotItem),
                              ),
                              fontSize: 14.0,
                            ),
                          )
                        : Text(
                            slotItem.header,
                            style: const TextStyle(
                              fontFamily: fontfamily,
                              color: textDark,
                              fontSize: 16.0,
                              // fontWeight: FontWeight.w500,
                            ),
                          ),
                    Expanded(child: Container()),
                    Text(
                      formatTimeFromMinutes(getDurationInMinutes(
                                  slotItem.startTime, slotItem.endTime)) ==
                              ""
                          ? "0m"
                          : formatTimeFromMinutes(getDurationInMinutes(
                              slotItem.startTime, slotItem.endTime)),
                      style: const TextStyle(
                        fontFamily: fontfamily,
                        color: textDark,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                slotItem.canAddTasks ? slotItemTasks(slotItem) : Container(),
              ],
            ),
          ),
        );
      },
      onWillAcceptWithDetails: (details) {
        if (slotItem.canAddTasks) {
          slotHovering = slot;
        }
        return true;
      },
      onLeave: (data) {
        setState(() {
          slotHovering = "";
        });
      },
      onAcceptWithDetails: (details) {
        if (slotItem.canAddTasks) {
          TaskItem newTask = details.data;
          DatabaseManager.removeTask(newTask, newTask.taskType);

          newTask.taskType = TaskType.forceadd;

          List<String> updatedTasks = slotItem.tasks;
          updatedTasks.add(newTask.toJson());
          DatabaseManager.updateSectionSlots(
              selectedTemplate!, slotItem, updatedTasks);
          slotHovering = "";

          widget.notifyParent();
        }
      },
    );
  }

  Widget slotItemTasks(SectionSlotItem slotItem) {
    if (slotItem.tasks.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 4.0, left: 6.0, bottom: 4.0),
        child: Row(
          children: [
            Icon(
              Icons.arrow_right_rounded,
              color: textDark.withOpacity(0.3),
              size: 16.0,
            ),
            Text(
              "drop tasks here...",
              style: TextStyle(
                fontFamily: fontfamily,
                color: textDark.withOpacity(0.3),
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: min(31.0 * slotItem.tasks.length, 93.0),
      child: ListView.builder(
        itemCount: slotItem.tasks.length,
        itemBuilder: (context, index) {
          TaskItem taskItem =
              TaskItem.fromJson(jsonDecode(slotItem.tasks[index]));
          return Draggable<TaskItem>(
            data: taskItem,
            feedback: SizedBox(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(100, 207, 207, 207),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: taskWidgetRowView(taskItem, slotItem, 1.0, false),
              ),
            ),
            childWhenDragging: taskWidgetRowView(taskItem, slotItem, 0.1, true),
            child: taskWidgetRowView(taskItem, slotItem, 1.0, true),
            onDragStarted: () {
              DatabaseManager.removeTaskFromSlot(
                  selectedTemplate!, slotItem, taskItem);
              widget.notifyParent();
            },
          );
        },
      ),
    );
  }

  Widget taskWidgetRowView(
    TaskItem taskItem,
    SectionSlotItem slotItem,
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
              await DatabaseManager.slotTaskCompletionStatus(
                  selectedTemplate!, slotItem, taskItem);
              await DatabaseManager.loadData();
              widget.notifyParent();
            },
            onSecondaryTap: () async {
              // Delete Task
              await DatabaseManager.removeTaskFromSlot(
                  selectedTemplate!, slotItem, taskItem);
              await DatabaseManager.loadData();
              widget.notifyParent();
            },
            child: Tooltip(
              waitDuration: taskHoverDuration,
              preferBelow: false,
              decoration: BoxDecoration(color: textDark.withOpacity(0.35)),
              message: taskItem.task,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    children: [
                      Container(width: 2.0),
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_right_rounded,
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
                        formatTimeFromMinutes(taskItem.minsRequired),
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

  bool canAddTasks = false;
  final newSlotNameController = TextEditingController();
  String newSlotStartTime = "";
  String newSlotEndTime = "";

  Widget dayPlannerNewSlot() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          await showDialog<void>(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    contentPadding: const EdgeInsets.all(0),
                    content: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(12.0),
                          height: MediaQuery.of(context).size.height / 2,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Create New Slot:",
                                  style: TextStyle(
                                    fontFamily: fontfamily,
                                    color: textDark.withOpacity(0.25),
                                    fontSize: 24.0,
                                  ),
                                ),
                                Container(height: 16.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    addNewSlotTimeSelector(true, setState),
                                    Container(width: 16.0),
                                    addNewSlotTimeSelector(false, setState),
                                  ],
                                ),
                                Container(height: 16.0),
                                addNewSlotNameTextField(),
                                Text(
                                  "(if no tasks are to be added)",
                                  style: TextStyle(
                                    fontFamily: fontfamily,
                                    color: textDark.withOpacity(0.2),
                                    fontSize: 12.0,
                                  ),
                                ),
                                Container(height: 16.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Add Tasks?",
                                      style: TextStyle(
                                        fontFamily: fontfamily,
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    Container(width: 16.0),
                                    addNewSlotCanAddTasks(setState),
                                  ],
                                ),
                                Container(height: 32.0),
                                addNewSlotButton(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_rounded,
                color: Colors.black.withOpacity(0.5),
                size: 20.0,
              ),
              Container(width: 4.0),
              Text(
                "add new slot",
                style: TextStyle(
                  fontFamily: fontfamily,
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addNewSlotCanAddTasks(void Function(void Function()) setState) {
    return Checkbox(
      value: canAddTasks,
      onChanged: (value) {
        setState(() {
          canAddTasks = value ?? false;
        });
      },
    );
  }

  Widget addNewSlotNameTextField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: newSlotNameController,
        cursorColor: textDark,
        style: const TextStyle(
          fontFamily: fontfamily,
          color: textDark,
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          hintText: "name for the slot...",
          hintStyle: TextStyle(
            fontFamily: fontfamily,
            color: textDark.withOpacity(0.25),
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget addNewSlotTimeSelector(
      bool startTime, void Function(void Function()) setState) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          TimeOfDay initialTime = const TimeOfDay(hour: 0, minute: 0);
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: initialTime,
          );

          if (pickedTime != null) {
            setState(() {
              if (startTime) {
                newSlotStartTime =
                    "${pickedTime.hour}:${pickedTime.minute == 0 ? "00" : "${pickedTime.minute}"}";
              } else {
                newSlotEndTime =
                    "${pickedTime.hour}:${pickedTime.minute == 0 ? "00" : "${pickedTime.minute}"}";
              }
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            startTime
                ? (newSlotStartTime.isEmpty ? "start time" : newSlotStartTime)
                : (newSlotEndTime.isEmpty ? "end time" : newSlotEndTime),
            style: TextStyle(
              fontFamily: fontfamily,
              color: textDark.withOpacity(0.7),
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget addNewSlotButton() {
    return ElevatedButton(
      onPressed: () async {
        if (selectedTemplate == null) {
          return;
        }

        List<String> slots = selectedTemplate!.slots;

        SectionSlotItem newSlot = SectionSlotItem(
          id: Random().nextInt(100000),
          startTime: newSlotStartTime,
          endTime: newSlotEndTime,
          canAddTasks: canAddTasks,
          header: newSlotNameController.text,
          tasks: [],
        );

        TimeOfDay newSlotStartTimeOfDay = TimeOfDay(
          hour: int.parse(newSlotStartTime.split(':')[0]),
          minute: int.parse(newSlotStartTime.split(':')[1]),
        );

        int insertIndex = slots.indexWhere((slotStr) {
          SectionSlotItem slot = SectionSlotItem.fromJson(jsonDecode(slotStr));
          TimeOfDay slotStartTimeOfDay = TimeOfDay(
            hour: int.parse(slot.startTime.split(':')[0]),
            minute: int.parse(slot.startTime.split(':')[1]),
          );
          return newSlotStartTimeOfDay.hour < slotStartTimeOfDay.hour ||
              (newSlotStartTimeOfDay.hour == slotStartTimeOfDay.hour &&
                  newSlotStartTimeOfDay.minute < slotStartTimeOfDay.minute);
        });

        if (insertIndex == -1) {
          // If no such position is found, append to the end
          slots.add(newSlot.toJson());
        } else {
          slots.insert(insertIndex, newSlot.toJson());
        }

        await DatabaseManager.updateSlots(selectedTemplate!, slots);

        widget.notifyParent();

        if (newSlotNameController.text.isNotEmpty) {
          newSlotNameController.clear();
          newSlotStartTime = "";
          newSlotEndTime = "";
          canAddTasks = false;
        }
        // ignore: use_build_context_synchronously
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      child: Text(
        'Add Slot',
        style: TextStyle(
          fontFamily: fontfamily,
          color: textDark.withOpacity(0.7),
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget divider() {
    return Container(
      height: 1.0,
      color: textDark.withOpacity(0.1),
    );
  }

  int getDurationInMinutes(String startTime, String endTime) {
    TimeOfDay start = stringToTime(startTime);
    TimeOfDay end = stringToTime(endTime);
    return (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
  }

  TimeOfDay stringToTime(String time) {
    try {
      List<String> parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  String formatTimeFromMinutes(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;

    String out = "";

    if (hours == 0 && mins == 0) out += "0m";

    if (hours > 0) {
      out += "${hours}h ";
    }
    if (mins > 0) {
      out += "${mins}m";
    }

    return out;
  }

  int slotTasksDurationMinutes(SectionSlotItem item) {
    int duration = 0;
    for (String task in item.tasks) {
      duration += TaskItem.fromJson(jsonDecode(task)).minsRequired;
    }
    return duration;
  }

  double slotGradientValue(SectionSlotItem item) {
    int tasksDuration = slotTasksDurationMinutes(item);
    int availableDuration = getDurationInMinutes(item.startTime, item.endTime);

    if (tasksDuration > availableDuration) return 1.0;

    return tasksDuration / availableDuration;
  }
}
