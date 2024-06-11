import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:task_management/tasks/utils/constants/exception.dart';
import '../../data/models/api_task.dart';

class ApiCallForTaskNotifier extends StateNotifier<List<Task>> {
  ApiCallForTaskNotifier() : super([]) {
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final response =
          await Dio().get('https://api-generator.retool.com/E3xiDZ/users');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data as List<dynamic>;
        final tasks =
            responseData.map((taskJson) => Task.fromJson(taskJson)).toList();
        state = tasks;
      } else {
        state = [];
      }
    } catch (error) {
      state = [];
      CustomException("Something went wrong while fetch api task");
    }
  }
}

final apiProvider =
    StateNotifierProvider<ApiCallForTaskNotifier, List<Task>>((ref) {
  return ApiCallForTaskNotifier();
});

