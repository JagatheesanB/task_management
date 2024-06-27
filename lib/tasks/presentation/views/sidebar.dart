import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_management/tasks/domain/models/completed.dart';
import 'package:task_management/tasks/presentation/views/attendance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_management/tasks/presentation/views/profile_screen.dart';
import 'package:task_management/tasks/presentation/views/user_instruction.dart';
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                              email: widget.email,
                            )),
                  );
                },
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                      // color: Colors.purple,
                      ),
                  child: Row(
                    children: [
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
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  emailPrefix,
                                  style: const TextStyle(
                                    color: Colors.black,
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
                                color: Colors.black,
                                fontSize: 19,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Language Selection PopupMenuButton
                      PopupMenuButton<Locale>(
                        icon: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _locale.languageCode.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black,
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
                          _showLanguageToast(value);
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
              ListTile(
                leading: const Icon(
                  Icons.task_outlined,
                  color: Colors.black,
                ),
                title: const Text(
                  'Instructions',
                  style: TextStyle(
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
                          builder: (context) => const UserInstructionsPage()));
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
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<void>(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 70),
              icon: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              itemBuilder: (BuildContext context) {
                return [];
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageToast(Locale selectedLocale) {
    String languageName = '';
    switch (selectedLocale.languageCode) {
      case 'en':
        languageName = 'English';
        break;
      case 'hi':
        languageName = 'Hindi';
        break;
      case 'fr':
        languageName = 'French';
        break;
      case 'zh':
        languageName = 'Chinese';
        break;
      default:
        languageName = 'Unknown';
    }
    Fluttertoast.showToast(
      msg: 'You selected $languageName',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP_RIGHT,
      backgroundColor: Colors.purple,
      textColor: Colors.white,
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

class CustomPopupMenu extends StatefulWidget {
  final Widget icon;
  final List<PopupMenuEntry> menuItems;
  final Function onPressed;

  const CustomPopupMenu({
    Key? key,
    required this.icon,
    required this.menuItems,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<CustomPopupMenu> createState() => _CustomPopupMenuState();
}

class _CustomPopupMenuState extends State<CustomPopupMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _toggleMenu() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: widget.icon,
          onPressed: () {
            widget.onPressed();
            _toggleMenu();
          },
        ),
        Positioned(
          right: 0,
          bottom: 50,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: widget.menuItems,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
