import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/presentation/providers/auth_provider.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/models/users.dart';
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
  double totalHours = 0;
  final double workingHours = 8.0;
  final double maxWorkingHours = 15.0;
  List<Users> _users = [];
  Users? _selectedUser;
  bool _showAssignedTask = false;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  String get _formattedSelectedDateAndMonth {
    return '${AppLocalizations.of(context)!.date} ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.allowedIntervals.isNotEmpty) {
      _selectedInterval = widget.allowedIntervals.first;
    }
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final userId = ref.read(currentUserProvider) as int;
    final users =
        await ref.read(authNotifierProvider.notifier).loadUsers(userId);
    setState(() {
      _users = users;
    });
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
        actions: [
          // Padding(padding: EdgeInsets.only(left: 20)),
          IconButton(
            padding: const EdgeInsets.only(right: 30),
            icon: Icon(
              _showAssignedTask ? Icons.people : Icons.person_off_outlined,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showAssignedTask = !_showAssignedTask;
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Center(
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
                const SizedBox(height: 10),
                // DropdownButtonFormField<Users>(
                //   value: _selectedUser,
                //   onChanged: (Users? newValue) {
                //     setState(() {
                //       _selectedUser = newValue;
                //     });
                //   },
                //   items: _users.map((Users user) {
                //     return DropdownMenuItem<Users>(
                //       value: user,
                //       child: Text(user.userName!),
                //     );
                //   }).toList(),
                //   decoration: const InputDecoration(
                //     labelText: 'Assign Task To',
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 10),
                if (_showAssignedTask) ...[_buildAutocompleteField()],
                const SizedBox(height: 10),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
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
      ),
    );
  }

  Widget _buildAutocompleteField() {
    return Autocomplete<Users>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        final String query = textEditingValue.text.toLowerCase();
        return _users
            .where((user) => user.userName!.toLowerCase().contains(query));
      },
      displayStringForOption: (Users user) => user.userName!,
      fieldViewBuilder: (BuildContext context, TextEditingController controller,
          FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: ' Assign Task To',
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Colors.purple,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Colors.purple,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Colors.purple,
              ),
            ),
          ),
        );
      },
      onSelected: (Users user) {
        setState(() {
          _selectedUser = user;
        });
      },
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = now.isAfter(_selectedDate) ? now : _selectedDate;
    DateTime minimumDate = now;
    DateTime maximumDate = now.add(const Duration(days: 365));
// initialDate.subtract(const Duration(days: 15))
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
                maximumDate: maximumDate,
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
    setState(() {
      _errorMessage = newTaskText.isEmpty
          ? AppLocalizations.of(context)!.pleaseEnterATaskBeforeAdding
          : null;
    });

    if (newTaskText.isNotEmpty) {
      final userId = ref.read(currentUserProvider) as int;
      final assignedToUserID = _selectedUser?.userId ?? userId;
      // final dbHelper = DatabaseHelper();

      if (newTaskText.length > 30) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.taskTooLong,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_RIGHT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        return;
      }

      // await _showAcceptanceDialog(context);

      // Check if the selected date is in the past
      final now = DateTime.now();
      final isSameDay = _selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day;
      if (_selectedInterval == 'WEEK' &&
          !isSameDay &&
          _selectedDate.isBefore(now)) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.addTaskOnlyForFuture,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_RIGHT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        return;
      }

      // Check if the task already exists
      // final existingTasks = await dbHelper.getAllTasksWithUserId(userId);
      // if (existingTasks.any((task) =>
      //     task.taskName == newTaskText && task.dateTime == _selectedDate)) {
      //   if (context.mounted) {
      //     Fluttertoast.showToast(
      //       msg: AppLocalizations.of(context)!.taskAlreadyExistsForThisDate,
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.TOP_RIGHT,
      //       timeInSecForIosWeb: 1,
      //       backgroundColor: Colors.purple,
      //       textColor: Colors.white,
      //       fontSize: 16.0,
      //     );
      //   }
      //   return;
      // }

      if (_selectedInterval == 'WEEK') {
        final daysText = _daysController.text.trim();
        if (daysText.isNotEmpty) {
          final int? numOfDays = int.tryParse(daysText);
          if (numOfDays != null && numOfDays > 0) {
            if (numOfDays > 20) {
              if (context.mounted) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.maxDaysExceeded,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP_RIGHT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              }
              return;
            }

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
                taskHours: '1',
              );
              await ref.read(taskProvider.notifier).addTask(nextTask, userId);
              await ref
                  .read(taskHistoryProvider.notifier)
                  .addTaskToHistory(nextTask, userId);
            }
          }
        }
      }

      List<int>? userIds = _users.map((user) => user.userId!).toList();

      // Add the task for the selected date only if numOfDays <= 20
      final newTask = Tasks(
        id: 0,
        taskName: newTaskText,
        dateTime: _selectedDate,
        interval: _selectedInterval,
        createdAt: DateTime.now(),
        // taskHours: '',
        assignedTo: assignedToUserID,
        sharedWith: userIds,
        // isAccepted: true,
        // _selectedUser != null ? [_selectedUser!.userId!] : []
      );
      // print('SharedWith - ${newTask.sharedWith}');
      await ref.read(taskProvider.notifier).addTask(newTask, userId);
      await ref
          .read(taskHistoryProvider.notifier)
          .addTaskToHistory(newTask, userId);

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
    }
    //  else {
    //   AnimatedSnackBar.material(
    //     AppLocalizations.of(context)!.pleaseEnterATaskBeforeAdding,
    //     type: AnimatedSnackBarType.info,
    //   ).show(context);
    //   return;
    // }
  }
}
