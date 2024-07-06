import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pomodoro/pages/planner/planner_section_item.dart';
import 'package:pomodoro/variables/colors.dart';
import 'package:pomodoro/variables/strings.dart';

class DayPlanner extends StatefulWidget {
  const DayPlanner({super.key});

  @override
  State<DayPlanner> createState() => _DayPlannerState();
}

class _DayPlannerState extends State<DayPlanner> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        dayPlannerTemplate(),
        divider(),
        dayPlannerList(),
      ],
    );
  }

  late SectionItem selectedTemplate;

  Widget dayPlannerTemplate() {
    List<SectionItem> items = [];

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Container()),
            addNewTemplate(),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          DropdownButton<SectionItem>(
            value: selectedTemplate,
            hint: Text('Select an item'),
            items: items.map((SectionItem item) {
              return DropdownMenuItem<SectionItem>(
                value: item,
                child: Text(item.name),
              );
            }).toList(),
            onChanged: (SectionItem? newValue) {
              setState(() {
                selectedTemplate = newValue!;
              });
            },
          ),
          Expanded(child: Container()),
          addNewTemplate(),
        ],
      ),
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
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: textDark.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: background,
            size: 26.0,
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

          // TODO: Create new template, and save it

          newTemplateNameController.clear();
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
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Container(),
    );
  }

  Widget divider() {
    return Container(
      height: 1.0,
      color: textDark.withOpacity(0.1),
    );
  }
}
