import 'dart:convert';
import 'dart:ui';
import 'package:task_management/tasks/domain/models/users.dart';

class Tasks {
  // static int _idCounter = 0;
  int? id;
  String taskName;
  bool isCompleted;
  DateTime? dateTime;
  final String? interval;
  final Users? user;
  String? taskHours;
  DateTime createdAt;

  Tasks({
    this.id,
    required this.taskName,
    this.isCompleted = false,
    this.dateTime,
    this.interval,
    this.user,
    this.taskHours,
    required this.createdAt,
  }) {
    // if (id == 0) {
    //   _idCounter++;
    //   id = _idCounter;
    // }
  }

  factory Tasks.fromMap(Map<String, dynamic> map) {
    return Tasks(
        id: map['id'] ?? 0,
        taskName: map['taskName'],
        isCompleted: map['isCompleted'] ?? false,
        dateTime:
            map['dateTime'] != null ? DateTime.parse(map['dateTime']) : null,
        interval: map['interval'],
        user: map['user'],
        taskHours: map['taskHours'],
        createdAt: map['createdAt']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'isCompleted': isCompleted ? 1 : 0,
      'dateTime': dateTime?.toIso8601String(),
      'interval': interval,
      // 'user': user?.userId,
      // 'taskHours': taskHours,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapWithOutId() {
    return {
      // 'id': id,
      'taskName': taskName,
      'isCompleted': isCompleted ? 1 : 0,
      'dateTime': dateTime?.toString(),
      'interval': interval,
      // 'taskHours': taskHours,
    };
  }

  Map<String, dynamic> toMapWithId() {
    return {
      'id': id,
      'taskName': taskName,
      'isCompleted': isCompleted ? 1 : 0,
      'dateTime': dateTime?.toIso8601String(),
      'interval': interval,
      // 'taskHours': taskHours,
    };
  }

  factory Tasks.fromJson(String jsonString) {
    final Map<String, dynamic> map = json.decode(jsonString);
    return Tasks(
      id: map['id'],
      taskName: map['taskName'],
      isCompleted: map['isCompleted'] ?? false,
      dateTime:
          map['dateTime'] != null ? DateTime.parse(map['dateTime']) : null,
      interval: map['interval'],
      taskHours: map['taskHours'],
      createdAt: map['createdAt'],
    );
  }

  String toJson() {
    return json.encode({
      'id': id,
      'taskName': taskName,
      'isCompleted': isCompleted,
      'dateTime': dateTime?.toIso8601String(),
      'interval': interval,
      'taskHours': taskHours,
      'createdAt': createdAt.toIso8601String(),
    });
  }

  List<Object?> get props => [id, taskName, isCompleted, dateTime, createdAt];

  Tasks copyWith({
    int? id,
    int? userId,
    String? taskName,
    Color? color,
    bool? isCompleted,
    DateTime? dateTime,
    String? interval,
  }) {
    return Tasks(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      isCompleted: isCompleted ?? this.isCompleted,
      dateTime: dateTime ?? this.dateTime,
      interval: interval ?? this.interval,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, taskName: $taskName, isCompleted: $isCompleted, dateTime: $dateTime, interval: $interval,createdAt: $createdAt}';
  }

  // static List<Tasks> taskList() {
  //   return [];
  // }
}
