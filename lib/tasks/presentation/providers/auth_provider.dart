import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/tasks/domain/repositories/task_repository.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';

import '../../domain/models/users.dart';

class UserNotifier extends StateNotifier<int?> {
  final TaskRepository _taskRepository;

  UserNotifier(this._taskRepository) : super(null);

  Future<int?> getUserId(String email) async {
    return await _taskRepository.getUserId(email);
  }

  void setUserId(int userId) {
    state = userId;
  }

  // void logout() {
  //   state = null;
  // }
}

final currentUserProvider = StateNotifierProvider<UserNotifier, int?>(
  (ref) => UserNotifier(ref.watch(taskRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<bool> {
  final TaskRepository _repository;

  AuthNotifier(this._repository) : super(false);

  Future<bool> login(String userName, String userPassword) async {
    final result = await _repository.login(userName, userPassword);
    state = result;
    // print('Login Status: $state');
    return result;
  }

  Future<void> signup(String userName, String userPassword) async {
    await _repository.signup(userName, userPassword);
    state = true;
    // print('Signup Status: $state');
  }

  Future<List<Users>> loadUsers(int userId) async {
    final users = await _repository.getAllUsers(userId);
    return users;
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return AuthNotifier(repository);
});
