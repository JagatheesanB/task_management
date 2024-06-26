import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:task_management/tasks/presentation/views/ProfileScreen.dart';
import 'package:task_management/tasks/presentation/views/welcome_page.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:task_management/tasks/utils/notifications.dart';
import 'tasks/presentation/providers/language_provider.dart';
// import 'tasks/presentation/views/bio_metric.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final String databasePath = await getDatabasesPath();
  // final String path = join(databasePath, "datasource.db");
  // print("DB Delete");
  // deleteDatabase(path);
  await NotificationManager.initializeNotifications();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: ref.watch(selectedLocaleProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'TIMESHEET',
      theme: ThemeData(fontFamily: 'poppins'),
      // darkTheme: ThemeData.dark(),
      home: const WelcomeScreen(),
    );
  }
}
