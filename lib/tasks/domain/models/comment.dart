class Comment {
  int? id;
  final int taskId;
  final String comment;
  // final DateTime createdAt;

  Comment({
    this.id,
    required this.taskId,
    required this.comment,
    // required this.createdAt,
  });

  Comment copyWith({
    int? id,
    int? taskId,
    String? comment,
    // DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      comment: comment ?? this.comment,
      // createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'comment': comment,
      // 'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      taskId: map['taskId'],
      comment: map['comment'],
      // createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
