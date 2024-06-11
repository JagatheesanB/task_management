import 'dart:convert';
import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _isObscured = true;

  final DatabaseHelper db = DatabaseHelper();

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

    if (email.isEmpty || password.isEmpty) {
      AnimatedSnackBar.material(
        AppLocalizations.of(context)!.fieldsAreEmpty,
        type: AnimatedSnackBarType.error,
      ).show(context);
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
      AnimatedSnackBar.material(
        AppLocalizations.of(context)!.incorrectCredentials,
        type: AnimatedSnackBarType.error,
      ).show(context);
      return;
    }
  }

  // void loadTask(int id) {
  //   ref.read(taskProvider.notifier).addDefaultTasks(id);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Colors.amber.shade100,
      backgroundColor: Colors.white,
      body: Column(
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
                Text(
                  AppLocalizations.of(context)!.login,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 35,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  controller: emailController,
                  textAlign: TextAlign.start,
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
                TextField(
                  controller: passController,
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
    );
  }
}

// import 'dart:convert';
// import 'dart:math';

// import 'package:animated_snack_bar/animated_snack_bar.dart';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:lottie/lottie.dart';
// import 'package:task_management/tasks/data/dataSources/task_datasource.dart';
// import 'package:task_management/tasks/presentation/views/home.dart';
// import 'package:task_management/tasks/presentation/views/signup_page.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:task_management/tasks/utils/constants/color_generator.dart';
// import 'package:local_auth/local_auth.dart';

// import '../../utils/notifications.dart';
// import '../providers/auth_provider.dart';

// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passController = TextEditingController();
//   bool _isObscured = true;
//   final LocalAuthentication _auth = LocalAuthentication();

//   final DatabaseHelper db = DatabaseHelper();

//   String encryptPassword(String password) {
//     final bytes = utf8.encode(password);
//     final hash = sha256.convert(bytes);
//     return hash.toString();
//   }

//   login() async {
//     final String email = emailController.text;
//     final String password = passController.text;
//     final int? id =
//         await ref.read(currentUserProvider.notifier).getUserId(email);

//     if (email.isEmpty || password.isEmpty) {
//       AnimatedSnackBar.material(
//         AppLocalizations.of(context)!.fieldsAreEmpty,
//         type: AnimatedSnackBarType.error,
//       ).show(context);
//       return;
//     }

//     final String encryptedPassword = encryptPassword(password);
//     String emailPrefix = email.split('@').first;
//     emailPrefix = emailPrefix.replaceAll(RegExp(r'[0-9]'), '').toUpperCase();

