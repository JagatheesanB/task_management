import 'package:task_management/tasks/data/dataSources/task_datasource.dart';
import 'package:task_management/tasks/domain/models/attendance.dart';
import 'package:task_management/tasks/domain/models/completed.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/domain/repositories/task_repository.dart';

import '../../domain/models/comment.dart';
import '../../domain/models/history.dart';

class TaskRepositoryImplementation implements TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<bool> login(String userName, String userPassword) async {
    return await _databaseHelper.login(userName, userPassword);
  }

  @override
  Future<void> signup(String userName, String userPassword) async {
    await _databaseHelper.signup(userName, userPassword);
  }

  @override
  Future<bool> checkUserExists(String userName) async {
    return await _databaseHelper.checkUserExists(userName);
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await _databaseHelper.deleteTask(taskId);
  }

  @override
  Future<void> editTask(int taskId, Tasks task) async {
    await _databaseHelper.editTask(taskId, task);
  }

  @override
  Future<List<CompletedTask>> getAllCompletedTasksByUserId(int userId) async {
    return await _databaseHelper.getAllCompletedTasksByUserId(userId);
  }

  @override
  Future<List<Tasks>> getAllTasks() async {
    return await _databaseHelper.getAllTasks();
  }

  @override
  Future<List<Tasks>> getAllTasksWithUserId(int userId) async {
    return await _databaseHelper.getAllTasksWithUserId(userId);
  }

  @override
  Future<int> deleteCompletedTask(int taskId) async {
    //print("Imple - $taskId");
    return await _databaseHelper.deleteCompletedTask(taskId);
  }

  @override
  Future<int> unCompletedTask(Tasks task) async {
    //print("Imple - ${task.id}");
    return await _databaseHelper.unCompletedTask(task);
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceHistoryByUserId(
      String userId) async {
    return await _databaseHelper.getAttendanceHistoryByUserId(userId);
  }

  @override
  Future<List<HistoryTask>> getTaskHistoryByUserId(int userId) async {
    return await _databaseHelper.getTaskHistoryByUserId(userId);
  }

  @override
  Future<List<Tasks>> getTasksByInterval(String interval) async {
    return await _databaseHelper.getTasksByInterval(interval);
  }

  @override
  Future<List<HistoryTask>> getTasksFromHistoryByInterval(
      String interval, int userId) async {
    return await _databaseHelper.getTasksFromHistoryByInterval(
        interval, userId);
  }

  @override
  Future<int?> getUserId(String email) async {
    return await _databaseHelper.getUserId(email);
  }

  @override
  Future<int> insertCompletedTask(Tasks task, int userId, int seconds) async {
    //print('Imple -${task.taskName}');
    return await _databaseHelper.insertCompletedTask(task, userId, seconds);
  }

  @override
  Future<int> insertTask(Tasks task, int userId) async {
    //print("Imple ");
    return await _databaseHelper.insertTask(task, userId);
  }

//
  @override
  Future<void> insertTaskForHistory(Tasks task, int userId) async {
    await _databaseHelper.insertTaskForHistory(task, userId);
  }

//
  @override
  Future<void> storeAttendanceHistory(int userId, String checkInTime) async {
    // //print('------------$userId');
    // //print('------------$checkInTime');
    await _databaseHelper.storeAttendanceHistory(userId, checkInTime);
  }

  @override
  Future<void> updateCheckoutTime(int userId, String checkOutTime) async {
    // //print('------------$userId');
    // //print('------------$checkOutTime');
    await _databaseHelper.updateCheckoutTime(userId, checkOutTime);
  }

  @override
  Future<void> updateTaskTimer(int id, String workingHours) async {
    //print("Imple $workingHours");
    await _databaseHelper.updateTaskTimer(id, workingHours);
  }

  @override
  Future<int> updateWorkingHours(int id, String taskHours) async {
    // print("Imple $taskHours");
    return await _databaseHelper.updateWorkingHours(id, taskHours);
  }

  // @override
  // Future<List<Tasks>> getTodayTasks(int userId) async {
  //   return await _databaseHelper.getTodayTasks(userId);
  // }

  @override
  Future<int> updateSeconds(int id, int seconds) async {
    // print("Imple $seconds");
    return await _databaseHelper.updateSeconds(id, seconds);
  }

  @override
  Future<int> insertComment(Comment comment) async {
    // print('Imple - $comment');
    return await _databaseHelper.insertComment(comment);
  }

  @override
  Future<void> editComment(int commentId, String newComment) async {
    await _databaseHelper.editComment(commentId, newComment);
  }

  @override
  Future<void> deleteComment(int commentId) async {
    await _databaseHelper.deleteComment(commentId);
  }

  @override
  Future<List<Comment>> getCommentsByTaskId(int taskId) async {
    return await _databaseHelper.getCommentsByTaskId(taskId);
  }
}
