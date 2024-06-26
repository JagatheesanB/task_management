import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_management/tasks/domain/models/attendance.dart';
import 'package:task_management/tasks/domain/models/completed.dart';
import 'package:task_management/tasks/domain/models/task.dart';
import 'package:task_management/tasks/utils/constants/exception.dart';

import '../../domain/models/chat.dart';
import '../../domain/models/comment.dart';
import '../../domain/models/history.dart';
import '../../domain/models/users.dart';

class DatabaseHelper {
  final String databaseName = "datasource.db";
  final String usersTable =
      "CREATE TABLE users (userId INTEGER PRIMARY KEY AUTOINCREMENT, userName TEXT UNIQUE, userPassword TEXT)";

  final String taskTable =
      "CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT,userId INTEGER,taskName TEXT, isCompleted INTEGER, dateTime TEXT, interval TEXT, workingHours TEXT, taskHours TEXT, createdAt TEXT, assignedTo INTEGER, sharedWith TEXT, isAccepted INTEGER)";

  final String completedTasksTable =
      "CREATE TABLE completed_tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, taskName TEXT,userId INTEGER, seconds INTEGER, dateTime TEXT)";

  final String chatTable =
      "CREATE TABLE chat_messages (id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, receiverId INTEGER, message TEXT, timestamp TEXT, isRead INTEGER, FOREIGN KEY (userId) REFERENCES users(userId))";

  static Database? _database; // holds the reference to the database
  static DatabaseHelper?
      _instance; //  holds the reference to the DatabaseHelper instance

