class TaskCardModel {
  String id;
  String title;
  String description;
  final bool isDone;

  TaskCardModel({required this.id, required this.title, this.description = '',required this.isDone});

  factory TaskCardModel.fromJson(Map<String, dynamic> json) => TaskCardModel(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        isDone: json['isDone'] ?? false,

      );
  TaskCardModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
  }) {
    return TaskCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isDone': isDone,
  };
}
