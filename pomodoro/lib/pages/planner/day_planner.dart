import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pomodoro/pages/helpers/database_manager.dart';
import 'package:pomodoro/pages/planner/planner_section_item.dart';
import 'package:pomodoro/pages/planner/planner_section_slot_item.dart';
import 'package:pomodoro/variables/colors.dart';
import 'package:pomodoro/variables/strings.dart';

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
      ),
    );
  }

  Widget addNewTemplateButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();

          SectionItem newTemplate = SectionItem(
            id: Random().nextInt(10000),
            name: newTemplateNameController.text,
            slots: [],
          );

          DatabaseManager.addSection(newTemplate);

          newTemplateNameController.clear();
          widget.notifyParent();
        },
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
    // Expanded
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: dayPlannerTemplateView(selectedTemplate!),
    );
  }

  Widget dayPlannerTemplateView(SectionItem item) {
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

// Expanded
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: item.slots.length,
          itemBuilder: (context, index) {
            return dayPlannerSlot(item.slots[index]);
          },
        ),
      ),
    );
  }

  // SLOTS-------------------------------------------------------------------------------------------------------------

  Widget dayPlannerSlot(String slot) {
    SectionSlotItem slotItem = SectionSlotItem.fromJson(jsonDecode(slot));

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "${slotItem.startTime}-${slotItem.endTime}",
                style: const TextStyle(
                  fontFamily: fontfamily,
                  color: textDark,
                  fontSize: 16.0,
                ),
              ),
              // Expanded(child: Container()),
              slotItem.canAddTasks
                  ? Text(
                      "14m",
                      style: TextStyle(
                        fontFamily: fontfamily,
                        color: Colors.red[200],
                        fontSize: 16.0,
                      ),
                    )
                  : Text(
                      slotItem.header,
                      style: const TextStyle(
                        fontFamily: fontfamily,
                        color: textDark,
                        fontSize: 16.0,
                      ),
                    ),
              Text(
                "15m",
                style: const TextStyle(
                  fontFamily: fontfamily,
                  color: textDark,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),

          // Expanded(child: Container()),

          // ADD TASKS

          slotItem.canAddTasks ? Container() : Container(),
        ],
      ),
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
                          height: MediaQuery.of(context).size.height / 2.5,
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
                                    fontSize: 18.0,
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
    return GestureDetector(
      onTap: () async {
        TimeOfDay initialTime = const TimeOfDay(hour: 0, minute: 0);
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );

        if (pickedTime != null) {
          setState(() {
            if (startTime) {
              newSlotStartTime = "${pickedTime.hour}:${pickedTime.minute}";
            } else {
              newSlotEndTime = "${pickedTime.hour}:${pickedTime.minute}";
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
    );
  }

  Widget addNewSlotButton() {
    return ElevatedButton(
      onPressed: () async {
        if (selectedTemplate == null) {
          return;
        }

        List<String> slots = selectedTemplate!.slots;
        slots.add(SectionSlotItem(
                id: Random().nextInt(100000),
                startTime: newSlotStartTime,
                endTime: newSlotEndTime,
                canAddTasks: canAddTasks,
                header: newSlotNameController.text)
            .toJson());

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
}
