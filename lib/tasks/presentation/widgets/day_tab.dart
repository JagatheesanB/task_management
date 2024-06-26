// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:task_management/tasks/domain/models/task.dart';
// import 'package:task_management/tasks/presentation/providers/task_provider.dart';
// import 'package:task_management/tasks/presentation/widgets/tasktile.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import '../views/add_task.dart';

// class DayPage extends ConsumerStatefulWidget {
//   final List<Tasks> taskList;
//   final Function(Tasks) completeTask;
//   final Function(Tasks) deleteTask;
//   final Tasks? task;

//   const DayPage({
//     super.key,
//     required this.taskList,
//     required this.completeTask,
//     required this.deleteTask,
//     this.task,
//   });

//   @override
//   ConsumerState createState() => DayPageState();
// }

// class DayPageState extends ConsumerState<DayPage>
//     with TickerProviderStateMixin {
//   int totalHours = 0;
//   List<Tasks> dayTasks = [];
//   late List<Tasks> taskList;
//   String selectedInterval = 'DAY';
//   // bool isSearchVisible = false;
//   // TextEditingController searchController = TextEditingController();
//   // List<Tasks> filteredTasks = [];

//   void _setSelectedInterval(String interval) {
//     setState(() {
//       selectedInterval = interval;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     taskList = widget.taskList;
//     totalHours = _calculateTotalHours(dayTasks);
//     // filteredTasks = taskList.where((task) => task.interval == "DAY").toList();
//     // _filterTasks();
//   }

//   // void _filterTasks({String? query = ''}) {
//   //   setState(() {
//   //     if (query!.isEmpty) {
//   //       filteredTasks = taskList
//   //           .where((task) => task.interval == selectedInterval)
//   //           .toList();
//   //     } else {
//   //       filteredTasks = taskList
//   //           .where((task) =>
//   //               task.interval == selectedInterval &&
//   //               task.taskName.toLowerCase().contains(query.toLowerCase()))
//   //           .toList();
//   //     }
//   //   });
//   // }

//   bool isSameDate(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }

//   int _calculateTotalHours(List<Tasks> tasks) {
//     int totalMinutes = tasks.fold(
//         0, (sum, task) => sum + (int.tryParse(task.taskHours ?? '0') ?? 0));
//     return totalMinutes ~/ 60;
//   }

//   void _updateTaskHours() {
//     setState(() {
//       totalHours = _calculateTotalHours(dayTasks);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     taskList = ref.watch(taskProvider);
//     // this.taskList = taskList;
//     // _filterTasks(query: searchController.text);
//     // print(taskList[0].taskHours);

//     // final dayTasks = taskList.where((task) => task.dateTime == "DAY").toList();

//     final dayTasks = taskList
//         .where((task) => isSameDate(task.dateTime!, DateTime.now()))
//         .toList();
//     _updateTaskHours();

//     // print(dayTasks);

