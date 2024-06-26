import 'dart:convert';
import 'dart:math';

// import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:task_management/tasks/data/dataSources/task_datasource.dart';
import 'package:task_management/tasks/presentation/views/home.dart';
import 'package:task_management/tasks/presentation/views/signup_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_management/tasks/utils/constants/color_generator.dart';

import '../../utils/notifications.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _isObscured = true;
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper db = DatabaseHelper();

  late Locale _locale = ref.watch(selectedLocaleProvider);

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
    _locale;
    // print(_locale);
  }

  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  login() async {
    final String email = emailController.text;
    final String password = passController.text;
    final int? id =
        await ref.read(currentUserProvider.notifier).getUserId(email);

    if (!_formKey.currentState!.validate()) {
      // AnimatedSnackBar.material(
      //   AppLocalizations.of(context)!.fieldsAreEmpty,
      //   type: AnimatedSnackBarType.error,
      // ).show(context);
      // return;
      showAwesomeSnackBar(
        AppLocalizations.of(context)!.fieldsAreEmpty,
        ContentType.failure,
      );
      return;
    }

    final String encryptedPassword = encryptPassword(password);
    // print('Original Password: $password');
    // print('Encrypted Password: $encryptedPassword');
    String emailPrefix = email.split('@').first;
    emailPrefix = emailPrefix.replaceAll(RegExp(r'[0-9]'), '').toUpperCase();

    // final bool isVerified = await db.login(email, encryptedPassword);
    final bool isVerified = await ref
        .read(authNotifierProvider.notifier)
        .login(email, encryptedPassword);
    if (isVerified) {
      ref.read(currentUserProvider.notifier).setUserId(id!);

      // loadTask(id);

      final Random random = Random();
      final String randomMessage =
          Quotes().messages[random.nextInt(Quotes().messages.length)];

      NotificationManager.showNotification(
          fileName: emailPrefix, message: randomMessage);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Home(
            email: email,
          ),
        ),
      );

      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.loginSuccessful,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_RIGHT,
        backgroundColor: Colors.purple,
        textColor: Colors.white,
      );
    } else {
      // AnimatedSnackBar.material(
      //   AppLocalizations.of(context)!.incorrectCredentials,
      //   type: AnimatedSnackBarType.error,
      // ).show(context);
      // return;
      showAwesomeSnackBar(
        AppLocalizations.of(context)!.incorrectCredentials,
        ContentType.failure,
      );
      return;
    }
  }

  void showAwesomeSnackBar(String message, ContentType contentType) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      content: AwesomeSnackbarContent(
        title: contentType == ContentType.failure ? 'error' : 'success',
        message: message,
        contentType: contentType,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // void loadTask(int id) {
  //   ref.read(taskProvider.notifier).addDefaultTasks(id);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.white,
      //   actions: [
      //     _languageselector(),
      //   ],
      // ),
      // backgroundColor: Colors.amber.shade100,
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 15),
              child: Lottie.asset(
                "assets/lottie/login.json",
                width: 400,
                height: 300,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.login,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 35,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Tooltip(
                        message: 'Language',
                        child: PopupMenuButton<Locale>(
                          icon: const Icon(Icons.language),
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
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    controller: emailController,
                    textAlign: TextAlign.start,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.emailIsRequired;
                      }
                      return null;
                    },
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.person_3,
                          color: Colors.black,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.purple,
                        ),
                      ),
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.purple,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: passController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.passwordIsRequired;
                      }
                      return null;
                    },
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.password_sharp,
                          color: Colors.black,
                        ),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.purple,
                        ),
                      ),
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.purple,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.purple,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: SizedBox(
                      width: 329,
                      height: 56,
                      child: Consumer(builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        return ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.signIn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dontHaveAccount,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        width: 2.5,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()));
                        },
                        child: Text(
                          AppLocalizations.of(context)!.signup,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
      gravity: ToastGravity.TOP_LEFT,
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
