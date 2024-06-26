import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'chat_screen.dart';

class Home extends ConsumerStatefulWidget {
  final String? email;
  const Home({
    Key? key,
    required this.email,
  }) : super(key: key);
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
  int? userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final userId = ref.read(currentUserProvider);
    if (userId != null) {
      loadData(userId);
      this.userId = userId;
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
                Row(
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 47)),
                    _week(),
                    _chatIcon(),
                  ],
                ),
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
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.person),
        //       label: 'Users',
        //     ),
        //   ],
        //   onTap: (index) {
        //     if (index == 1) {
        //       _showUserListModal();
        //     }
        //   },
        // ),
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
          ).animate().fade().slideY(),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(''),
            ),
          ),
          Tooltip(
            message: 'Report',
            child: TextButton(
              onPressed: _navigateToReportsPage,
              child: const Text(
                'REPORT',
                style: TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ).animate().fade().slideY(),
            ),
          ),
          // IconButton(
          //   onPressed: _handleSearch,
          //   icon: const Icon(Icons.search, color: Colors.black),
          // ),
          Tooltip(
            message: 'History',
            child: TextButton(
              onPressed: _navigateToTaskHistoryPage,
              child: const Text(
                'HISTORY',
                style: TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ).animate().fade().slideY(),
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.person),
      //     onPressed: _showUserListModal,
      //   ),
      // ],
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

  void _showUserListModal() async {
    final userId = ref.read(currentUserProvider) as int;
    final users =
        await ref.read(authNotifierProvider.notifier).loadUsers(userId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.black, width: 5.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'User List',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15.0),
                          title: Text(
                            users[index].userName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // subtitle: Text(
                          //   'ID: ${users[index].userId}',
                          //   style: const TextStyle(
                          //     color: Colors.black54,
                          //   ),
                          // ),
                          trailing:
                              Icon(Icons.send, color: Colors.purple.shade600),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Consumer(builder: (context, ref, _) {
                                  return ChatScreen(
                                    userId: userId,
                                    userName: users[index].userName!,
                                    receiverId: users[index].userId!,
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Colors.purple, Color.fromARGB(255, 99, 68, 182)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  child: Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          // Padding(padding: EdgeInsets.symmetric(horizontal: 30,vertical: 0)),
          // _chatIcon(),
        ],
      ),
    );
  }

  Widget _chatIcon() {
    return Visibility(
      visible: selectedInterval == 'DAY',
      child: IconButton(
        padding: const EdgeInsets.symmetric(horizontal: 45),
        icon: const Icon(Icons.chat),
        onPressed: _showUserListModal,
      ),
    );
  }

  String _getFormattedDate() {
    return DateFormat('dd MMMM yyyy').format(_selectedDate);
  }
}
