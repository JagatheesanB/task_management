import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/tasks/data/repositories/task_repo_impl.dart';
import 'package:task_management/tasks/domain/repositories/task_repository.dart';
import '../../domain/models/chat.dart';
import '../../utils/constants/exception.dart';

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final TaskRepository _chatRepository;

  ChatNotifier(this._chatRepository, List<ChatMessage> state) : super(state);

  Future<void> getChatMessagesForUser(int userId, int receiverId) async {
    try {
      final List<ChatMessage> chatMessages =
          await _chatRepository.getChatMessagesByUserId(userId, receiverId);
      state = chatMessages;
    } catch (e) {
      print('Error in getChatMessagesForUser: $e');
      throw CustomException('Failed to fetch chat messages: $e');
    }
  }

  Future<void> addChatMessage(
      String messageContent, int userId, int receiverId) async {
    try {
      final ChatMessage message = ChatMessage(
        id: 0,
        userId: userId,
        receiverId: receiverId,
        message: messageContent,
        timestamp: DateTime.now(),
      );
      print('Before userId -- receiverId = $userId ---  $receiverId');

      final int messageId = await _chatRepository.insertChatMessage(
          userId, receiverId, messageContent);
      print('After userId -- receiverId = $userId ---  $receiverId');
      final ChatMessage newMessage = message.copyWith(id: messageId);
      state = [...state, newMessage];
    } catch (e) {
      throw CustomException('Failed to add chat message: $e');
    }
  }

  Future<int> updateChatMessage(int messageId, String newMessage) async {
    state = state.map((message) {
      if (message.id == messageId) {
        return message.copyWith(message: newMessage);
      } else {
        return message;
      }
    }).toList();

    try {
      int id = await _chatRepository.updateChatMessage(messageId, newMessage);
      return id;
    } catch (e) {
      state = [...state];
      throw CustomException('Failed to update chat message: $e');
    }
  }

  Future<int> deleteChatMessage(int messageId) async {
    if (state.any((message) => message.id == messageId)) {
      final List<ChatMessage> updatedMessages = List<ChatMessage>.from(state)
        ..removeWhere((message) => message.id == messageId);
      state = updatedMessages;

      try {
        int id = await _chatRepository.deleteChatMessage(messageId);
        return id;
      } catch (e) {
        state = List<ChatMessage>.from(updatedMessages);
        throw CustomException('Failed to delete chat message: $e');
      }
    } else {
      throw CustomException('Message not found for delete');
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
    (ref) => ChatNotifier(ref.watch(chatRepositoryProvider), []));

final chatRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImplementation();
});
