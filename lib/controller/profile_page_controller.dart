import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';

class ProfilePageController {
  late final MongoDBService mongoDBService;

  ProfilePageController() {
    initialize();
  }

  // Initialize the MongoDB service
  Future<void> initialize() async {
    mongoDBService = await MongoDBService.create();
  }

  // Save the bug report to the database
  Future<bool> saveReport(int reportNum, String email, String name,
      String reportDescription, String status) async {
    try {
      await mongoDBService.storeBugReport(
          id: ObjectId(),
          reportNum: reportNum,
          email: email,
          name: name,
          reportDescription: reportDescription,
          date: _getCurrentDate(),
          status: status);
      return true; // Report saved successfully
    } catch (e) {
      if (kDebugMode) {
        print('Error saving bug report: $e');
      }
      return false; // Failed to save report
    }
  }

  // Get the current date in the format 'YYYY-MM-DD'
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void dispose() {
    mongoDBService.disconnect();
  }
}
