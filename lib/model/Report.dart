class Report {
  final String userEmail;
  final String userName;
  final String reportDescription;
  final String date;

  Report({
    required this.userEmail,
    required this.userName,
    required this.reportDescription,
    required this.date,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      userEmail: json['userEmail'],
      userName: json['userName'],
      reportDescription: json['reportDescription'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'userName': userName,
      'reportDescription': reportDescription,
      'date': date,
    };
  }
}
