import 'package:riverpod/riverpod.dart';
import 'package:task_management/tasks/domain/models/completed.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/domain/repositories/task_repository.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import 'package:task_management/tasks/utils/constants/exception.dart';

class CompletedTasksNotifier extends StateNotifier<List<CompletedTask>> {
  final TaskRepository _taskRepository;

  CompletedTasksNotifier(this._taskRepository) : super([]);

  void addCompletedTask(int id, Tasks task, int seconds, int userId,DateTime dateTime) async {
    final completedTask = CompletedTask(
      id: id,
      task: task,
      seconds: seconds,
      userId: userId, dateTime: dateTime,
    );
    state = [...state, completedTask];

    try {
      // print(
      //     'Getting task to complete is ${task.taskName} with $seconds seconds');
      int id = await _taskRepository.insertCompletedTask(
          task, userId, seconds);
      task.id = id;
      // print('The completed task is ${task.taskName} with $seconds seconds');
    } catch (e) {
      // print('Error adding completed task in provider: $e');
      state = List.of(state)..removeLast();
      CustomException("Something went wrong while adding completed task");
    }
  }

  Future<void> unCompletedTask(Tasks task) async {
    try {
      int id = await _taskRepository.unCompletedTask(task);
      task.id = id;
    } catch (e) {
      CustomException("Something went wrong while unompleted task");
    }
  }

  Future<void> deleteCompletedTask(int taskId) async {
    // print("Provider $taskId");
    // Create a copy of the current state before making any changes
    var taskList = List<CompletedTask>.from(state);

    // Remove the task locally first to update the UI immediately
    taskList.removeWhere((task) => task.id == taskId);
    state = taskList;

    try {
      // print("before $taskId");
      await _taskRepository.deleteCompletedTask(taskId);
      state = state.where((task) => task.id != taskId).toList();
      // print("after $taskId");
    } catch (e) {
      // If there is an error, revert the state to the previous state
      // print('Error deleting completed task: $e');
      state = List<CompletedTask>.from(state)
        ..add(taskList.firstWhere((task) => task.id == taskId));
      CustomException("Error in deleting Completed task $e");
    }
  }

  Future<List<CompletedTask>> getAllCompletedTasks(int userId) async {
    // print('Completed Task userId - $userId');
    List<CompletedTask> tasks =
        await _taskRepository.getAllCompletedTasksByUserId(userId);
    return state = tasks;
  }

  // Future<void> updateSeconds(int id, int seconds) async {
  //   print('provider $id,$seconds');
  //   for (CompletedTask task in state) {
  //     if (task.id == id) {
  //       task.seconds = seconds;
  //     }
  //   }
  //   try {
  //     print('Inside provider $id, $seconds');
  //     await _taskRepository.updateSeconds(id, seconds);
  //     print('Inside provider $id, $seconds');
  //   } catch (e) {
  //     throw CustomException(
  //         "Something went wrong while updating working hours time");
  //   }
  // }
}

final completedTasksprovider =
    StateNotifierProvider<CompletedTasksNotifier, List<CompletedTask>>(
  (ref) => CompletedTasksNotifier(ref.watch(taskRepositoryProvider)),
);
