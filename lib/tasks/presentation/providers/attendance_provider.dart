import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';

import '../../domain/models/attendance.dart';
import '../../domain/repositories/task_repository.dart';
import '../../utils/constants/exception.dart';

class AttendanceRecordNotifier extends StateNotifier<List<AttendanceRecord>> {
  final TaskRepository _taskRepository;

  AttendanceRecordNotifier(this._taskRepository) : super([]);

  Future<void> addAttendanceHistoryByUserId(
      int userId, String checkInTime, String checkOutTime) async {
    final AttendanceRecord record = AttendanceRecord(
      userId: userId,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      date: DateTime.now(),
    );

    try {
      await _taskRepository.storeAttendanceHistory(userId, checkInTime);
      state = [...state, record];
      // print('Attendance history stored successfully for user ID: $userId');
    } catch (e) {
      // print('Error storing attendance history: $e');
      CustomException("Something went wrong while adding Attd");
    }
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceRecordsByUserId(
      String userId) async {
    final List<AttendanceRecord> records =
        await _taskRepository.getAttendanceHistoryByUserId(userId);
    state = records;
    return records.map((record) => record.toMap()).toList();
  }

  Future<void> updateCheckoutTime(int userId, String checkOutTime) async {
    try {
      await _taskRepository.updateCheckoutTime(userId, checkOutTime);
      // print('fffffff------$userId,$checkOutTime');
    } catch (e) {
      throw CustomException(
          "Something went wrong while updating checkout time");
    }
  }
}

final attendanceRecordProvider =
    StateNotifierProvider<AttendanceRecordNotifier, List<AttendanceRecord>>(
  (ref) => AttendanceRecordNotifier(ref.watch(taskRepositoryProvider)),
);


final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);