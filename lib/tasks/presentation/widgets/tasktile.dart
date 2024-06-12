import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/presentation/providers/completed_provider.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import '../../domain/models/completed.dart';
import '../providers/auth_provider.dart';
import '../views/note_page.dart';

class TaskTile extends ConsumerStatefulWidget {
  final Tasks task;
  final Function onComplete;
  final Function(int) onUpdateHours;
  final Function onDelete;
  final CompletedTask? completedTask;
  final bool isExpired;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onUpdateHours,
    required this.onDelete,
    this.completedTask,
    required this.isExpired,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<TaskTile> {
  Timer? _timer;
  int seconds = 0;
  bool isTimerRunning = false;
  // String? _taskComment;

  @override
  void initState() {
    super.initState();
    // _saveTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _completeTask() {
    if (seconds < 0) {
      Fluttertoast.showToast(
        msg: 'You have to work at least 1 Minute',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    final int? userId = ref.read(currentUserProvider);
    String durationValue = widget.task.taskHours!;

    ref.read(completedTasksprovider.notifier).addCompletedTask(widget.task.id!,
        widget.task, int.parse(durationValue), userId!, DateTime.now());

    Fluttertoast.showToast(
      msg: '${widget.task.taskName} Completed',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    setState(() {
      widget.task.isCompleted = true;
    });
    widget.onUpdateHours(int.parse(durationValue));
  }

  void _uncompleteTask() {
    Fluttertoast.showToast(
      msg: '${widget.task.taskName} Reopened',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    ref.read(completedTasksprovider.notifier).unCompletedTask(widget.task);
    setState(() {
      widget.task.isCompleted = false;
    });
    widget.onUpdateHours(0);
  }

  // void _saveTimer() {
  //   _timer = Timer.periodic(const Duration(seconds: 1), (_) {
  //     setState(() {
  //       isTimerRunning = true;
  //       seconds++;
  //       if (seconds == 28800) {
  //         NotificationManager.showTaskNotification(
  //           fileName: widget.task.taskName,
  //           message: 'You have been working for 8 hours on',
  //         );
  //       }
  //       if (seconds % 3600 == 0) {
  //         widget.onUpdateHours(1);
  //       }
  //     });
  //   });
  // }

  String _getDisplayTime(String taskHours) {
    int totalMinutes = int.parse(taskHours);
    if (totalMinutes >= 60) {
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;
      return '$hours H $minutes M';
    } else {
      return '$totalMinutes M';
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayTime = widget.task.taskHours != null
        ? _getDisplayTime(widget.task.taskHours!)
        : '0 M';

    String firstLetter = widget.task.taskName.isNotEmpty
        ? widget.task.taskName.substring(0, 1).toUpperCase()
        : '';

    String capitalize(String s) =>
        s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '';

    String taskFirstLetter = capitalize(widget.task.taskName);

    TextStyle textStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
    );

    return LongPressDraggable(
      feedback: Container(),
      childWhenDragging: Container(),
      data: widget.task,
      onDragStarted: () {
        if (!widget.task.isCompleted) {
          _showDeleteConfirmationDialog();
        }
      },
      child: GestureDetector(
        // onDoubleTapDown: (details) => {
        //   if (!widget.task.isCompleted)
        //     {
        //       _showCommentDialog(),
        //     }
        // },
        onDoubleTap: () {
          if (widget.task.isCompleted) {
            _uncompleteTask();
          }
        },
        onTap: () {
          if (!widget.task.isCompleted) {
            _editTaskName(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: widget.task.isCompleted ? Colors.purple[100] : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.task.isCompleted ? Colors.transparent : Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.pink[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => CommentsDialog(
                  //         task: widget.task,
                  //       ),
                  //     ),
                  //   );
                  // },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskFirstLetter,
                        style: textStyle,
                      ),
                      // const SizedBox(height: 5), // Spacer
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  displayTime,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (!widget.task.isCompleted) {
                    _completeTask();
                  }
                },
                child: Icon(
                  widget.task.isCompleted ? Icons.done_all : Icons.done_outline,
                  color:
                      widget.task.isCompleted ? Colors.green : Colors.blueGrey,
                  size: 30,
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                      // padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                      child: const Text(
                        'Note',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        if (!widget.task.isCompleted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentsDialog(
                                task: widget.task,
                              ),
                            ),
                          );
                        }
                      }),
                ],
                child: const Icon(Icons.more_vert_rounded),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _editTaskName(BuildContext context) async {
    String editedTaskName = widget.task.taskName;
    String editedTaskDuration = widget.task.taskHours ?? '0';
    String durationValue = editedTaskDuration;
    String? durationUnit;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text(
                'Edit Task',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        editedTaskName = value;
                      },
                      controller: TextEditingController()
                        ..text = widget.task.taskName,
                      decoration: InputDecoration(
                        labelText: "Task Name",
                        hintText: "Enter new task name",
                        prefixIcon: const Icon(Icons.task),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            onChanged: (value) {
                              durationValue = value;
                            },
                            controller: TextEditingController()
                              ..text = durationValue,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: "Duration",
                              hintText: "Enter duration",
                              prefixIcon: const Icon(Icons.timer),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: durationUnit,
                            onChanged: (String? newValue) {
                              setState(() {
                                durationUnit = newValue!;
                              });
                            },
                            items: const [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('  Select'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'minutes',
                                child: Text(' Minutes'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'hours',
                                child: Text(' Hours'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: "Unit",
                              // prefixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding:
                                  const EdgeInsets.all(8), // Reduced padding
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    double enteredValue = double.parse(durationValue);
                    int totalMinutes = 0;

                    if (durationUnit == 'hours') {
                      if (enteredValue < 0.5 || enteredValue > 24) {
                        Fluttertoast.showToast(
                          msg: 'Please enter valid hours (0.5-24)',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        return;
                      }
                      totalMinutes = (enteredValue * 60).toInt();
                    } else if (durationUnit == 'minutes') {
                      if (enteredValue < 0.5 || enteredValue > 1440) {
                        Fluttertoast.showToast(
                          msg: 'Please enter valid minutes (0.5-1440)',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        return;
                      }
                      totalMinutes = enteredValue.toInt();
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Please select a unit',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      return;
                    }
                    setState(() {});
                    ref
                        .read(taskProvider.notifier)
                        .updateTaskName(editedTaskName, widget.task.id!);
                    ref.read(taskProvider.notifier).updateWorkingHours(
                        widget.task.id!, totalMinutes.toString());
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg: 'Task Updated',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Delete Task',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this task?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final taskProviderNotifier = ref.read(taskProvider.notifier);
                taskProviderNotifier.deleteTask(widget.task.id!);
                Fluttertoast.showToast(
                  msg: 'Task Deleted',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                return;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // void _showCommentDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       String comment = _taskComment ?? '';

  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         title: const Text(
  //           'Add Note',
  //           style: TextStyle(
  //             fontFamily: 'Poppins',
  //             fontWeight: FontWeight.bold,
  //             fontSize: 24,
  //           ),
  //         ),
  //         content: TextField(
  //           onChanged: (value) {
  //             comment = value;
  //           },
  //           controller: TextEditingController(text: comment),
  //           decoration: InputDecoration(
  //             labelText: "Comment",
  //             hintText: "Enter your comment here",
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10.0),
  //             ),
  //             contentPadding: const EdgeInsets.all(16),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text(
  //               'Cancel',
  //               style: TextStyle(color: Colors.red, fontSize: 16),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               // setState(() {
  //               //   _taskComment = comment;
  //               // });
  //               final newComment = Comment(
  //                 taskId: widget.task.id!,
  //                 comment: comment,
  //                 // createdAt: DateTime.now(),
  //               );
  //               print('BUI - Comment ${newComment.comment}');
  //               ref.read(commentProvider.notifier).insertComment(newComment);
  //               print('AUI - Comment ${newComment.comment}');
  //               Navigator.of(context).pop();
  //               Fluttertoast.showToast(
  //                 msg: 'Comment Added',
  //                 toastLength: Toast.LENGTH_SHORT,
  //                 gravity: ToastGravity.CENTER,
  //                 timeInSecForIosWeb: 1,
  //                 backgroundColor: Colors.red,
  //                 textColor: Colors.white,
  //                 fontSize: 16.0,
  //               );
  //               return;
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.purple,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10.0),
  //               ),
  //               padding:
  //                   const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  //             ),
  //             child: const Text(
  //               'Save',
  //               style: TextStyle(color: Colors.white, fontSize: 16),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

//   Future<void> _showHoursDialog(BuildContext context) async {
//   final TextEditingController _hoursController = TextEditingController();
//   String selectedUnit = 'minutes';
//   await showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text(
//           'Select Time',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             TextField(
//               controller: _hoursController,
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(
//                 labelText: 'Time',
//               ),
//             ),
//             const SizedBox(height: 10),
//             DropdownButton<String>(
//               value: selectedUnit,
//               items: <String>['minutes', 'hours'].map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   selectedUnit = newValue!;
//                 });
//               },
//             ),
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               double inputTime = double.parse(_hoursController.text);
//               int timeInMinutes = selectedUnit == 'hours' ? (inputTime * 60).toInt() : inputTime.toInt();
//               setState(() {
//                 widget.task.taskHours = timeInMinutes.toString();
//               });
//               Navigator.of(context).pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//             ),
//             child: const Text(
//               'Save',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }
}
