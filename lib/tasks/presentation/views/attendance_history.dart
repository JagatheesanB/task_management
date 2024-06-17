import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  late DateTime selectedDate;
  late Future<List<Map<String, dynamic>>> futureAttendanceRecords;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    futureAttendanceRecords = _fetchAttendanceRecords(selectedDate);
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceRecords(
      DateTime selectedDate) async {
    final userId = ref.read(currentUserProvider)?.toString();
    if (userId != null) {
      try {
        final attendanceRecords = await ref
            .watch(attendanceRecordProvider.notifier)
            .fetchAttendanceRecordsByUserId(userId);
        return attendanceRecords.where((attendance) {
          final checkIn = DateTime.parse(attendance['checkInTime']!);
          final checkInDate =
              DateTime(checkIn.year, checkIn.month, checkIn.day);
          return checkInDate.isAtSameMomentAs(selectedDate);
        }).toList();
      } catch (error) {
        // Handle error appropriately
        // print('Error fetching attendance records: $error');
        return [];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.attendanceHistory,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.selectDate,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.date_range),
            onTap: () async {
              // picking date and state update
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                  futureAttendanceRecords =
                      _fetchAttendanceRecords(selectedDate);
                });
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${AppLocalizations.of(context)!.selectedDate}: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureAttendanceRecords,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final attendanceList = snapshot.data!;
                  if (attendanceList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/lottie/empty.json',
                            width: 180,
                            height: 170,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!
                                .noRecordsAvailableForThisDate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: attendanceList.length,
                      itemBuilder: (context, index) {
                        final attendance = attendanceList[index];
                        final checkIn =
                            DateTime.parse(attendance['checkInTime']!);
                        final checkOut = attendance['checkOutTime'] != null
                            ? DateTime.parse(attendance['checkOutTime']!)
                            : DateTime.utc(2000, 1, 1);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${attendance['date'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Check-In: ${_formatDateTime(checkIn)}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'poppins',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 50,
                                    ),
                                    Text(
                                      'Check-Out: ${_formatDateTime(checkOut)}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'poppins',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
