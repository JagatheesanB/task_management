import 'package:task_management/tasks/domain/models/attendance.dart';
import 'package:task_management/tasks/domain/models/history.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/domain/models/users.dart';

import '../models/chat.dart';
import '../models/comment.dart';
import '../models/completed.dart';

abstract class TaskRepository {
  Future<bool> login(String userName, String userPassword);
  Future<void> signup(String userName, String userPassword);
  Future<bool> checkUserExists(String userName);
  Future<int> insertTask(Tasks task, int userId);
  Future<void> editTask(int taskId, Tasks task);
  Future<void> deleteTask(int taskId);
  Future<List<Tasks>> getTasksByInterval(String interval);
  Future<List<Tasks>> getAllTasks();
  Future<List<Tasks>> getAllTasksWithUserId(int userId);
  Future<int?> getUserId(String email);
  Future<int> insertCompletedTask(Tasks task, int userId, int seconds);
  Future<List<HistoryTask>> getTasksFromHistoryByInterval(
      String interval, int userId);
  Future<List<HistoryTask>> getTaskHistoryByUserId(int userId);
  Future<void> insertTaskForHistory(Tasks task, int userId);
  Future<List<CompletedTask>> getAllCompletedTasksByUserId(int userId);
  Future<void> storeAttendanceHistory(int userId, String checkInTime);
  Future<List<AttendanceRecord>> getAttendanceHistoryByUserId(String userId);
  Future<void> updateCheckoutTime(int userId, String checkOutTime);
  Future<void> updateTaskTimer(int id, String workingHours);
  Future<int> deleteCompletedTask(int taskId);
  Future<int> unCompletedTask(Tasks tasks);
  Future<int> updateWorkingHours(int id, String taskHours);
  // Future<List<Tasks>> getTodayTasks(int userId);
  Future<int> updateSeconds(int id, int seconds);
  Future<int> insertComment(Comment comment);
  Future<void> editComment(int commentId, String newComment);
  Future<void> deleteComment(int commentId);
  Future<List<Comment>> getCommentsByTaskId(int taskId);
  Future<List<Users>> getAllUsers(int loggedInUserId);
  Future<int> getCompletedTasksCount(int userId);
  Future<int> getUncompletedTasksCount(int userId);
  // Future<String> getTotalTaskHoursForCurrentDate(int userId);
  Future<int> insertChatMessage(int userId, int receiverId, String message);
  Future<List<ChatMessage>> getChatMessagesByUserId(int userId, int receiverId);
  Future<int> updateChatMessage(int id, String newMessage);
  Future<int> deleteChatMessage(int id);
  Future<void> markMessageAsRead(int id, int receiverId);
  Future<int> getUnreadMessageCount(int userId, int receiverId);
}