//     final bool isVerified = await db.login(email, encryptedPassword);
//     if (isVerified) {
//       ref.read(currentUserProvider.notifier).setUserId(id!);
//       final Random random = Random();
//       final String randomMessage =
//           Quotes().messages[random.nextInt(Quotes().messages.length)];
//       NotificationManager.showNotification(
//           fileName: emailPrefix, message: randomMessage);
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => Home(
//             email: email,
//           ),
//         ),
//       );
//       Fluttertoast.showToast(
//         msg: AppLocalizations.of(context)!.loginSuccessful,
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.TOP_RIGHT,
//         backgroundColor: Colors.purple,
//         textColor: Colors.white,
//       );
//     } else {
//       AnimatedSnackBar.material(
//         AppLocalizations.of(context)!.incorrectCredentials,
//         type: AnimatedSnackBarType.error,
//       ).show(context);
//       return;
//     }
//   }

//   Future<void> _authenticateWithBiometrics() async {
//     try {
//       final bool canAuthUsingBiometrics = await _auth.canCheckBiometrics;
//       if (canAuthUsingBiometrics) {
//         final bool didAuthUsingBiometrics = await _auth.authenticate(
//           localizedReason: 'Please authenticate using biometrics',
//           options: const AuthenticationOptions(
//             biometricOnly: true,
//           ),
//         );
//         if (didAuthUsingBiometrics) {
//           const String biometricId = "";
//           final String? email = await db.getUserEmailByBiometricId(biometricId);
//           print('bio email - $email');
//           final int? id =
//               await ref.read(currentUserProvider.notifier).getUserId(email!);
//           ref.read(currentUserProvider.notifier).setUserId(id!);

//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) => Home(
//                 email: email,
//               ),
//             ),
//           );

//           Fluttertoast.showToast(
//             msg: AppLocalizations.of(context)!.loginSuccessful,
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.TOP_RIGHT,
//             backgroundColor: Colors.purple,
//             textColor: Colors.white,
//           );
//         } else {
//           AnimatedSnackBar.material(
//             'Biometric authentication failed',
//             type: AnimatedSnackBarType.error,
//           ).show(context);
//         }
//       }
//     } catch (e) {
//       AnimatedSnackBar.material(
//         'Error during authentication: $e',
//         type: AnimatedSnackBarType.error,
//       ).show(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.white,
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 15, top: 15),
//             child: Lottie.asset(
//               "assets/lottie/login.json",
//               width: 400,
//               height: 300,
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 50),
//             child: Column(
//               textDirection: TextDirection.ltr,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   AppLocalizations.of(context)!.login,
//                   style: const TextStyle(
//                     color: Colors.purple,
//                     fontSize: 35,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 40,
//                 ),
//                 TextField(
//                   controller: emailController,
//                   textAlign: TextAlign.start,
//                   style: const TextStyle(
//                     color: Color.fromARGB(255, 0, 0, 0),
//                     fontSize: 13,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w400,
//                   ),
//                   decoration: InputDecoration(
//                     labelText: AppLocalizations.of(context)!.email,
//                     prefixIcon: const Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Icon(
//                         Icons.person_3,
//                         color: Colors.black,
//                       ),
//                     ),
//                     labelStyle: const TextStyle(
//                       color: Color.fromARGB(255, 0, 0, 0),
//                       fontSize: 15,
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                     ),
//                     enabledBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                       borderSide: BorderSide(
//                         width: 1,
//                         color: Colors.purple,
//                       ),
//                     ),
//                     focusedBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                       borderSide: BorderSide(
//                         width: 1,
//                         color: Colors.purple,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 TextField(
//                   controller: passController,
//                   textAlign: TextAlign.start,
//                   style: const TextStyle(
//                     color: Color.fromARGB(255, 0, 0, 0),
//                     fontSize: 13,
//                     fontFamily: 'Poppins',
//                     fontWeight: FontWeight.w400,
//                   ),
//                   obscureText: _isObscured,
//                   decoration: InputDecoration(
//                     labelText: AppLocalizations.of(context)!.password,
//                     prefixIcon: const Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Icon(
//                         Icons.password_sharp,
//                         color: Colors.black,
//                       ),
//                     ),
//                     labelStyle: const TextStyle(
//                       color: Color.fromARGB(255, 0, 0, 0),
//                       fontSize: 15,
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                     ),
//                     enabledBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                       borderSide: BorderSide(
//                         width: 1,
//                         color: Colors.purple,
//                       ),
//                     ),
//                     focusedBorder: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)),
//                       borderSide: BorderSide(
//                         width: 1,
//                         color: Colors.purple,
//                       ),
//                     ),
//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _isObscured = !_isObscured;
//                         });
//                       },
//                       icon: Icon(
//                         _isObscured ? Icons.visibility_off : Icons.visibility,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 ClipRRect(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   child: SizedBox(
//                     width: 329,
//                     height: 56,
//                     child: Consumer(builder:
//                         (BuildContext context, WidgetRef ref, Widget? child) {
//                       return ElevatedButton(
//                         onPressed: login,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.purple,
//                         ),
//                         child: Text(
//                           AppLocalizations.of(context)!.signIn,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 FloatingActionButton(
//                   onPressed: _authenticateWithBiometrics,
//                   child: const Icon(Icons.fingerprint),
//                   backgroundColor: Colors.purple,
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       AppLocalizations.of(context)!.dontHaveAccount,
//                       style: const TextStyle(
//                         color: Colors.purple,
//                         fontSize: 18,
//                         fontFamily: 'Poppins',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 2.5,
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const SignUpScreen()));
//                       },
//                       child: Text(
//                         AppLocalizations.of(context)!.signup,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontFamily: 'Poppins',
//                           fontWeight: FontWeight.w500,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
