import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/controller/profile_page_controller.dart';
import 'package:taste_hub/controller/sign_in_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve current user information
    final User? user = FirebaseAuth.instance.currentUser;

    // Controllers for handling user input
    final TextEditingController reportController = TextEditingController();

    // Controllers for handling user actions and data
    final SignInController signInController = SignInController();
    final ProfilePageController profilePageController = ProfilePageController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(), // Hide app bar title
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User welcome section
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '[ We\'re glad to have you back! ]',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? 'Guest',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Thank you message container
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thank you for supporting us!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'As a local business, we thank you for supporting us and hope you enjoy.',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Language selection tile
          const Align(
            alignment: Alignment.centerRight,
            child: ExpansionTile(
              leading: Icon(Icons.language, color: Colors.red),
              title: Text(
                'Language',
                style: TextStyle(fontSize: 19, color: Colors.black),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('English', style: TextStyle(fontSize: 18)),
                        leading: Radio(
                          value: 'en',
                          groupValue: 'en',
                          onChanged: null, // No action on language change
                        ),
                      ),
                      ListTile(
                        title: Text('Spanish', style: TextStyle(fontSize: 18)),
                        leading: Radio(
                          value: 'es',
                          groupValue: 'en',
                          onChanged: null, // No action on language change
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Forgot password section
          Align(
            alignment: Alignment.centerRight,
            child: ExpansionTile(
              leading: const Icon(Icons.lock_reset, color: Colors.red),
              title: const Text(
                'Forgot your password?',
                style: TextStyle(fontSize: 19, color: Colors.black),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Click on the button to send you a link to reset your password.',
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // Send password reset email functionality
                          String? email = user?.email;
                          if (email != null) {
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email);
                              // Show success message
                              // ignore: use_build_context_synchronously
                              showSuccessToast(context,
                                  message:
                                      'Password reset email sent. Check your inbox.');
                            } catch (e) {
                              // Show error message
                              // ignore: use_build_context_synchronously
                              showErrorToast(context,
                                  message:
                                      'Failed to send password reset email.');
                            }
                          } else {
                            // Show error message for empty email (though user shouldn't reach here)
                            showErrorToast(context,
                                message: 'Unable to retrieve email.');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(150, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bug report section
          Align(
            alignment: Alignment.centerRight,
            child: ExpansionTile(
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: const Text(
                'Found a bug? Send a report.',
                style: TextStyle(fontSize: 19, color: Colors.black),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        maxLines: 4,
                        controller: reportController,
                        decoration: const InputDecoration(
                          labelText: 'Describe the issue',
                          labelStyle: TextStyle(fontSize: 17),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          String displayName = user?.displayName ?? 'Anonymous';
                          // Submit bug report functionality
                          profilePageController
                              .saveReport(generateRandomNumber(), user!.email!,
                                  displayName, reportController.text, 'pending')
                              .then((success) {
                            if (success) {
                              // Show success toast
                              // ignore: use_build_context_synchronously
                              showSuccessToast(context,
                                  message: 'Bug report sent successfully!');
                              reportController.text = '';
                            } else {
                              // Show error toast
                              // ignore: use_build_context_synchronously
                              showErrorToast(context,
                                  message: 'Failed to send bug report.');
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(150, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                // Show logout confirmation dialog
                bool? shouldLogout = await _showLogoutDialog(context);
                if (shouldLogout == true) {
                  // Logout user
                  // ignore: use_build_context_synchronously
                  signInController.logout(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to display logout confirmation dialog
  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Function to generate a random number for bug report ID
  int generateRandomNumber() {
    Random random = Random();
    int min = 100000;
    int max = 999999;
    return min + random.nextInt(max - min);
  }
}
