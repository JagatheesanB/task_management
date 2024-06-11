class HistoryTask {
  final int? id;
  final String taskName;
  final DateTime dateTime;
  final int userId;

  HistoryTask({
    this.id,
    required this.taskName,
    required this.dateTime,
    required this.userId,
  });

  HistoryTask copyWith({
    int? id,
    String? taskName,
    DateTime? dateTime,
    int? userId,
  }) {
    return HistoryTask(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      dateTime: dateTime ?? this.dateTime,
      userId: userId ?? this.userId,
    );
  }

  factory HistoryTask.fromJson(Map<String, dynamic> json) {
    return HistoryTask(
      id: json['id'],
      taskName: json['taskName'],
      dateTime: DateTime.parse(json['dateTime']),
      userId: json['userId'],
    );
  }
}
