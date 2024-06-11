import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/data/dataSources/task_datasource.dart';
import 'package:task_management/tasks/presentation/providers/auth_provider.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/history_provider.dart';

class AddTask extends ConsumerStatefulWidget {
  const AddTask({
    Key? key,
    required this.onIntervalSelected,
    required this.allowedIntervals,
  }) : super(key: key);
  final Function(String) onIntervalSelected;
  final List<String> allowedIntervals;

  @override
  ConsumerState createState() => _AddTaskState();
}

class _AddTaskState extends ConsumerState<AddTask>
    with SingleTickerProviderStateMixin {
  final TextEditingController _addTaskController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  String _selectedInterval = 'DAY';
  late DateTime _selectedDate = DateTime.now();

  String get _formattedSelectedDateAndMonth {
    return 'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.allowedIntervals.isNotEmpty) {
      _selectedInterval = widget.allowedIntervals.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.addTask,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.taskname,
                style: const TextStyle(
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 1,
                    color: Colors.purple,
                  ),
                ),
                child: TextField(
                  controller: _addTaskController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.enterTask,
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _selectedInterval == 'WEEK'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formattedSelectedDateAndMonth,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showDatePicker(context);
                          },
                          icon: const Icon(Icons.calendar_today),
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                  : const SizedBox(),
              if (_selectedInterval == 'WEEK') ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Colors.purple,
                    ),
                  ),
                  child: TextField(
                    controller: _daysController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.enterNumberOfDays,
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  await _submitTask(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.submittask,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    DateTime initialDate =
        DateTime.now().isAfter(_selectedDate) ? DateTime.now() : _selectedDate;
    DateTime minimumDate = initialDate.subtract(const Duration(days: 10));

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 190,
              color: Colors.white,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: minimumDate,
                maximumDate: DateTime.now().add(const Duration(days: 15)),
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
            ),
            CupertinoButton(
              color: Colors.purple,
              child: Text(
                AppLocalizations.of(context)!.done,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTask(BuildContext context) async {
    final newTaskText = _addTaskController.text.trim();
    if (newTaskText.isNotEmpty) {
      final userId = ref.read(currentUserProvider) as int;
      final dbHelper = DatabaseHelper();

      // Check if the task already exists
      final existingTasks = await dbHelper.getAllTasksWithUserId(userId);
      if (existingTasks.any((task) =>
          task.taskName == newTaskText && task.dateTime == _selectedDate)) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.taskAlreadyExistsForThisDate,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_RIGHT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.purple,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        return;
      }

      // Add the task for the selected date
      final newTask = Tasks(
        id: 0,
        taskName: newTaskText,
        dateTime: _selectedDate,
        interval: _selectedInterval,
        createdAt: DateTime.now(),
        // taskHours: '',
      );
      await ref.read(taskProvider.notifier).addTask(newTask, userId);
      await ref
          .read(taskHistoryProvider.notifier)
          .addTaskToHistory(newTask, userId);

      if (_selectedInterval == 'WEEK') {
        final daysText = _daysController.text.trim();
        if (daysText.isNotEmpty) {
          final int? numOfDays = int.tryParse(daysText);
          if (numOfDays != null && numOfDays > 0) {
            // Iterating over the number of days and adding tasks
            for (int i = 1; i < numOfDays; i++) {
              // Start from 1
              final nextDate = _selectedDate.add(Duration(days: i));
              final nextTask = Tasks(
                id: 0,
                taskName: newTaskText,
                dateTime: nextDate,
                interval: _selectedInterval,
                createdAt: DateTime.now(),
                // taskHours: '',
              );
              await ref.read(taskProvider.notifier).addTask(nextTask, userId);
              await ref
                  .read(taskHistoryProvider.notifier)
                  .addTaskToHistory(nextTask, userId);
            }
          }
        }
      }

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.tasksAddedSuccessfully,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 9, 63, 212),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      AnimatedSnackBar.material(
        AppLocalizations.of(context)!.pleaseEnterATaskBeforeAdding,
        type: AnimatedSnackBarType.info,
      ).show(context);
      return;
    }
  }
}
