import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/tasks/data/repositories/task_repo_impl.dart';
import 'package:task_management/tasks/domain/repositories/task_repository.dart';

import '../../domain/models/comment.dart';
import '../../utils/constants/exception.dart';

class CommentNotifier extends StateNotifier<List<Comment>> {
  final TaskRepository _commentRepository;

  CommentNotifier(this._commentRepository, List<Comment> state) : super(state);

  Future<void> insertComment(Comment comment) async {
    // print('Inside p - $comment');
    int id = await _commentRepository.insertComment(comment);
    // print('after p - $comment');
    comment.id = id;
    state = [...state, comment];
  }

  Future<void> updateComment(int commentId, String newComment) async {
    try {
      await _commentRepository.editComment(commentId, newComment);
      state = state.map((c) {
        if (c.id == commentId) {
          return c.copyWith(comment: newComment);
        } else {
          return c;
        }
      }).toList();
    } catch (e) {
      throw CustomException("Error in updating comment $e");
    }
  }

  Future<void> deleteComment(int commentId) async {
    if (state.any((c) => c.id == commentId)) {
      var commentList = List<Comment>.from(state);
      commentList.removeWhere((c) => c.id == commentId);
      state = commentList;

      try {
        await _commentRepository.deleteComment(commentId);
      } catch (e) {
        throw CustomException("Error in deleting comment $e");
      }
    } else {
      throw CustomException("Comment not found for delete");
    }
  }

  Future<void> getCommentsByTaskId(int taskId) async {
    List<Comment> comments =
        await _commentRepository.getCommentsByTaskId(taskId);
    state = comments;
  }
}

final commentProvider = StateNotifierProvider<CommentNotifier, List<Comment>>(
  (ref) => CommentNotifier(ref.watch(commentRepositoryProvider), []),
);

final commentRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImplementation();
});
