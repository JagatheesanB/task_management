import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_management/tasks/domain/models/completed.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_management/tasks/presentation/providers/auth_provider.dart';
import 'package:task_management/tasks/presentation/providers/completed_provider.dart';
import 'package:task_management/tasks/presentation/views/generate_excel.dart';

class CompletedTasksPage extends ConsumerStatefulWidget {
  const CompletedTasksPage({Key? key, required this.completedTask})
      : super(key: key);

  final List<CompletedTask> completedTask;

  @override
  ConsumerState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends ConsumerState<CompletedTasksPage> {
  // late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // _selectedDate = DateTime.now();
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate,
  //     firstDate: DateTime(2015, 8),
  //     lastDate: DateTime.now(),
  //   );
  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //   }
  // }
  // List<CompletedTask> _filterTaskByDate(List<CompletedTask> tasks) {
  //   return tasks.where((task) {
  //     final completedDate = task.dateTime;
  //     return completedDate.year == _selectedDate.year &&
  //         completedDate.month == _selectedDate.month &&
  //         completedDate.day == _selectedDate.day;
  //   }).toList();
  // }

  // void _navigateToExcelPage() async {
  //   int? userId = ref.read(currentUserProvider);
  //   if (userId != null) {
  //     List<CompletedTask> tasks = await ref
  //         .read(completedTasksprovider.notifier)
  //         .getAllCompletedTasks(userId);
  //     if (tasks.isNotEmpty) {
  //       if (context.mounted) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ExcelGenerator(
  //               completedTasks: tasks,
  //             ),
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

  void _navigateToExcelPage() async {
    int? userId = ref.read(currentUserProvider);
    if (userId != null) {
      List<CompletedTask> tasks = await ref
          .read(completedTasksprovider.notifier)
          .getAllCompletedTasks(userId);
      if (tasks.isNotEmpty) {
        if (context.mounted) {
          File excelFile = await generateExcelFile(tasks);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExcelDisplayPage(
                excelFile: excelFile,
              ),
            ),
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'No completed tasks to export',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  Future<File> generateExcelFile(List<CompletedTask> tasks) async {
    var excel = Excel.createExcel();
    var sheet = excel['CompletedTasks'];

    // Adding header row
    sheet.appendRow(['Task Name', 'Time Spent']);

    for (var completedTask in tasks) {
      String displayTime = _getDisplayTime(completedTask.seconds.toString());
      sheet.appendRow([
        completedTask.task.taskName.toUpperCase(),
        displayTime,
      ]);
    }

    // Save the Excel to a file
    final output = await getTemporaryDirectory();
    File excelFile = File('${output.path}/Completed_Tasks.xlsx');
    excelFile.writeAsBytesSync(excel.save()!);

    return excelFile;
  }

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
    final completedTasks = ref.watch(completedTasksprovider);
    // final filteredTasks = _filterTaskByDate(completedTasks);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.report,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: widget.completedTask.isEmpty //filteredTasks
                ? Center(
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
                          AppLocalizations.of(context)!.noCompletedTasks,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: completedTasks.length,
                    itemBuilder: (context, index) {
                      final completedTask =
                          completedTasks.reversed.toList()[index];
                      String displayTime =
                          _getDisplayTime(completedTask.seconds.toString());

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              completedTask.task.taskName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Time spent: $displayTime',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey[700],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                ref
                                    .read(completedTasksprovider.notifier)
                                    .deleteCompletedTask(completedTask.id);
                                Fluttertoast.showToast(
                                  msg:
                                      '${completedTask.task.taskName.toUpperCase()} ${AppLocalizations.of(context)!.taskDeleted.toUpperCase()}',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: _navigateToExcelPage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const Icon(Icons.file_download),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.getExcel,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
