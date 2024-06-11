// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/api_task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/api_provider.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = ref.read(apiProvider);
  }

  void toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
    ref.read(apiProvider.notifier).state = _tasks;
  }

  Future<void> _refreshTasks() async {
    Completer<void> completer = Completer<void>();
    await Future.delayed(const Duration(seconds: 2));
    _tasks = ref.read(apiProvider);
    setState(() {});
    completer.complete();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:  Text(
          AppLocalizations.of(context)!.taskList,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  onTap: () => toggleTaskCompletion(index),
                  title: Text(
                    'ID: ${task.id}',
                    style: TextStyle(
                      color: task.isCompleted ? Colors.green : Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    task.taskName,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: task.isCompleted
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.radio_button_unchecked,
                          color: Colors.red),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
