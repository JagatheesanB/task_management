import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/tasks/data/dataSources/task_datasource.dart';
import 'package:task_management/tasks/presentation/views/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:async';

import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final EmailOTP myauth;
  final Function encryptPassword;
  final DatabaseHelper db;

  const OtpScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.myauth,
    required this.db,
    required this.encryptPassword,
  }) : super(key: key);

  @override
  ConsumerState createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController otpController1 = TextEditingController();
  final TextEditingController otpController2 = TextEditingController();
  final TextEditingController otpController3 = TextEditingController();
  final TextEditingController otpController4 = TextEditingController();

  Timer? _timer;
  int _start = 60; // 1 minutes in seconds
  bool _isOtpExpired = false;
  final bool _isOtpVerified = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    otpController1.dispose();
    otpController2.dispose();
    otpController3.dispose();
    otpController4.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _start = 60; // Reset to 1 minutes
    _isOtpExpired = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isOtpExpired = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String get timerText {
    // final minutes = (_start ~/ 60).toString().padLeft(2, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return seconds;
  }

  void sendOtp() async {
    await widget.myauth.sendOTP();
    if (context.mounted) {
      showAwesomeSnackBar(
        AppLocalizations.of(context)!.otpHasBeenSent,
        ContentType.success,
      );
    }
  }

  void resendOtp() async {
    setState(() {
      _isOtpExpired = false;
    });
    await widget.myauth.sendOTP();
    startTimer();
    if (context.mounted) {
      showAwesomeSnackBar(
        AppLocalizations.of(context)!.otpHasBeenResent,
        ContentType.help,
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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.verifyOTP,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context)!.enterTheOTPSentToYourEmail,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOtpField(otpController1),
                  _buildOtpField(otpController2),
                  _buildOtpField(otpController3),
                  _buildOtpField(otpController4),
                ],
              ),
              const SizedBox(height: 30),
              if (!_isOtpVerified && !_isOtpExpired) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final otp = otpController1.text +
                          otpController2.text +
                          otpController3.text +
                          otpController4.text;
                      if (await widget.myauth.verifyOTP(otp: otp)) {
                        final encryptedPassword =
                            widget.encryptPassword(widget.password);
                        // await widget.db.signup(widget.email, encryptedPassword);
                        await ref
                            .read(authNotifierProvider.notifier)
                            .signup(widget.email, encryptedPassword);
                        if (context.mounted) {
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                          showAwesomeSnackBar(
                            AppLocalizations.of(context)!.otpIsVerified,
                            ContentType.success,
                          );
                        }
                      } else {
                        if (context.mounted) {
                          showAwesomeSnackBar(
                            AppLocalizations.of(context)!.invalidOTP,
                            ContentType.failure,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.verifyOTP,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Time remaining: $timerText",
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (_isOtpExpired)
                Text(
                  AppLocalizations.of(context)!.otpHasExpired,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              if (!_isOtpVerified)
                TextButton(
                  onPressed: _isOtpExpired ? resendOtp : null,
                  child: Text(
                    AppLocalizations.of(context)!.resendOTP,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(TextEditingController otpController) {
    return SizedBox(
      width: 50,
      child: TextFormField(
        controller: otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: '0',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 24,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}
