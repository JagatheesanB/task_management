import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:task_management/tasks/presentation/providers/completed_provider.dart';
import 'package:task_management/tasks/presentation/views/completed_task.dart';
import 'package:task_management/tasks/presentation/views/login_page.dart';
import 'package:task_management/tasks/presentation/widgets/day_tab.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/presentation/views/history_page.dart';
import 'package:task_management/tasks/presentation/providers/task_provider.dart';
import 'package:task_management/tasks/presentation/views/sidebar.dart';
import 'package:task_management/tasks/presentation/widgets/tasktile.dart';
import 'package:task_management/tasks/presentation/widgets/week_tab.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/models/completed.dart';
import '../../domain/models/history.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';

class Home extends ConsumerStatefulWidget {
  const Home({
    Key? key,
    required this.email,
  }) : super(key: key);
  final String? email;

  @override
  ConsumerState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  final GlobalKey<DayPageState> dayPageKey = GlobalKey<DayPageState>();
  late List<Tasks> taskList = [];
  final List<Tasks> completedTasks = [];
  final List<CompletedTask> completedTask = [];
  late TabController _tabController;
  final DateTime _selectedDate = DateTime.now();
  String selectedInterval = 'DAY';
  bool isSearchVisible = false;
  TextEditingController searchController = TextEditingController();
  List<Tasks> daysTasks = [];
  List<Tasks> weekTasks = [];
  // late Tasks tasks;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final userId = ref.read(currentUserProvider);
    if (userId != null) {
      loadData(userId);
    }
    _filterTasks();
  }

  // void _handleSearch() {
  //   setState(() {
  //     isSearchVisible = !isSearchVisible;
  //     if (!isSearchVisible) {
  //       searchController.clear();
  //       isSearching = false;
  //       _filterTasks();
  //     } else {
  //       isSearching = true;
  //     }
  //   });
  // }

  void _filterTasks({String? query = ''}) {
    setState(() {
      if (query!.isEmpty) {
        daysTasks = taskList
            .where((task) => task.interval == 'DAY' || task.interval == 'WEEK')
            .toList();
      } else {
        daysTasks = taskList
            .where((task) =>
                task.interval == selectedInterval &&
                task.taskName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _completeTask(Tasks task) {
    taskList.remove(task);
    completedTasks.add(task);
    setState(() {});
  }

  void _navigateToTaskHistoryPage() async {
    int? userId = ref.read(currentUserProvider);
    List<HistoryTask> tasks = await ref
        .read(taskHistoryProvider.notifier)
        .getTasksFromHistoryByInterval(selectedInterval, userId!);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskHistoryPage(
            selectedDate: _selectedDate,
            historyTask: tasks,
          ),
        ),
      );
    }
  }

  void _navigateToReportsPage() async {
    int? userId = ref.read(currentUserProvider);
    if (userId != null) {
      List<CompletedTask> tasks = await ref
          .read(completedTasksprovider.notifier)
          .getAllCompletedTasks(userId);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletedTasksPage(
              completedTask: tasks,
            ),
          ),
        );
      }
    }
  }

  loadData(int userId) {
    ref.read(taskProvider.notifier).getTasksWithUserId(userId);
  }

  // loadTodayTasks(int userId) {
  //   ref.read(taskProvider.notifier).getTodayTasks(userId);
  // }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    taskList = ref.watch(taskProvider);
    _filterTasks(query: searchController.text);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: Tooltip(
          message: 'Menu',
          child: Sidebar(
            onLogout: logout,
            email: widget.email!,
            completedtasks: completedTask,
          ),
        ),
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                _buildTabBar(),
                const SizedBox(
                  height: 10,
                ),
                _week(),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      isSearching
                          ? _buildSearchResults()
                          : Consumer(
                              builder: (BuildContext context, WidgetRef ref,
                                  Widget? child) {
                                return DayPage(
                                  taskList: taskList,
                                  key: dayPageKey,
                                  completeTask: _completeTask,
                                  deleteTask: (Tasks taskToDelete) {
                                    setState(() {
                                      taskList.remove(taskToDelete);
                                      _filterTasks(
                                          query: searchController.text);
                                    });
                                  },
                                  // task: tasks,
                                );
                              },
                            ),
                      WeekPage(
                        taskList: weekTasks,
                        selectedDate: DateTime.now(),
                        completeTask: _completeTask,
                        deleteTask: (Tasks taskToDelete) {
                          setState(() {
                            taskList.remove(taskToDelete);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (daysTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/empty.json',
              width: 170,
              height: 170,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppLocalizations.of(context)!.noResultFound,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: daysTasks.length,
        itemBuilder: (context, index) {
          final task = daysTasks[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TaskTile(
              task: task,
              onComplete: () {},
              onUpdateHours: (hours) {},
              onDelete: () {},
              isExpired: false,
            ),
          );
        },
      );
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.mytasks,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(''),
            ),
          ),
          Tooltip(
            message: 'Report',
            child: IconButton(
              onPressed: _navigateToReportsPage,
              icon: const Icon(Icons.report_outlined, color: Colors.black),
            ),
          ),
          // IconButton(
          //   onPressed: _handleSearch,
          //   icon: const Icon(Icons.search, color: Colors.black),
          // ),
          Tooltip(
            message: 'History',
            child: IconButton(
              onPressed: _navigateToTaskHistoryPage,
              icon: const Icon(Icons.history, color: Colors.black),
            ),
          ),
        ],
      ),
      bottom: isSearchVisible ? _buildSearchBar() : null,
    );
  }

  PreferredSizeWidget _buildSearchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: Colors.grey),
          ),
          child: TextField(
            controller: searchController,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.search,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
                        _filterTasks();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              _filterTasks(query: value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    _tabController.addListener(() {
      setState(() {
        selectedInterval = _tabController.index == 0 ? 'DAY' : 'WEEK';
      });
    });
    return TabBar(
      labelColor: Colors.purple,
      controller: _tabController,
      indicatorColor: Colors.purple,
      tabs: [
        Tab(text: AppLocalizations.of(context)!.day),
        Tab(text: AppLocalizations.of(context)!.week),
      ],
    );
  }

  Widget _week() {
    return Visibility(
      visible: selectedInterval == 'DAY',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getFormattedDate(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    return DateFormat('dd MMMM yyyy').format(_selectedDate);
  }
}
