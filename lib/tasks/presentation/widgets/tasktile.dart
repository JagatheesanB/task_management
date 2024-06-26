import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/presentation/providers/completed_provider.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import '../../domain/models/completed.dart';
import '../providers/auth_provider.dart';
import '../views/note_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool isHover = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _completeTask() {
    if (widget.task.taskHours == null || widget.task.taskHours == '0') {
      Fluttertoast.showToast(
        msg: 'add duration To complete Task',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      _editTaskName(context);
      return;
    }

    if (seconds < 0) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.work_15_minutes,
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
      msg:
          '${widget.task.taskName.toUpperCase()} ${AppLocalizations.of(context)!.completed.toUpperCase()}',
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
      msg:
          '${widget.task.taskName.toUpperCase()} ${AppLocalizations.of(context)!.reopened.toUpperCase()}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    ref.read(completedTasksprovider.notifier).unCompletedTask(widget.task);
    ref.read(taskProvider.notifier).uncompleteTaskByName(widget.task.taskName);
    // ref
    //     .read(completedTasksprovider.notifier)
    //     .deleteCompletedTask(widget.completedTask!.id);
    setState(() {
      widget.task.isCompleted = false;
    });
    widget.onUpdateHours(0);
  }

  String _getDisplayTime(String taskHours) {
    int totalMinutes = int.parse(taskHours);
    if (totalMinutes >= 60) {
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;
      if (minutes == 0) {
        return '$hours hr';
      }
      return '$hours hr $minutes m';
    } else {
      return '$totalMinutes m';
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayTime = widget.task.taskHours != null
        ? _getDisplayTime(widget.task.taskHours!)
        : '0 m';

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

    // if (!widget.task.isAccepted) {
    //   return const SizedBox.shrink();
    // }

    return LongPressDraggable(
      feedback: Container(),
      childWhenDragging: Container(),
      data: widget.task,
      // onDragStarted: () {
      //   if (!widget.task.isCompleted) {
      //     _showDeleteConfirmationDialog();
      //   }
      // },
      child: GestureDetector(
        onTap: () {
          if (!widget.task.isCompleted) {
            _editTaskName(context);
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          // onEnter: (event) {
          //   setState(() {
          //     isHover = true;
          //   });
          // },
          // onHover: (event) => {
          //   setState(() {
          //     isHover = true;
          //   })
          // },
          // onExit: (event) {
          //   setState(() {
          //     isHover = false;
          //   });
          // },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: isHover
                ? Matrix4.diagonal3Values(1.1, 1.1, 1)
                : Matrix4.identity(),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: widget.task.isCompleted
                  ? const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 160, 88, 223),
                        Color.fromARGB(255, 255, 255, 255)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.task.isCompleted ? null : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    widget.task.isCompleted ? Colors.transparent : Colors.grey,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Color.fromARGB(255, 99, 68, 182)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
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
                    ).animate().fade(duration: 900.ms).slideX(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskFirstLetter,
                        style: textStyle,
                      ).animate().fade(duration: 900.ms).slideX(),
                      // const Text(
                      //   'Details here',
                      //   style: TextStyle(
                      //     fontFamily: 'Poppins',
                      //     fontSize: 14,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 110,
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [],
                  ),
                  child: Center(
                    child: Text(
                      displayTime,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fade(duration: 900.ms).slideX(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (!widget.task.isCompleted) {
                      ref
                          .read(taskProvider.notifier)
                          .completeTaskByName(widget.task.taskName);
                      _completeTask();
                    }
                  },
                  child: Tooltip(
                    message: 'Complete task',
                    preferBelow: true,
                    child: Icon(
                      widget.task.isCompleted
                          ? Icons.done_all
                          : Icons.done_outline,
                      color: widget.task.isCompleted
                          ? Colors.green
                          : Colors.blueGrey,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton(
                  color: Colors.black,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.note_add, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.note,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.normal,
                            ),
                          ).animate().fade(duration: 500.ms).slideY(),
                        ],
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
                      },
                    ),
                    if (widget.task.isCompleted)
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.uncomplete,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                              ),
                            ).animate().fade(duration: 500.ms).slideY(),
                          ],
                        ),
                        onTap: () {
                          _uncompleteTask();
                        },
                      ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_outlined,
                              color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.deleteTask,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.normal,
                            ),
                          ).animate().fade(duration: 500.ms).slideY(),
                        ],
                      ),
                      onTap: () {
                        _showDeleteConfirmationDialog();
                      },
                    ),
                  ],
                  child: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
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
              title: Text(
                AppLocalizations.of(context)!.editTask,
                style: const TextStyle(
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
                        labelText: AppLocalizations.of(context)!.taskname,
                        hintText:
                            AppLocalizations.of(context)!.enterNewTaskName,
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
                              labelText: AppLocalizations.of(context)!.duration,
                              hintText:
                                  AppLocalizations.of(context)!.enterDuration,
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
                                durationUnit = newValue;
                              });
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child:
                                    Text(AppLocalizations.of(context)!.select),
                              ),
                              DropdownMenuItem<String>(
                                value: 'minutes',
                                child:
                                    Text(AppLocalizations.of(context)!.minutes),
                              ),
                              DropdownMenuItem<String>(
                                value: 'hours',
                                child:
                                    Text(AppLocalizations.of(context)!.hours),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.unit,
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
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    double enteredValue = double.parse(durationValue);
                    int totalMinutes = 0;

                    if (durationUnit == 'hours') {
                      if (enteredValue < 0.5 || enteredValue > 24) {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.valid_hours,
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
                          msg: AppLocalizations.of(context)!
                              .pleaseEnterValidMinutes,
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
                        msg: AppLocalizations.of(context)!.pleaseSelectAUnit,
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

                    ref.read(taskProvider.notifier).updateTaskById(
                        widget.task.id!, totalMinutes.toString());

                    ref.read(taskProvider.notifier).updateWorkingHours(
                        widget.task.id!, totalMinutes.toString());
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg:
                          '${widget.task.taskName.toUpperCase()} ${AppLocalizations.of(context)!.taskUpdated.toUpperCase()}',
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
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.deleteTask,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.areYouSureYouWantToDeleteThisTask,
            style: const TextStyle(
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
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
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
                  msg:
                      '${widget.task.taskName.toUpperCase()} ${AppLocalizations.of(context)!.taskDeleted.toUpperCase()}',
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
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ).animate().fade().slideX(),
            ),
          ],
        );
      },
    );
  }
}
