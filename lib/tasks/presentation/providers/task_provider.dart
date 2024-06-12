import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/tasks/data/repositories/task_repo_impl.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/domain/repositories/task_repository.dart';
import 'package:task_management/tasks/utils/constants/exception.dart';

class TaskNotifier extends StateNotifier<List<Tasks>> {
  final TaskRepository _taskRepository;

  TaskNotifier(this._taskRepository, List<Tasks> state) : super(state);

  Future<void> getTasksWithUserId(int userId) async {
    List<Tasks> tasks = await _taskRepository.getAllTasksWithUserId(userId);
    state = tasks;
  }

  // Future<void> getTodayTasks(int userId) async {
  //   List<Tasks> tasks = await _taskRepository.getTodayTasks(userId);
  //   state = tasks;
  // }

  Future<void> getAllTasks() async {
    List<Tasks> tasks = await _taskRepository.getAllTasks();
    state = tasks;
  }

  Future<void> addTask(Tasks task, int userId) async {
    //print('provider----------------------${task.id}');
    int id = await _taskRepository.insertTask(task, userId);
    task.id = id;
    state = [...state, task];
//    onTaskListChange?.call(state);
  }

  Future<void> updateTaskName(String name, int id) async {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(taskName: name);
      } else {
        return task;
      }
    }).toList();

    try {
      await _taskRepository.editTask(
          id, state.firstWhere((task) => task.id == id));
    } catch (e) {
      state = [...state];
      CustomException("Error in editing task $e");
    }
  }

  void deleteTask(int taskId) async {
    if (state.any((task) => task.id == taskId)) {
      var taskList = List<Tasks>.from(state);
      taskList.removeWhere((task) => task.id == taskId);
      state = taskList;

      try {
        await _taskRepository.deleteTask(taskId);
      } catch (e) {
        state = List<Tasks>.from(taskList);
        CustomException("Error in deleting task $e");
      }
    } else {
      if (state.any((task) => task.id != taskId)) {
        CustomException("Task not found for delete");
      }
    }
//    onTaskListChange?.call(state);
  }

  Future<void> updateTaskTimer(int id, String workingHours) async {
    //print('provider $id,$workingHours');
    try {
      await _taskRepository.updateTaskTimer(id, workingHours);
      //print('Inside provider $id, $workingHours');
    } catch (e) {
      throw CustomException(
          "Something went wrong while updating working hours time");
    }
  }

  Future<void> updateWorkingHours(int id, String taskHours) async {
    // print('provider $id,$taskHours');
    for (Tasks task in state) {
      if (task.id == id) {
        task.taskHours = taskHours;
      }
    }
    try {
      // print('Inside provider $id, $taskHours');
      await _taskRepository.updateWorkingHours(id, taskHours);
      // print('Inside provider $id, $taskHours');
    } catch (e) {
      throw CustomException(
          "Something went wrong while updating working hours time");
    }
  }

  // Future<void> addDefaultTasks(int userId) async {
  //   final List<Tasks> defaultTasks = [
  //     Tasks(
  //       id: 0,
  //       taskName: 'Finish Project',
  //       isCompleted: false,
  //       dateTime: DateTime.now(),
  //       interval: 'DAY',
  //       createdAt: DateTime.now(),
  //     ),
  //     Tasks(
  //       id: 0,
  //       taskName: 'Meeting',
  //       isCompleted: false,
  //       dateTime: DateTime.now(),
  //       interval: 'WEEK',
  //       createdAt: DateTime.now(),
  //     ),
  //     Tasks(
  //       id: 0,
  //       taskName: 'Coding',
  //       isCompleted: false,
  //       dateTime: DateTime.now(),
  //       interval: 'DAY',
  //       createdAt: DateTime.now(),
  //     ),
  //   ];

  //   for (Tasks task in defaultTasks) {
  //     await _taskRepository.insertTask(task, userId);
  //   }
  //   await getTasksWithUserId(userId);
  // }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Tasks>>(
  (ref) => TaskNotifier(ref.watch(taskRepositoryProvider), []),
);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImplementation();
});
