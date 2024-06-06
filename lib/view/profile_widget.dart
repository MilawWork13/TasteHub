import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/controller/profile_page_controller.dart';
import 'package:taste_hub/controller/sign_in_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final SignInController signInController = SignInController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController reportController = TextEditingController();
    final ProfilePageController profilePageController = ProfilePageController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 0),
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
                          onChanged: null,
                        ),
                      ),
                      ListTile(
                        title: Text('Spanish', style: TextStyle(fontSize: 18)),
                        leading: Radio(
                          value: 'es',
                          groupValue: 'en',
                          onChanged: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                        'Enter your email address to receive a password reset link.',
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
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
                          String? email = emailController.text;
                          if (email.isNotEmpty) {
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email);
                              // Show a success message or navigate to a success page
                              // ignore: use_build_context_synchronously
                              showSuccessToast(context,
                                  message:
                                      'Password reset email sent. Check your inbox.');
                            } catch (e) {
                              // Show an error message if sending fails
                              // ignore: use_build_context_synchronously
                              showErrorToast(context,
                                  message:
                                      'Failed to send password reset email.');
                            }
                          } else {
                            // Show an error message if email is empty
                            showErrorToast(context,
                                message: 'Please enter your email adress.');
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
                          'Send Reset Link',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                          profilePageController
                              .saveReport(user!.email!, user.displayName!,
                                  reportController.text)
                              .then((success) {
                            if (success) {
                              // Show success toast if the report is successfully sent
                              showSuccessToast(context,
                                  message: 'Bug report sent successfully!');
                              reportController.text = '';
                            } else {
                              // Show error toast if there's an issue sending the report
                              showErrorToast(context,
                                  message: 'Failed to send bug report.');
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              const Size(150, 40), // Adjust button size
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
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                // Call the logout method from SignInController
                bool? shouldLogout = await _showLogoutDialog(context);
                if (shouldLogout == true) {
                  // ignore: use_build_context_synchronously
                  signInController.logout(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 40), // Adjust button size
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

  // Dialog to confirm logout
  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you trying to logout?'),
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
}