  DatabaseHelper._(); //private and instance can create only wihtin the class so that it cannot be accessed from outside the class.

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, databaseName);
    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  FutureOr<void> _createDb(db, version) async {
    await db.execute(usersTable);
    await db.execute(taskTable);
    await db.execute(completedTasksTable);
    await db.execute(chatTable);
    await createHistoryTable(db);
    await createAttendanceTable(db);
    await createCommentTable(db);
  }

  Future<void> createHistoryTable(Database db) async {
    await db.execute('''
    CREATE TABLE history(
      id INTEGER PRIMARY KEY,
      taskName TEXT,
      userId INTEGER,
      dateTime TEXT
    )
  ''');
  }

  Future<void> createAttendanceTable(Database db) async {
    await db.execute('''
    CREATE TABLE attendance_history(
      id INTEGER PRIMARY KEY,
      userId INTEGER,
      checkInTime TEXT,
      checkOutTime TEXT,
      date TEXT,
      FOREIGN KEY (userId) REFERENCES users(userId)
    )
  ''');
  }

  Future<void> createCommentTable(Database db) async {
    await db.execute('''
    CREATE TABLE comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    taskId INTEGER,
    comment TEXT,
    FOREIGN KEY (taskId) REFERENCES tasks(id)
  )
  ''');
  }
  // createdAt TEXT,

  Future<bool> login(String userName, String userPassword) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'userName = ? AND userPassword = ?',
      whereArgs: [userName, userPassword],
    );

    return result.isNotEmpty;
  }

  Future<void> signup(String userName, String userPassword) async {
    final Database db = await database;

    await db.insert(
      'users',
      {
        'userName': userName,
        'userPassword': userPassword,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Users>> getAllUsers(int loggedInUserId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query('users', where: 'userId != ?', whereArgs: [loggedInUserId]);
    return List.generate(maps.length, (i) {
      return Users(
        userId: maps[i]['userId'],
        userName: maps[i]['userName'],
      );
    });
  }

  // Future<String?> getUserEmailByBiometricId(String biometricId) async {
  //   final Database db = await database;
  //   final List<Map<String, dynamic>> result = await db.query(
  //     'users',
  //     columns: ['userName'],
  //     where: 'biometricId = ?',
  //     whereArgs: [biometricId],
  //   );
  //   if (result.isNotEmpty) {
  //     return result.first['userName'] as String?;
  //   } else {
  //     return null;
  //   }
  // }

  Future<bool> checkUserExists(String userName) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'userName = ?',
      whereArgs: [userName],
    );
    return result.isNotEmpty;
  }

  Future<int> insertTask(Tasks task, int userId) async {
    final Database db = await database;
    // //print((task.id));
    // //print('task $task');
    try {
      int id = await db.insert('tasks', {
        ...task.toMapWithOutId(),
        'userId': userId,
      });
      return id;
    } catch (e) {
      // //print("dellll");
      CustomException("Something went wrong while inserting task");
    }
    return 0;
  }

  // Edit Task

  Future<void> editTask(int taskId, Tasks task) async {
    final Database db = await database;
    try {
      await db.update(
        'tasks',
        task.toMapWithOutId(),
        where: 'id = ? ',
        whereArgs: [taskId],
      );
      // //print('Task edited successfully: ${task.taskName}');
    } catch (e) {
      // //print('Error editing task: $e');
      CustomException("Something went wrong while editing task");
    }
  }

  // Delete a Task

  Future<void> deleteTask(int taskId) async {
    final Database db = await database;

    try {
      await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );
      // //print('Task deleted successfully with ID: $taskId');
    } catch (e) {
      // //print('Error deleting task: $e');
      CustomException("Something went wrong while deleting task");
    }
  }

  // Uncompleted Tasks

  Future<int> unCompletedTask(Tasks task) async {
    // //print('hhhhhh $task');
    final Database db = await database;
    try {
      // int id = await db.insert(
      //   'tasks',
      //   {'taskName': task.taskName, 'userId': userId, 'seconds': seconds},
      // );
      int id = await db
          .rawUpdate('UPDATE tasks SET isCompleted=0 WHERE id=?', [task.id]);
      // //print('task added successfully: ${task.taskName}');
      return id;
    } catch (e) {
      CustomException("Something went wrong while in task");
    }
    return 0;
  }

  // Fetch tasks based on interval

  Future<List<Tasks>> getTasksByInterval(String interval) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'interval = ?',
      whereArgs: [interval],
    );
    return List.generate(maps.length, (i) {
      return Tasks(
        id: maps[i]['taskId'],
        taskName: maps[i]['taskName'],
        isCompleted: maps[i]['isCompleted'] == 1,
        dateTime: DateTime.parse(maps[i]['dateTime']),
        interval: maps[i]['interval'],
        createdAt: DateTime.now(),
        taskHours: '',
      );
    });
  }

  // Get All Tasks

  Future<List<Tasks>> getAllTasks() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Tasks(
        id: maps[i]['id'],
        taskName: maps[i]['taskName'],
        isCompleted: maps[i]['isCompleted'] == 1,
        dateTime: DateTime.parse(maps[i]['dateTime']),
        interval: maps[i]['interval'],
        createdAt: DateTime.now(),
      );
    });
  }

  // Future<List<Tasks>> getAllTasksWithUserId(int userId) async {
  //   final Database db = await database;
  //   // Fetch all tasks for the user
  //   final List<Map<String, dynamic>> allTasksMaps = await db.query(
  //     'tasks',
  //     where: 'userId = ?',
  //     whereArgs: [userId],
  //   );
  //   print('All tasks maps - $allTasksMaps');
  //   return List.generate(allTasksMaps.length, (i) {
  //     return Tasks(
  //       id: allTasksMaps[i]['id'],
  //       taskName: allTasksMaps[i]['taskName'],
  //       isCompleted: allTasksMaps[i]['isCompleted'] == 1,
  //       dateTime: DateTime.parse(allTasksMaps[i]['dateTime']),
  //       interval: allTasksMaps[i]['interval'],
  //       taskHours: allTasksMaps[i]['taskHours'],
  //       createdAt: allTasksMaps[i]['createdAt'] != null
  //           ? DateTime.parse(allTasksMaps[i]['createdAt'])
  //           : DateTime.now(),
  //     );
  //   });
  // }

  Future<List<Tasks>> getAllTasksWithUserId(int userId) async {
    final Database db = await database;

    // Fetch all tasks for the user, both completed and not completed
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? OR assignedTo = ?',
      whereArgs: [userId, userId],
    );
    // print('Maps : $maps');
    List<Tasks> tasks = [];
    for (var map in maps) {
      List<int> sharedWithList = [];
      if (map['sharedWith'] != null && map['sharedWith'] is String) {
        List<String> sharedWithStrings = map['sharedWith'].split(',');
        sharedWithList = sharedWithStrings
            .map((str) => int.tryParse(str.trim()) ?? 0)
            .toList();
      } else if (map['sharedWith'] is List) {
        sharedWithList = List<int>.from(map['sharedWith']);
      }

      Tasks task = Tasks(
          id: map['id'],
          taskName: map['taskName'],
          isCompleted: map['isCompleted'] == 1,
          dateTime: DateTime.parse(map['dateTime']),
          interval: map['interval'],
          taskHours: map['taskHours'],
          createdAt: map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
          assignedTo: map['assignedTo'],
          sharedWith: sharedWithList,
          isAccepted: false);
      task = updateTaskDateIfNeeded(task);

      tasks.add(task);
    }
    return tasks;
  }

  // tasks = tasks
  //     .where((task) => task.user?.userId == userId && !task.isCompleted)
  //     .toList();

  Tasks updateTaskDateIfNeeded(Tasks task) {
    if (!task.isCompleted && task.dateTime!.isBefore(DateTime.now())) {
      int daysDifference = DateTime.now().difference(task.dateTime!).inDays;
      task.dateTime = task.dateTime!.add(Duration(days: daysDifference));
    }
    return task;
  }

  // Get All Tasks with UserId
  // Future<List<Tasks>> getAllTasksWithUserId(int userId) async {
  //   final Database db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'tasks',
  //     where: 'userId = ?',
  //     whereArgs: [userId],
  //   );
  //   print('maps - $maps');
  //   return List.generate(maps.length, (i) {
  //     return Tasks(
  //       id: maps[i]['id'],
  //       taskName: maps[i]['taskName'],
  //       isCompleted: maps[i]['isCompleted'] == 1,
  //       dateTime: DateTime.parse(maps[i]['dateTime']),
  //       interval: maps[i]['interval'],
  //       taskHours: maps[i]['taskHours'],
  //       createdAt: DateTime.now(),
  //     );
  //   });
  // }

  // Future<List<Tasks>> getTodayTasks(int userId) async {
  //   final Database db = await database;
  //   DateTime now = DateTime.now();
  //   String todayStr = DateFormat('yyyy-MM-dd').format(now);
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'tasks',
  //     where: 'userId = ? AND date(dateTime) = ?',
  //     whereArgs: [userId, todayStr],
  //   );
  //   return List.generate(maps.length, (i) {
  //     return Tasks(
  //       id: maps[i]['id'],
  //       taskName: maps[i]['taskName'],
  //       isCompleted: maps[i]['isCompleted'] == 1,
  //       dateTime: DateTime.parse(maps[i]['dateTime']),
  //       interval: maps[i]['interval'],
  //       taskHours: maps[i]['taskHours'],
  //       createdAt: DateTime.now(),
  //     );
  //   });
  // }

  // Fetch User ID

  Future<int?> getUserId(String email) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['userId'],
      where: 'userName = ?',
      whereArgs: [email],
    );
    // //print(result);
    if (result.isNotEmpty) {
      return result.first['userId'] as int?;
    } else {
      return null;
    }
  }

  // Insert completed task into the database

  // Future<int> insertCompletedTask(Tasks task, int userId, int seconds) async {
  //   // //print('hhhhhh $task');
  //   final Database db = await database;
  //   try {
  //     int id = await db.insert(
  //       'completed_tasks',
  //       {
  //         'taskName': task.taskName,
  //         'userId': userId,
  //         'seconds': seconds,
  //         'dateTime': DateTime.now().toIso8601String()
  //       },
  //     );
  //     //print('Completed ID : ${task.id}');
  //     // await db.rawUpdate(
  //     //     'UPDATE tasks SET isCompleted=1 WHERE id=?',
  //     //     [task.id]);
  //     await db.rawUpdate(
  //       'UPDATE tasks SET isCompleted = 1 WHERE taskName = ? AND isCompleted = 0',
  //       [task.taskName],
  //     );
  //     //print('Completed task added successfully: ${task.taskName}');
  //     return id;
  //   } catch (e) {
  //     //print('Error adding completed task: $e');
  //     CustomException("Something went wrong while in Completed task");
  //   }
  //   return 0;
  // }

  Future<int> insertCompletedTask(Tasks task, int userId, int seconds) async {
    final Database db = await database;
    final DateTime now = DateTime.now();

    try {
      int completedTaskId = await db.insert(
        'completed_tasks',
        {
          'taskName': task.taskName,
          'userId': userId,
          'seconds': seconds,
          'dateTime': now.toIso8601String(),
        },
      );

      await db.update(
        'tasks',
        {'isCompleted': 1},
        where: 'taskName = ?',
        whereArgs: [task.taskName],
      );

      return completedTaskId;
    } catch (e) {
      // print('Error adding completed task: $e');
      throw CustomException("Something went wrong while in Completed task");
    }
  }