//     return Scaffold(
//       body: Column(
//         children: [
//           _buildTaskBar(),
//           const SizedBox(
//             height: 20,
//           ),
//           Expanded(
//             child: dayTasks.isEmpty
//                 ? _buildNoTasksWidget()
//                 : ListView.builder(
//                     itemCount: dayTasks.length,
//                     itemBuilder: (context, index) {
//                       final task = dayTasks.reversed.toList()[index];
//                       // Check if the task is more than 24 hours old
//                       final isTaskExpired =
//                           DateTime.now().difference(task.createdAt).inHours >=
//                               12;
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: TaskTile(
//                           task: task,
//                           onComplete: () {
//                             widget.completeTask(task);
//                             _updateTaskHours();
//                           },
//                           onDelete: () {
//                             widget.deleteTask(task);
//                             _updateTaskHours();
//                           },
//                           onUpdateHours:_updateTaskHours,
//                           // (int hours) {
//                           //   setState(() {
//                           //     totalHours += hours;
//                           //   });
//                           // },
//                           isExpired: isTaskExpired,
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//       floatingActionButton: _addButton(context),
//     );
//   }

//   FloatingActionButton _addButton(BuildContext context) {
//     return FloatingActionButton(
//       heroTag: 'btn1',
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AddTask(
//               onIntervalSelected: _setSelectedInterval,
//               allowedIntervals: const ['DAY'],
//             ),
//           ),
//         );
//       },
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//       backgroundColor: Colors.purple,
//       child: const Icon(
//         Icons.add,
//         color: Colors.white,
//         size: 30,
//       ),
//     );
//   }

//   Widget _buildTaskBar() {
//     return Row(
//       children: [
//         const Padding(padding: EdgeInsets.all(16.0)),
//         Text(
//           AppLocalizations.of(context)!.taskList,
//           style: const TextStyle(
//             fontFamily: 'Poppins',
//             fontSize: 25,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const Padding(padding: EdgeInsets.symmetric(horizontal: 75)),
//         Text(
//           'Total- $totalHours hrs/Day',
//           style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//         )
//       ],
//     );
//   }

//   Widget _buildNoTasksWidget() {
//     return const Center(
//       child: Text(
//         'No Task Available',
//         style: TextStyle(
//             fontSize: 20,
//             fontFamily: 'Poppins',
//             fontStyle: FontStyle.italic,
//             fontWeight: FontWeight.normal,
//             color: Colors.black),
//       ),
//     );
//   }
// }
//  IconButton(
//           onPressed: () {
//             setState(() {
//               isSearchVisible = !isSearchVisible;
//               if (isSearchVisible) {
//                 searchController.clear();
//                 _filterTasks();
//               }
//             });
//           },
//           icon: const Icon(Icons.search),
//         ),
//         if (isSearchVisible)
//           Expanded(
//               child: Padding(
//             padding: const EdgeInsets.only(right: 10.0),
//             child: TextField(
//               controller: searchController,
//               decoration: const InputDecoration(
//                 hintText: "Search ...",
//               ),
//               onChanged: (value) {
//                 _filterTasks(query: value);
//               },
//             ),
//           ))

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import 'package:task_management/tasks/presentation/widgets/tasktile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/notifications.dart';
import '../views/add_task.dart';

class DayPage extends ConsumerStatefulWidget {
  final List<Tasks> taskList;
  final Function(Tasks) completeTask;
  final Function(Tasks) deleteTask;
  final Tasks? task;
  // final CompletedTask completedTask;

  const DayPage({
    super.key,
    required this.taskList,
    required this.completeTask,
    required this.deleteTask,
    // required this.completedTask,
    this.task,
  });

  @override
  ConsumerState createState() => DayPageState();
}

class DayPageState extends ConsumerState<DayPage>
    with TickerProviderStateMixin {
  double totalHours = 0;
  final double workingHours = 8.0;
  final double maxWorkingHours = 15.0;
  late List<Tasks> taskList;
  List<Tasks> dayTasks = [];

  String selectedInterval = 'DAY';

  void _setSelectedInterval(String interval) {
    setState(() {
      selectedInterval = interval;
    });
  }

  @override
  void initState() {
    super.initState();
    dayTasks = widget.taskList
        .where((task) => isSameDate(task.dateTime!, DateTime.now()))
        .toList();
    totalHours = _calculateTotalHours(dayTasks);
    _checkAndNotifyUser();
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double _calculateTotalHours(List<Tasks> tasks) {
    int totalMinutes = tasks.fold(
        0, (sum, task) => sum + (int.tryParse(task.taskHours ?? '0') ?? 0));
    return totalMinutes / 60.0;
  }

  void _updateTaskHours() {
    setState(() {
      totalHours = _calculateTotalHours(dayTasks);
      _checkAndNotifyUser();
    });
  }

  void _checkAndNotifyUser() {
    if (totalHours >= workingHours) {
      NotificationManager.showTaskNotification(
        fileName: 'You have reached 8 hours of work today',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    taskList = ref.watch(taskProvider);
    dayTasks = taskList
        .where((task) => isSameDate(task.dateTime!, DateTime.now()))
        .toList();
    // dayTasks = taskList.where((task) => task.interval == "WEEK").toList();
    _updateTaskHours();

    return Scaffold(
      body: Column(
        children: [
          _buildTaskBar(),
          const SizedBox(height: 20),
          Expanded(
            child: dayTasks.isEmpty
                ? _buildNoTasksWidget()
                : ListView.builder(
                    itemCount: dayTasks.length,
                    itemBuilder: (context, index) {
                      final task = dayTasks.reversed.toList()[index];
                      final isTaskExpired =
                          DateTime.now().difference(task.createdAt).inHours >=
                              12;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TaskTile(
                          task: task,
                          onComplete: () {
                            widget.completeTask(task);
                            _updateTaskHours();
                          },
                          onDelete: () {
                            widget.deleteTask(task);
                            _updateTaskHours();
                          },
                          onUpdateHours: (hours) {
                            _updateTaskHours();
                          },
                          isExpired: isTaskExpired,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _addButton(context),
    );
  }

  FloatingActionButton _addButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'btn1',
      onPressed: totalHours >= maxWorkingHours
          ? () {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.youHaveReachedMaxHours,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTask(
                    onIntervalSelected: _setSelectedInterval,
                    allowedIntervals: const ['DAY'],
                  ),
                ),
              ).then((_) {
                _updateTaskHours();
              });
            },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor:
          totalHours >= maxWorkingHours ? Colors.grey : Colors.purple,
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildTaskBar() {
    return Row(
      children: [
        const Padding(padding: EdgeInsets.all(18.0)),
        Text(
          AppLocalizations.of(context)!.tasks,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 60)),
        Row(
          children: [
            Text(
              '${AppLocalizations.of(context)!.total} -',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              ' ${totalHours.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hoursPerDay}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoTasksWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noTaskAvailable,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
