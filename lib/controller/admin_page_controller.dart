import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/Report.dart';
import 'package:taste_hub/model/User.dart';

class AdminPageController {
  ValueNotifier<List<Report>> reports = ValueNotifier<List<Report>>([]);
  ValueNotifier<List<UserModel>> users = ValueNotifier<List<UserModel>>([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late MongoDBService _mongoDBService;

  // Initialize the controller
  Future<void> initialize() async {
    _mongoDBService = await MongoDBService.create();
    await fetchReports();
    await fetchUsers();
  }

  // Fetch all reports from the database
  Future<void> fetchReports() async {
    final fetchedReports = await _mongoDBService.getAllReports();
    reports.value = fetchedReports;
  }

  // Fetch all users from the database
  Future<void> fetchUsers() async {
    final fetchedUsers = await _mongoDBService.getAllUsers();
    users.value = fetchedUsers;
  }

  // Solve the report with the given ID
  Future<void> solveReport(ObjectId reportId) async {
    await _mongoDBService.solveReport(reportId);
  }

  // Reopen the report with the given ID
  Future<void> reopenReport(ObjectId reportId) async {
    await _mongoDBService.reopenReport(reportId);
  }

  // Delete the report with the given ID
  Future<void> deleteReport(ObjectId reportId) async {
    await _mongoDBService.deleteReport(reportId);
  }

  // Refresh the reports list
  Future<void> refreshReports() async {
    await fetchReports();
  }

  // Refresh the users list
  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  // Disable the user account with the given email
  Future<void> disableUserByEmail(String userEmail) async {
    try {
      // Get user by email
      var userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();
      if (userQuery.docs.isNotEmpty) {
        var userId = userQuery.docs.first.id;
        await _firestore
            .collection('users')
            .doc(userId)
            .update({'disabled': true});
        if (kDebugMode) {
          print('User account disabled successfully.');
        }
        await fetchUsers();
      } else {
        if (kDebugMode) {
          print('User not found with email: $userEmail');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disabling user account: $e');
      }
    }
  }

  // Enable the user account with the given email
  Future<void> deleteUserByEmail(String userEmail, BuildContext context) async {
    try {
      // Get user by email
      var userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();
      if (userQuery.docs.isNotEmpty) {
        var userId = userQuery.docs.first.id;

        // Show dialog to confirm deletion
        bool confirmDelete = await showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                  'Are you sure you want to delete this user account?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );

        if (confirmDelete) {
          await _firestore.collection('users').doc(userId).delete();
          if (kDebugMode) {
            print('User account deleted successfully.');
          }
          await fetchUsers();
        }
      } else {
        if (kDebugMode) {
          print('User not found with email: $userEmail');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user account: $e');
      }
    }
  }
}
