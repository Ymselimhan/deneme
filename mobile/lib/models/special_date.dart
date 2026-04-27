class SpecialDate {
  final int id;
  final String title;
  final DateTime date;
  final String type;
  final String? description;
  final int coupleId;

  SpecialDate({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.description,
    required this.coupleId,
  });

  factory SpecialDate.fromJson(Map<String, dynamic> json) {
    return SpecialDate(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      description: json['description'],
      coupleId: json['coupleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'coupleId': coupleId,
    };
  }
}
