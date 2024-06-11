class AttendanceRecord {
  final int? id;
  final int userId;
  final String checkInTime;
  final String checkOutTime;
  final DateTime? date;

  AttendanceRecord({
    this.id,
    required this.userId,
    required this.checkInTime,
    required this.checkOutTime,
    this.date,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      userId: map['userId'],
      checkInTime: map['checkInTime'],
      checkOutTime: map['checkOutTime'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    String formattedDate =
        date?.toString().split(' ')[0].split('-').reversed.join('/') ?? '';
    return {
      'id': id,
      'userId': userId,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'date': formattedDate,
    };
  }
}
