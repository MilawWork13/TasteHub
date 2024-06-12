import 'package:mongo_dart/mongo_dart.dart';

// Report class
class Report {
  final ObjectId id;
  final int reportNum;
  final String userEmail;
  final String userName;
  final String reportDescription;
  final String date;
  final String status;

  // Constructor
  Report({
    required this.id,
    required this.reportNum,
    required this.userEmail,
    required this.userName,
    required this.reportDescription,
    required this.date,
    required this.status,
  });

  // Convert from JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'],
      reportNum: json['reportNum'],
      userEmail: json['userEmail'],
      userName: json['userName'],
      reportDescription: json['reportDescription'],
      date: json['date'],
      status: json['status'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reportNum': reportNum,
      'userEmail': userEmail,
      'userName': userName,
      'reportDescription': reportDescription,
      'date': date,
      'status': status,
    };
  }
}
