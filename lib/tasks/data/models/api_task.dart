class Task {
  final int id;
  final String taskName;
  bool isCompleted;

  Task({
    required this.id,
    required this.taskName,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      taskName: json['TaskName'] as String,
      isCompleted: json['Is Completed'] as bool? ?? false,
    );
  }
}
