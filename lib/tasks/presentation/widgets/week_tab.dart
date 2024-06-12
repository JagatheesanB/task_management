import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import 'package:task_management/tasks/presentation/views/add_task.dart';
import 'package:task_management/tasks/presentation/widgets/tasktile.dart';

class WeekPage extends ConsumerStatefulWidget {
  final List<Tasks> taskList;
  final DateTime selectedDate;
  final Function(Tasks) completeTask;
  final Function(Tasks) deleteTask;

  const WeekPage({
    Key? key,
    required this.selectedDate,
    required this.completeTask,
    required this.deleteTask,
    required this.taskList,
  }) : super(key: key);

  @override
  ConsumerState createState() => WeekPageState();
}

class WeekPageState extends ConsumerState<WeekPage>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  String selectedInterval = 'DAY';
  late List<Tasks> taskList;

  DateTimeRange dateRange =
      DateTimeRange(start: DateTime(2024, 5, 1), end: DateTime.now());

  void _setSelectedInterval(String interval) {
    setState(() {
      selectedInterval = interval;
    });
  }

  @override
  void initState() {
    super.initState();
    taskList = widget.taskList;
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final start = dateRange.start;
    final end = dateRange.end;
    // final difference = dateRange.duration;

    taskList = ref.watch(taskProvider);
    final selectedDateTasks = taskList.where((task) =>
        // task.interval == "WEEK" &&
        _isSameDay(task.dateTime!, _selectedDate)).toList();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Color.fromARGB(255, 99, 68, 182)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.blue.withOpacity(0.4),
                  //     spreadRadius: 2,
                  //     blurRadius: 8,
                  //     offset: const Offset(0, 3),
                  //   ),
                  // ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _previousWeek,
                      icon: const Icon(Icons.arrow_circle_left_outlined,
                          color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: pickDateRange,
                      child: Text(
                        '${start.day}/${start.month}/${start.year}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: pickDateRange,
                      child: Text(
                        '${end.day}/${end.month}/${end.year}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _nextWeek,
                      icon: const Icon(Icons.arrow_circle_right_outlined,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          // Text(
          //   'Difference : ${difference.inDays} days',
          //   style: const TextStyle(fontFamily: 'poppins', fontSize: 8),
          // ),
          // _week(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                30,
                (index) {
                  final day = _selectedDate
                      .subtract(Duration(days: _selectedDate.weekday - 1)) //
                      .add(Duration(days: index));
                  final isSelectedDate = _isSameDay(day, _selectedDate);
                  final hasTasks = _hasTasksForDate(day, taskList);
                  final isPastDate = _isPastDate(day);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = day;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: isSelectedDate
                                ? const LinearGradient(
                                    colors: [
                                      Colors.purple,
                                      Colors.deepPurpleAccent
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: !isSelectedDate ? Colors.white : null,
                            borderRadius: BorderRadius.circular(12),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.purple.withOpacity(0.5),
                            //     spreadRadius: 2,
                            //     blurRadius: 8,
                            //     offset: const Offset(0, 3),
                            //   )
                            // ],
                            border: Border.all(
                              color: !isSelectedDate
                                  ? isPastDate
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade400
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('E').format(day),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: isSelectedDate
                                      ? Colors.white
                                      : isPastDate
                                          ? Colors.grey
                                          : Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                DateFormat('d').format(day),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelectedDate
                                      ? Colors.white
                                      : isPastDate
                                          ? Colors.grey
                                          : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (hasTasks)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isSelectedDate
                                        ? Colors.white
                                        : Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedDateTasks.isEmpty
                ? _buildNoTasksWidget()
                : ListView.builder(
                    itemCount: selectedDateTasks.length,
                    itemBuilder: (context, index) {
                      final task = selectedDateTasks.reversed.toList()[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TaskTile(
                          task: task,
                          onComplete: widget.completeTask,
                          onDelete: widget.deleteTask,
                          onUpdateHours: (int hours) {},
                          isExpired: false,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton:
          !_isPastDate(_selectedDate) ? _addButton(context) : null,
    );
  }

  Future pickDateRange() async {
    DateTimeRange? nextDateRange = await showDateRangePicker(
        context: context,
        initialDateRange: dateRange,
        firstDate: DateTime(2022),
        lastDate: DateTime(2025));

    if (nextDateRange == null) return;
    setState(() {
      dateRange = nextDateRange;
    });
  }

  // Widget _week() {
  //   final previousMonth = DateTime(_selectedDate.year, _selectedDate.month - 1);
  //   final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1);
  //   return Visibility(
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         IconButton(
  //           onPressed: _selectedDate.month > DateTime.now().month
  //               ? () {
  //                   setState(() {
  //                     _selectedDate = previousMonth;
  //                   });
  //                 }
  //               : null,
  //           icon: const Icon(
  //             Icons.arrow_back_ios,
  //             color: Colors.redAccent,
  //           ),
  //         ),
  //         Text(
  //           _getFormattedDate(),
  //           style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
  //         ),
  //         IconButton(
  //           onPressed: _selectedDate.month < DateTime.now().month
  //               ? () {
  //                   setState(() {
  //                     _selectedDate = nextMonth;
  //                   });
  //                 }
  //               : null,
  //           icon: const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  FloatingActionButton _addButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'btn2',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTask(
              onIntervalSelected: _setSelectedInterval,
              allowedIntervals: const ['WEEK'],
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.blue,
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  void _previousWeek() {
    setState(() {
      dateRange = DateTimeRange(
        start: dateRange.start.subtract(const Duration(days: 7)),
        end: dateRange.end.subtract(const Duration(days: 7)),
      );
      _selectedDate = dateRange.start;
    });
  }

  void _nextWeek() {
    setState(() {
      dateRange = DateTimeRange(
        start: dateRange.start.add(const Duration(days: 7)),
        end: dateRange.end.add(const Duration(days: 7)),
      );
      _selectedDate = dateRange.start;
    });
  }

  bool _hasTasksForDate(DateTime date, List<Tasks> taskList) {
    final tasksForDate =
        taskList.where((task) => _isSameDay(task.dateTime!, date)).toList();

    if (_isSameDay(date, DateTime.now())) {
      return tasksForDate
          .any((task) => !_isSameDay(task.dateTime!, DateTime.now()));
    } else {
      return tasksForDate.isNotEmpty;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isPastDate(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  Widget _buildNoTasksWidget() {
    return const Center(
      child: Text(
        'No Task Available',
        style: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.normal,
            color: Colors.black),
      ),
    );
  }

  String _getFormattedDate() {
    return DateFormat('dd MMMM yyyy').format(_selectedDate);
  }
}
