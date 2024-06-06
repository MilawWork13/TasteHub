import 'package:taste_hub/controller/services/mongo_db_service.dart';

class ProfilePageController {
  late final MongoDBService mongoDBService;

  ProfilePageController() {
    initialize();
  }

  Future<void> initialize() async {
    mongoDBService = await MongoDBService.create();
  }

  Future<bool> saveReport(
      String email, String name, String reportDescription) async {
    try {
      // Call your MongoDBService method to save the bug report
      // Assuming the MongoDBService method returns a boolean indicating success
      await mongoDBService.storeBugReport(
          email: email,
          name: name,
          reportDescription: reportDescription,
          date: _getCurrentDate());
      return true; // Report saved successfully
    } catch (e) {
      print('Error saving bug report: $e');
      return false; // Failed to save report
    }
  }

  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void dispose() {
    mongoDBService.disconnect();
  }
}
