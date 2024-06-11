import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/models/history.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';

class TaskHistoryPage extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final List<HistoryTask> historyTask;

  const TaskHistoryPage({
    Key? key,
    required this.selectedDate,
    required this.historyTask,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TaskHistoryPageState();
}

class _TaskHistoryPageState extends ConsumerState<TaskHistoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider);
    final historyTaskList = ref.watch(taskHistoryProvider);
    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (historyTaskList.isNotEmpty) {
      return Scaffold(
        // backgroundColor: Colors.amber.shade100,
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: _buildTaskList(context, historyTaskList),
      );
    } else {
      return Scaffold(
        // backgroundColor: Colors.amber.shade100,
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: _buildEmptyState(context),
      );
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        AppLocalizations.of(context)!.historyTask,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<HistoryTask> tasks) {
    return ListView.builder(
      itemCount: widget.historyTask.length,
      // itemCount: tasks.length,
      itemBuilder: (context, index) {
        final historyTask = widget.historyTask[index];
        // final historyTask = tasks[index];
        final formattedDateTime =
            DateFormat.yMMMMd('en_US').format(historyTask.dateTime);
        return Card(
          margin: const EdgeInsets.all(8.0), // Add margin
          elevation: 4.0,
          // color: const Color.fromARGB(255, 199, 93, 86),
          color: Colors.grey.shade300,
          child: ListTile(
            leading: const Icon(
              Icons.fiber_manual_record,
              color: Colors.black,
            ),
            title: Text(
              historyTask.taskName.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              formattedDateTime,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.black,
              ),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
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
            AppLocalizations.of(context)!.historyNotFound,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lottie/lottie.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:task_management/tasks/presentation/providers/attendance_provider.dart';

// import '../../domain/models/history.dart';
// import '../providers/auth_provider.dart';
// import '../providers/history_provider.dart';

// class TaskHistoryPage extends ConsumerStatefulWidget {
//   final DateTime selectedDate;
//   final List<HistoryTask> historyTask;

//   const TaskHistoryPage({
//     Key? key,
//     required this.selectedDate,
//     required this.historyTask,
//   }) : super(key: key);
//   @override
//   ConsumerState<TaskHistoryPage> createState() => _TaskHistoryPageState();
// }

// class _TaskHistoryPageState extends ConsumerState<TaskHistoryPage> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userId = ref.watch(currentUserProvider);
//     final historyTaskList = ref.watch(taskHistoryProvider);
//     final dateRange = ref.watch(dateRangeProvider.notifier).state;

//     if (userId == null) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     if (historyTaskList.isNotEmpty) {
//       final filteredHistoryTaskList =
//           _filterHistoryTasksByDate(historyTaskList, dateRange);
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: _buildAppBar(context),
//         body: Column(
//           children: [
//             _buildDatePicker(context),
//             _buildSelectedDate(context),
//             Expanded(
//               child: _buildTaskList(context, filteredHistoryTaskList),
//             ),
//           ],
//         ),
//       );
//     } else {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: _buildAppBar(context),
//         body: _buildEmptyState(context),
//       );
//     }
//   }

//   AppBar _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       title: Text(
//         AppLocalizations.of(context)!.historyTask,
//         style: const TextStyle(
//           fontFamily: 'Poppins',
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//     );
//   }

//   Widget _buildDatePicker(BuildContext context) {
//     return ListTile(
//       title: const Text(
//         'Select Date:',
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 20,
//           fontFamily: 'Poppins',
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       trailing: const Icon(Icons.date_range),
//       onTap: () async {
//         final pickedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime(2000),
//           lastDate: DateTime.now(),
//         );
//         if (pickedDate != null) {
//           final dateRange = DateTimeRange(start: pickedDate, end: pickedDate);
//           ref.read(dateRangeProvider.notifier).state = dateRange;
//         }
//       },
//     );
//   }

//   Widget _buildSelectedDate(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, _) {
//         final selectedDate = ref.watch(dateRangeProvider)?.start;
//         if (selectedDate != null) {
//           final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               'Selected Date: $formattedDate',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           );
//         } else {
//           return Container();
//         }
//       },
//     );
//   }

//   List<HistoryTask> _filterHistoryTasksByDate(
//       List<HistoryTask> tasks, DateTimeRange? dateRange) {
//     if (dateRange != null) {
//       return tasks.where((task) {
//         final taskDate = DateTime(
//             task.dateTime.year, task.dateTime.month, task.dateTime.day);
//         return taskDate.isAtSameMomentAs(dateRange.start);
//       }).toList();
//     } else {
//       return tasks;
//     }
//   }

//   Widget _buildTaskList(BuildContext context, List<HistoryTask> tasks) {
//     return ListView.builder(
//       itemCount: tasks.length,
//       itemBuilder: (context, index) {
//         final historyTask = tasks[index];
//         final formattedDateTime =
//             DateFormat.yMMMMd('en_US').format(historyTask.dateTime);
//         return Card(
//           margin: const EdgeInsets.all(8.0),
//           elevation: 4.0,
//           color: const Color.fromARGB(255, 199, 93, 86),
//           child: ListTile(
//             leading: const Icon(
//               Icons.fiber_manual_record,
//               color: Colors.white,
//             ),
//             title: Text(
//               historyTask.taskName.toUpperCase(),
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.white,
//               ),
//             ),
//             subtitle: Text(
//               formattedDateTime,
//               style: const TextStyle(
//                 fontStyle: FontStyle.italic,
//                 color: Colors.white,
//               ),
//             ),
//             onTap: () {},
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Lottie.asset(
//             'assets/lottie/empty.json',
//             width: 170,
//             height: 170,
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'History not found',
//             style: TextStyle(
//               fontStyle: FontStyle.italic,
//               color: Colors.black,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }