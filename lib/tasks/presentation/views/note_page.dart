// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:lottie/lottie.dart';
// import 'package:task_management/tasks/domain/models/comment.dart';
// import 'package:task_management/tasks/domain/models/task.dart';
// import 'package:task_management/tasks/presentation/providers/comment_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// class CommentsDialog extends ConsumerStatefulWidget {
//   final Tasks task;
//   const CommentsDialog({Key? key, required this.task}) : super(key: key);
//   @override
//   ConsumerState createState() => _CommentsDialogState();
// }
// class _CommentsDialogState extends ConsumerState<CommentsDialog> {
//   // String? _taskComment;
//   @override
//   void initState() {
//     super.initState();
//     ref.read(commentProvider.notifier).getCommentsByTaskId(widget.task.id!);
//   }
//   @override
//   Widget build(BuildContext context) {
//     List<Comment> comments = ref.watch(commentProvider);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Notes for ${widget.task.taskName}',
//           style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         // backgroundColor: Colors.purple,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: comments.isNotEmpty
//             ? ListView.builder(
//                 itemCount: comments.length,
//                 itemBuilder: (context, index) {
//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8.0),
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: ListTile(
//                       leading: const Icon(
//                         Icons.comment,
//                         color: Colors.purple,
//                       ),
//                       title: Text(
//                         comments[index].comment,
//                         style: const TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize: 16,
//                         ),
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit_note_outlined,
//                                 color: Colors.blue),
//                             onPressed: () {
//                               _showNoteDialog(
//                                 isUpdating: true,
//                                 commentId: comments[index].id!,
//                                 initialComment: comments[index].comment,
//                               );
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete_outline_rounded,
//                                 color: Colors.red),
//                             onPressed: () {
//                               ref
//                                   .read(commentProvider.notifier)
//                                   .deleteComment(comments[index].id!);
//                               Fluttertoast.showToast(
//                                 msg: AppLocalizations.of(context)!.noteDeleted,
//                                 toastLength: Toast.LENGTH_SHORT,
//                                 gravity: ToastGravity.CENTER,
//                                 timeInSecForIosWeb: 1,
//                                 backgroundColor: Colors.red,
//                                 textColor: Colors.white,
//                                 fontSize: 16.0,
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               )
//             : Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Lottie.asset(
//                       'assets/lottie/empty.json',
//                       width: 170,
//                       height: 170,
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       AppLocalizations.of(context)!.noNoteAdded,
//                       style: const TextStyle(
//                         fontStyle: FontStyle.italic,
//                         color: Colors.black,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showNoteDialog();
//         },
//         backgroundColor: Colors.purple,
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//   void _showNoteDialog(
//       {bool isUpdating = false, int? commentId, String? initialComment}) {
//     String comment = initialComment ?? '';
//     TextEditingController noteController = TextEditingController(text: comment);
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           title: Text(
//             isUpdating
//                 ? AppLocalizations.of(context)!.updateNote
//                 : AppLocalizations.of(context)!.addNote,
//             style: const TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.bold,
//               fontSize: 24,
//             ),
//           ),
//           content: TextField(
//             onChanged: (value) {
//               comment = value;
//             },
//             controller: noteController,
//             decoration: InputDecoration(
//               labelText: AppLocalizations.of(context)!.note,
//               hintText: AppLocalizations.of(context)!.enterYourNoteHere,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               contentPadding: const EdgeInsets.all(16),
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                 AppLocalizations.of(context)!.cancel,
//                 style: const TextStyle(color: Colors.red, fontSize: 16),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (isUpdating) {
//                   ref
//                       .read(commentProvider.notifier)
//                       .updateComment(commentId!, comment);
//                   Fluttertoast.showToast(
//                     msg: AppLocalizations.of(context)!.noteUpdated,
//                     toastLength: Toast.LENGTH_SHORT,
//                     gravity: ToastGravity.CENTER,
//                     timeInSecForIosWeb: 1,
//                     backgroundColor: Colors.green,
//                     textColor: Colors.white,
//                     fontSize: 16.0,
//                   );
//                 } else {
//                   final newComment = Comment(
//                     taskId: widget.task.id!,
//                     comment: comment,
//                   );
//                   ref.read(commentProvider.notifier).insertComment(newComment);
//                   Fluttertoast.showToast(
//                     msg: AppLocalizations.of(context)!.noteAdded,
//                     toastLength: Toast.LENGTH_SHORT,
//                     gravity: ToastGravity.CENTER,
//                     timeInSecForIosWeb: 1,
//                     backgroundColor: Colors.green,
//                     textColor: Colors.white,
//                     fontSize: 16.0,
//                   );
//                 }
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//               ),
//               child: Text(
//                 AppLocalizations.of(context)!.save,
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:task_management/tasks/domain/models/comment.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/presentation/providers/comment_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommentsDialog extends ConsumerStatefulWidget {
  final Tasks task;

  const CommentsDialog({Key? key, required this.task}) : super(key: key);

  @override
  ConsumerState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends ConsumerState<CommentsDialog> {
  @override
  void initState() {
    super.initState();
    ref.read(commentProvider.notifier).getCommentsByTaskId(widget.task.id!);
  }

  @override
  Widget build(BuildContext context) {
    List<Comment> comments = ref.watch(commentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.notesFor}${widget.task.taskName}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: comments.isNotEmpty
            ? ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.comment,
                        color: Colors.purple,
                      ),
                      title: Text(
                        comments[index].comment,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note_outlined,
                                color: Colors.blue),
                            onPressed: () {
                              _showNoteDialog(
                                isUpdating: true,
                                commentId: comments[index].id!,
                                initialComment: comments[index].comment,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(commentProvider.notifier)
                                  .deleteComment(comments[index].id!);
                              Fluttertoast.showToast(
                                msg: AppLocalizations.of(context)!.noteDeleted,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/empty.json',
                      width: 170,
                      height: 170,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.noNoteAdded,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNoteDialog();
        },
        backgroundColor: Colors.purple,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showNoteDialog(
      {bool isUpdating = false, int? commentId, String? initialComment}) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String comment = initialComment ?? '';
    TextEditingController noteController = TextEditingController(text: comment);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            isUpdating
                ? AppLocalizations.of(context)!.updateNote
                : AppLocalizations.of(context)!.addNote,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: noteController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.note,
                hintText: AppLocalizations.of(context)!.enterYourNoteHere,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!
                      .pleaseAddNoteBeforeSubmit;
                }
                return null;
              },
              onChanged: (value) {
                comment = value;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (isUpdating) {
                    ref
                        .read(commentProvider.notifier)
                        .updateComment(commentId!, comment);
                    Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.noteUpdated,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    final newComment = Comment(
                      taskId: widget.task.id!,
                      comment: comment,
                    );
                    ref
                        .read(commentProvider.notifier)
                        .insertComment(newComment);
                    Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.noteAdded,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
