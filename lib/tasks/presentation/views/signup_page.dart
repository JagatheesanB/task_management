import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import 'package:task_management/tasks/presentation/views/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_management/tasks/presentation/views/verify_screen.dart';

import '../../data/dataSources/task_datasource.dart';
import 'package:email_otp/email_otp.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  bool _passObscured = true;
  bool _confirmPassObscured = true;
  final DatabaseHelper db = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final EmailOTP myauth = EmailOTP();

  String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Email validation regex for @gmail.com and @kumaran.com only
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@(gmail\.com|kumaran\.com)$',
  );

  // Password validation regex
  final RegExp passwordRegex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&amp;*~]).{8,}$',
  );

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailIsRequired;
    } else if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.of(context)!.enterValidEmail;
    } else if (value.length > 60) {
      return AppLocalizations.of(context)!.emailMustNotExceed60Characters;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.passwordIsRequired;
    } else if (!passwordRegex.hasMatch(value)) {
      return AppLocalizations.of(context)!.passwordMustContain;
    } else if (value.length > 10) {
      return AppLocalizations.of(context)!.passwordMustNotExceed10Characters;
    }
    return null;
  }

  void signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String email = emailController.text;
    final String password = passController.text;
    final String confirmPassword = confirmPassController.text;

    if (password != confirmPassword) {
      showAwesomeSnackBar(
        AppLocalizations.of(context)!.passwordDoesNotMatch,
        ContentType.failure,
      );
      return;
    }

    final bool userExists = await db.checkUserExists(email);
    if (userExists && context.mounted) {
      showAwesomeSnackBar(
        AppLocalizations.of(context)!.userAlreadyExists,
        ContentType.failure,
      );
      return;
    }

    myauth.setConfig(
      appEmail: "jagatheesan@gmail.com",
      appName: "TimeLance",
      userEmail: email,
      otpLength: 4,
      otpType: OTPType.digitsOnly,
    );

    try {
      final otpSent = await myauth.sendOTP();
      if (otpSent == true) {
        showAwesomeSnackBar(
          AppLocalizations.of(context)!.otpHasBeenSent,
          ContentType.success,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: email,
              password: password,
              myauth: myauth,
              db: db,
              encryptPassword: encryptPassword,
            ),
          ),
        );
      } else {
        showAwesomeSnackBar(
          AppLocalizations.of(context)!.failedToSendOTP,
          ContentType.failure,
        );
        return;
      }
    } on SocketException {
      showAwesomeSnackBar(
        AppLocalizations.of(context)!.noInternetConnection,
        ContentType.failure,
      );
      return;
    } catch (e) {
      showAwesomeSnackBar(
        'An unexpected error occurred: $e',
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Lottie.asset(
                  "assets/lottie/signup.json",
                  width: 428,
                  height: 370,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.signup,
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 27,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validateEmail,
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
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.purple,
                          ),
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: validatePassword,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      obscureText: _passObscured,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.password_sharp,
                            color: Colors.black,
                          ),
                        ),
                        hintText: AppLocalizations.of(context)!.createPassword,
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.purple,
                          ),
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
                              _passObscured = !_passObscured;
                            });
                          },
                          icon: Icon(
                            _passObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: confirmPassController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .passwordIsRequired;
                        } else if (passController.text !=
                            confirmPassController.text) {
                          return AppLocalizations.of(context)!
                              .passwordDoesNotMatch;
                        }
                        return null;
                      },
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      obscureText: _confirmPassObscured,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.confirmPassword,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.password_sharp,
                            color: Colors.black,
                          ),
                        ),
                        hintText: AppLocalizations.of(context)!.confirmPassword,
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.purple,
                          ),
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
                              _confirmPassObscured = !_confirmPassObscured;
                            });
                          },
                          icon: Icon(
                            _confirmPassObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        width: 329,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.createAccount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.haveAccount,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Colors.purple,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2.5),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.login,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline),
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
      ),
    );
  }
}
