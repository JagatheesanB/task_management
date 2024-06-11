import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/tasks/domain/models/history.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import 'package:task_management/tasks/utils/constants/exception.dart';

import '../../domain/models/task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskHistoryNotifier extends StateNotifier<List<HistoryTask>> {
  final TaskRepository _taskRepository;

  TaskHistoryNotifier(this._taskRepository) : super([]);

  Future<void> addTaskToHistory(Tasks task, int userId) async {
    final HistoryTask historyTask = HistoryTask(
      taskName: task.taskName,
      dateTime: task.dateTime ?? DateTime.now(),
      userId: userId,
    );

    state = [...state, historyTask];

    try {
      await _taskRepository.insertTaskForHistory(task, userId);
      // print('Task added to history successfully: ${task.taskName} $userId');
    } catch (e) {
      // print('Error adding task to history: $e');
      CustomException("Something went wrong while adding history task");
    }
  }

  Future<List<HistoryTask>> getTasksFromHistoryByInterval(
      String interval, int userId) async {
    return _taskRepository.getTasksFromHistoryByInterval(interval, userId);
  }

  Future<List<HistoryTask>> getTaskHistoryByUserId(int userId) async {
    return await _taskRepository.getTaskHistoryByUserId(userId);
  }
}

final taskHistoryProvider =
    StateNotifierProvider<TaskHistoryNotifier, List<HistoryTask>>(
  (ref) => TaskHistoryNotifier(ref.watch(taskRepositoryProvider)),
);
