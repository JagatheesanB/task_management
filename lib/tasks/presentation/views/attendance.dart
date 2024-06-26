import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/tasks/presentation/views/attendance_history.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_management/tasks/utils/constants/exception.dart';

import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';

class AttendanceLocationScreen extends ConsumerStatefulWidget {
  const AttendanceLocationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _AttendanceLocationScreenState();
}

class _AttendanceLocationScreenState
    extends ConsumerState<AttendanceLocationScreen> {
  late Timer _timer;
  late DateTime _lastCheckInTime;
  late DateTime _lastCheckOutTime;

  String hoursString = "00", minuteString = "00", secondString = "00";
  int hours = 0, minutes = 0, seconds = 0;
  bool isTimerRunning = false;

  bool isLoading = false;
  loc.LocationData? locationData;
  List<Placemark>? placemarks;
  int workingHoursPerDay = 9;

  // final TextEditingController _workingHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    _getLocation();
    _timer = Timer(const Duration(seconds: 0), () {});
  }

  void _initializeTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = ref.read(currentUserProvider);
    final lastCheckInString = prefs.getString('lastCheckInTime_$userId');
    final isTimerRunning = prefs.getBool('isTimerRunning_$userId') ?? false;
    if (lastCheckInString != null) {
      final lastCheckIn = DateTime.parse(lastCheckInString);
      final difference = DateTime.now().difference(lastCheckIn);
      if (difference.inSeconds > 0 && isTimerRunning) {
        setState(() {
          _lastCheckInTime = lastCheckIn;
          this.isTimerRunning = true;
        });
        _startTimer();
      }
    }
    // hours = 8;
    // minutes = 59;
  }

  void _checkIn() async {
    final userId = ref.read(currentUserProvider);
    final now = DateTime.now();
    setState(() {
      _lastCheckInTime = now;
      isTimerRunning = true;
      isLoading = true;
      hours = 0;
      minutes = 0;
      seconds = 0;
      hoursString = "00";
      minuteString = "00";
      secondString = "00";
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCheckInTime_$userId', now.toIso8601String());
    await prefs.setBool('isTimerRunning_$userId', true);

    _startTimer();
    await ref
        .read(attendanceRecordProvider.notifier)
        .addAttendanceHistoryByUserId(userId!, _lastCheckInTime.toString(), '');
    // //print(_lastCheckInTime);

    await _getLocation();
    setState(() {
      isLoading = false;
    });
  }

  // periodic timer that fires every second to update the timer display.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimer();
    });
  }

  //  calculates the time difference between the current time and the last check-in time
  void _updateTimer() {
    final now = DateTime.now();
    final difference = now.difference(_lastCheckInTime);
    setState(() {
      hours = difference.inHours;
      minutes = difference.inMinutes.remainder(60);
      seconds = difference.inSeconds.remainder(60);
      hoursString = hours.toString().padLeft(2, '0');
      minuteString = minutes.toString().padLeft(2, '0');
      secondString = seconds.toString().padLeft(2, '0');
    });
  }

  void _checkOut() async {
    final userId = ref.read(currentUserProvider);
    if (isTimerRunning) {
      _timer.cancel();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastCheckInTime_$userId');
      await prefs.setBool('isTimerRunning_$userId', false);
      _lastCheckOutTime = DateTime.now();
      await ref
          .read(attendanceRecordProvider.notifier)
          .updateCheckoutTime(userId!, _lastCheckOutTime.toString());
      setState(() {
        isTimerRunning = false;
        isLoading = true;
      });
      await _getLocation();
      isLoading = false;
    }
  }

  Future<void> _getLocation() async {
    final loc.Location location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    if (locationData != null) {
      try {
        placemarks = await placemarkFromCoordinates(
            locationData!.latitude!, locationData!.longitude!);
      } catch (e) {
        CustomException("Coordinates not found ");
      }
    }
  }

  // void _updateWorkingHoursPerDay(String newValue) {
  //   final newHours = int.tryParse(newValue);
  //   if (newHours != null && newHours > 0) {
  //     setState(() {
  //       workingHoursPerDay = newHours;
  //     });
  //   }
  // }

  @override
  void dispose() async {
    // _workingHoursController.dispose();
    _timer.cancel();
    _clearUser();
    super.dispose();
  }

  Future<void> _clearUser() async {
    final userId = ref.read(currentUserProvider);
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastCheckInTime_$userId');
      await prefs.remove('isTimerRunning_$userId');
    }
  }

  Container _buildTimerBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            value.padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 50,
              fontFamily: 'poppins',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (hours + (minutes / 60)) / workingHoursPerDay;

    if (progress > 1.0) {
      progress = 1.0;
    }

    return Scaffold(
      // backgroundColor: Colors.amber.shade100,
      backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.amber.shade100,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.attendance,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            color: Colors.black,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.history,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AttendanceHistoryScreen()),
                  );
                },
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.date,
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd().format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Lottie.asset(
                "assets/lottie/location.json",
                width: 400,
                height: 170,
              ),
              const SizedBox(height: 40),
              // // Input field for workingHoursPerDay
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       const Text(
              //         'Working Hours /Day: ',
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontFamily: 'poppins',
              //           fontWeight: FontWeight.bold,
              //           fontSize: 14,
              //         ),
              //       ),
              //       SizedBox(
              //         width: 50,
              //         child: TextField(
              //           controller: _workingHoursController,
              //           keyboardType: TextInputType.number,
              //           textAlign: TextAlign.center,
              //           onChanged: _updateWorkingHoursPerDay,
              //           decoration: InputDecoration(
              //             hintText: '$workingHoursPerDay',
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimerBox(hoursString),
                  const SizedBox(width: 10),
                  const Text(
                    " : ",
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  _buildTimerBox(minuteString),
                  const SizedBox(width: 10),
                  const Text(
                    " : ",
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  _buildTimerBox(secondString),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.hours,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.minutes,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.seconds,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${AppLocalizations.of(context)!.workingHours} :  ${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isTimerRunning
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isTimerRunning ? null : _checkIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8.0),
                          Text(
                            AppLocalizations.of(context)!.checkIn,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color:
                                  isTimerRunning ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isTimerRunning
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isTimerRunning ? _checkOut : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8.0),
                          Text(
                            AppLocalizations.of(context)!.checkOut,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color:
                                  isTimerRunning ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (placemarks != null && placemarks!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Center(
                      child: Text(
                        "${placemarks![0].street},${placemarks![0].locality},${placemarks![0].postalCode}, ${placemarks![0].country}"
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 30,
                  ),
                  Text(AppLocalizations.of(context)!.notAvailable),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}