// Delete Completed Task

  Future<int> deleteCompletedTask(int taskId) async {
    final Database db = await database;
    //print("db : $taskId");
    try {
      final List<Map<String, dynamic>> completedTask = await db.query(
        'completed_tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );

      if (completedTask.isNotEmpty) {
        // String taskName = completedTask.first['taskName'];

        int id = await db.delete(
          'completed_tasks',
          where: 'id = ?',
          whereArgs: [taskId],
        );
        // await db.rawUpdate(
        //     'UPDATE tasks SET isCompleted = 0 WHERE taskName = ?', [taskName]);
        //print('Completed Task deleted successfully with ID: $taskId');
        return id;
      } else {
        //print('No completed task found with ID: $taskId');
      }
    } catch (e) {
      //print('Error deleting completed task: $e');
      throw CustomException(
          "Something went wrong while deleting completed task");
    }
    return 0;
  }

  // Get All Completed Tasks by UserId // int? -> int

  Future<List<CompletedTask>> getAllCompletedTasksByUserId(int userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'completed_tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    // print('Completed Maps - $maps');
    return List.generate(maps.length, (i) {
      // Check if taskId is null before casting
      int? taskId = maps[i]['taskId'] as int?;
      int taskIdNonNull = taskId ?? -1;

      // Handle null value for seconds
      int seconds = maps[i]['seconds'] ?? 0;

      return CompletedTask(
        id: maps[i]['id'],
        task: Tasks(
          id: taskIdNonNull,
          taskName: maps[i]['taskName'],
          createdAt: DateTime.now(),
          // taskHours: '',
        ),
        seconds: seconds,
        userId: maps[i]['userId'] as int,
        dateTime: DateTime.now(),
      );
    });
  }

  // Insert task into the history table

  Future<void> insertTaskForHistory(Tasks task, int userId) async {
    final Database db = await database;

    try {
      await db.insert(
        'history',
        {
          'taskName': task.taskName,
          'userId': userId,
          'dateTime': task.dateTime.toString(),
        },
      );
      // //print('Task added to history successfully: ${task.taskName} $userId');
    } catch (e) {
      // //print('Error adding task to history: $e');
      CustomException("Something went wrong while adding history task");
    }
  }

  // Method to retrieve task history based on user ID

  Future<List<HistoryTask>> getTaskHistoryByUserId(int userId) async {
    Database db = await initDB();
    List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    // //print(maps);
    return List.generate(maps.length, (i) {
      return HistoryTask(
        id: maps[i]['id'],
        taskName: maps[i]['taskName'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        userId: maps[i]['userId'],
      );
    });
  }

// Get tasks from history table by interval (day, week, month)

  Future<List<HistoryTask>> getTasksFromHistoryByInterval(
      String interval, int userId) async {
    final Database db = await database;

    late DateTime startDate;
    late DateTime endDate;

    switch (interval) {
      case 'day':
        startDate = DateTime.now().subtract(const Duration(days: 1));
        endDate = DateTime.now();
        break;
      case 'week':
        startDate = DateTime.now().subtract(const Duration(days: 7));
        endDate = DateTime.now();
        break;
      default:
        startDate = DateTime.now().subtract(const Duration(days: 7));
        endDate = DateTime.now();
        break;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'userId = ? AND dateTime BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String()
      ],
    );

    return List.generate(maps.length, (i) {
      return HistoryTask(
        id: maps[i]['id'],
        taskName: maps[i]['taskName'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        userId: maps[i]['userId'],
      );
    });
  }

  // Store attendance history for a user

  Future<void> storeAttendanceHistory(int userId, String checkInTime) async {
    //print(
    //     'Attendance history stored successfully for user ID: $userId ,$checkInTime');
    final Database db = await database;

    try {
      await db.insert(
        'attendance_history',
        {
          'userId': userId,
          'checkInTime': checkInTime.toString(),
          'date': DateTime.now().toString(),
        },
      );
      // //print(
      //     'Attendance history stored successfully for user ID: $userId ,$checkInTime');
    } catch (e) {
      // //print('Error storing attendance history: $e');
      CustomException("Something went wrong while adding attendance");
    }
  }

  // Update Checkout time

  Future<void> updateCheckoutTime(int userId, String checkOutTime) async {
    final Database db = await database;

    try {
      await db.update(
        'attendance_history',
        {
          'checkOutTime': checkOutTime.toString(),
        },
        where: 'userId = ? AND checkOutTime IS NULL',
        whereArgs: [userId],
      );
      // //print('CheckOut Added ,$checkOutTime');
    } catch (e) {
      throw CustomException(
          "Something went wrong while updating checkout time");
    }
  }

  // Update Task Timer

  Future<void> updateTaskTimer(int taskId, String workingHours) async {
    final Database db = await database;
    try {
      //print("Updating working hours to: $workingHours");
      await db.update(
        'tasks',
        {
          'workingHours': workingHours.toString(),
        },
        where: 'id = ?',
        whereArgs: [taskId],
      );
      //print("Task working hours updated successfully to $workingHours");
    } catch (e) {
      //print("Error updating working hours: $e");
      throw CustomException(
          "Something went wrong while updating working hours time: $e");
    }
  }

  // Update Working Hours

  Future<int> updateWorkingHours(int taskId, String taskWorkingHours) async {
    final Database db = await database;
    try {
      // print("Updating working hours to: $taskWorkingHours");

      int id = await db.rawUpdate(
        'UPDATE tasks SET taskHours = ? WHERE id = ?',
        [taskWorkingHours, taskId],
      );
      // print("Task working hours updated successfully to $taskWorkingHours");
      return id;
    } catch (e) {
      // print("Error updating working hours: $e");
      throw CustomException(
          "Something went wrong while updating working hours time: $e");
    }
  }

  Future<int> updateSeconds(int taskId, int seconds) async {
    final Database db = await database;
    try {
      // print("Updating working hours to: $seconds");

      int id = await db.rawUpdate(
        'UPDATE completed_tasks SET seconds = ? WHERE id = ?',
        [seconds, taskId],
      );
      // print("Task working hours updated successfully to $seconds");
      return id;
    } catch (e) {
      // print("Error updating working hours: $e");
      throw CustomException(
          "Something went wrong while updating working hours time: $e");
    }
  }

  // Get Attendance by userId

  Future<List<AttendanceRecord>> getAttendanceHistoryByUserId(
      String userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_history',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    // //print(maps);
    return List.generate(maps.length, (i) {
      return AttendanceRecord(
        id: maps[i]['id'],
        userId: maps[i]['userId'],
        checkInTime: maps[i]['checkInTime'],
        checkOutTime: maps[i]['checkOutTime'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Future<int> insertComment(Comment comment) async {
    final db = await database;
    try {
      // print('DB - ${comment.comment}');
      int id = await db.insert('comments', comment.toMap());
      // print('Comment Added - $comment');
      return id;
    } catch (e) {
      // print('Catch block - ${comment.comment}');
      throw CustomException("Something went wrong while adding comment: $e");
    }
  }

  Future<void> editComment(int commentId, String newComment) async {
    final db = await database;
    // print('Note for Update $newComment');
    await db.update(
      'comments',
      {'comment': newComment},
      where: 'id = ?',
      whereArgs: [commentId],
    );
    // print('Note Update $newComment');
  }

  Future<void> deleteComment(int commentId) async {
    final db = await database;
    await db.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }

  Future<List<Comment>> getCommentsByTaskId(int taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
    // print('Notes Maps - $maps');
    return List.generate(maps.length, (i) {
      return Comment(
        id: maps[i]['id'],
        taskId: maps[i]['taskId'],
        comment: maps[i]['comment'],
        // createdAt: DateTime.parse(maps[i]['createdAt']),
      );
    });
  }

  // Method to get total task hours for the current date
  Future<String> getTotalTaskHoursForCurrentDate(
      int userId, DateTime currentDate) async {
    final Database db = await database;
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(taskHours) AS totalTaskHours 
      FROM tasks 
      WHERE userId = ? AND date(dateTime) = ?
    ''', [userId, currentDate]);

    String totalHours = result[0]['totalTaskHours'].toString();

    return totalHours;
  }

  Future<int> getCompletedTasksCount(int userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT COUNT(*) AS count 
    FROM tasks 
    WHERE userId = ? AND isCompleted = 1
  ''', [userId]);

    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<int> getUncompletedTasksCount(int userId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT COUNT(*) AS count 
    FROM tasks 
    WHERE userId = ? AND isCompleted = 0
  ''', [userId]);

    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  // Create chat message
  Future<int> insertChatMessage(
      int userId, int receiverId, String message) async {
    final Database db = await database;
    final DateTime now = DateTime.now();
    try {
      int id = await db.insert(
        'chat_messages',
        {
          'userId': userId,
          'receiverId': receiverId,
          'message': message,
          'timestamp': now.toIso8601String(),
          'isRead': 0,
        },
      );
      // print('DB ----- $userId -- $receiverId');
      return id;
    } catch (e) {
      // print('Error inserting chat message: $e');
      throw Exception("Failed to insert chat message.");
    }
  }

  // Get chat messages by user ID
  // Future<List<ChatMessage>> getChatMessagesByUserId(int userId) async {
  //   try {
  //     final Database db = await database;

  //     final List<Map<String, dynamic>> senderMaps = await db.query(
  //       'chat_messages',
  //       where: 'userId = ?',
  //       whereArgs: [userId],
  //     );
  //     print('senderMaps --------- $senderMaps');
  //     final List<Map<String, dynamic>> receiverMaps = await db.query(
  //       'chat_messages',
  //       where: 'receiverId = ?',
  //       whereArgs: [userId],
  //     );
  //     print('receiverMaps --------- $receiverMaps');

  //     List<ChatMessage> messages = [];

  //     // Add sender messages
  //     if (senderMaps.isNotEmpty) {
  //       messages.addAll(senderMaps.map((map) => ChatMessage.fromMap(map)));
  //     }

  //     // Add receiver messages, ensuring no duplicates
  //     for (var map in receiverMaps) {
  //       if (!messages.any((msg) => msg.id == map['id'])) {
  //         messages.add(ChatMessage.fromMap(map));
  //       }
  //     }

  //     return messages;
  //   } catch (e) {
  //     print('Error fetching chat messages: $e');
  //     throw CustomException('Failed to fetch chat messages: $e');
  //   }
  // }

  Future<List<ChatMessage>> getChatMessagesByUserId(
      int userId, int receiverId) async {
    try {
      final Database db = await database;

      // Fetch messages where userId is the sender
      final List<Map<String, dynamic>> senderMaps = await db.query(
        'chat_messages',
        where: 'userId = ? AND receiverId = ?',
        whereArgs: [userId, receiverId],
      );
      print('senderMaps --------- $senderMaps');

      // Fetch messages where userId is the receiver
      final List<Map<String, dynamic>> receiverMaps = await db.query(
        'chat_messages',
        where: 'userId = ? AND receiverId = ?',
        whereArgs: [receiverId, userId],
      );
      print('receiverMaps --------- $receiverMaps');

      List<ChatMessage> messages = [];

      // Add sender messages
      if (senderMaps.isNotEmpty) {
        messages.addAll(senderMaps.map((map) => ChatMessage.fromMap(map)));
      }
      // Add receiver messages, ensuring no duplicates
      for (var map in receiverMaps) {
        if (!messages.any((msg) => msg.id == map['id'])) {
          messages.add(ChatMessage.fromMap(map));
        }
      }

      return messages;
    } catch (e) {
      // print('Error fetching chat messages: $e');
      throw CustomException('Failed to fetch chat messages: $e');
    }
  }

  // Update chat message
  Future<int> updateChatMessage(int id, String newMessage) async {
    final Database db = await database;
    final DateTime now = DateTime.now();
    try {
      int count = await db.update(
        'chat_messages',
        {
          'message': newMessage,
          'timestamp': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      // print('UPDATED MESSAGE ----- $newMessage');
      return count;
    } catch (e) {
      // print('Error updating chat message: $e');
      throw Exception("Failed to update chat message.");
    }
  }

  // Delete chat message
  Future<int> deleteChatMessage(int id) async {
    final Database db = await database;
    try {
      int count = await db.delete(
        'chat_messages',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count;
    } catch (e) {
      // print('Error deleting chat message: $e');
      throw Exception("Failed to delete chat message.");
    }
  }

  // Mark chat message as read
  Future<void> markMessageAsRead(int userId, int receiverId) async {
    final Database db = await database;
    try {
      await db.update(
        'chat_messages',
        {'isRead': 1},
        where: 'receiverId = ? AND userId = ?',
        whereArgs: [userId, receiverId],
      );
    } catch (e) {
      // print('Error marking messages as read: $e');
      throw Exception("Failed to mark messages as read.");
    }
  }

  Future<int> getUnreadMessageCount(int userId, int receiverId) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> unreadMessages = await db.query(
        'chat_messages',
        where: 'userId = ? AND receiverId = ? AND isRead = ?',
        whereArgs: [receiverId, userId, 0],
      );

      print('unreadMessages ----------- $unreadMessages $receiverId $userId');
      return unreadMessages.length;
    } catch (e) {
      throw CustomException('Failed to get unread message count: $e');
    }
  }
}
