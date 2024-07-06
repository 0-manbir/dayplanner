import 'dart:convert';

class SectionItem {
  int id = 0;
  String name = "{Empty}";
  List<String> slots = [];

  SectionItem({
    required this.id,
    required this.name,
    required this.slots,
  });

  String toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'slots': slots,
    };
    return jsonEncode(data);
  }

  factory SectionItem.fromJson(Map<String, dynamic> data) {
    return SectionItem(
      id: data['id'],
      name: data['name'],
      slots: List<String>.from(data['slots']),
    );
  }
}
