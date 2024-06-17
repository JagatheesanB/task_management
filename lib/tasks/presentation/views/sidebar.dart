import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/tasks/domain/models/completed.dart';
import 'package:task_management/tasks/presentation/views/attendance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/language_provider.dart';

class Sidebar extends ConsumerStatefulWidget {
  final void Function() onLogout;
  final String email;
  final List<CompletedTask> completedtasks;
  const Sidebar({
    Key? key,
    required this.onLogout,
    required this.email,
    required this.completedtasks,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  late Locale _locale;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _loadLocale();
    super.didChangeDependencies();
  }

  void _loadLocale() {
    _locale = ref.watch(selectedLocaleProvider);
  }

  @override
  Widget build(BuildContext context) {
    String emailPrefix = widget.email.split('@').first;
    emailPrefix = emailPrefix.replaceAll(RegExp(r'[0-9]'), '').toUpperCase();

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.purple,
                // gradient: LinearGradient(colors: [
                //   Color.fromARGB(255, 160, 88, 223),
                //   Color.fromARGB(255, 255, 255, 255)
                // ], begin: Alignment.topLeft, end: Alignment.bottomRight)
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .welcome
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              emailPrefix,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<Locale>(
                    icon: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _locale.languageCode.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    itemBuilder: (BuildContext context) {
                      return languages;
                    },
                    onSelected: (value) {
                      setState(() {
                        _locale = value;
                      });
                      ref
                          .read(selectedLocaleProvider.notifier)
                          .changeLocale(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.access_time_outlined,
              color: Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.attendance,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.purple,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceLocationScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app_outlined,
              color: Colors.black,
            ),
            title: Text(
              AppLocalizations.of(context)!.logout,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.purple,
              ),
            ),
            onTap: () {
              widget.onLogout();
            },
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<Locale>> get languages {
    return [
      const PopupMenuItem(
        value: Locale('en'),
        child: Row(
          children: <Widget>[
            Icon(Icons.language, color: Colors.blue),
            SizedBox(width: 10),
            Text('English'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: Locale('hi'),
        child: Row(
          children: <Widget>[
            Icon(Icons.language, color: Colors.orange),
            SizedBox(width: 10),
            Text('Hindi'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: Locale('fr'),
        child: Row(
          children: <Widget>[
            Icon(Icons.language, color: Colors.red),
            SizedBox(width: 10),
            Text('French'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: Locale('zh'),
        child: Row(
          children: <Widget>[
            Icon(Icons.language, color: Colors.green),
            SizedBox(width: 10),
            Text('Chinese'),
          ],
        ),
      ),
    ];
  }
}
