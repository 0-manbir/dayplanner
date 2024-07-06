import 'dart:convert';

class SectionSlotItem {
  int id = 0;
  String startTime;
  String endTime;
  bool canAddTasks = false;
  String header = "{Empty}";

  SectionSlotItem({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.canAddTasks,
    required this.header,
  });

  String toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'startTime': startTime,
      'endTime': endTime,
      'canAddTasks': canAddTasks,
      'header': header,
    };
    return jsonEncode(data);
  }

  factory SectionSlotItem.fromJson(Map<String, dynamic> data) {
    return SectionSlotItem(
      id: data['id'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      canAddTasks: data['canAddTasks'],
      header: data['header'],
    );
  }
}
