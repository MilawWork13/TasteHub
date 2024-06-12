import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/controller/sign_in_controller.dart';
import 'package:taste_hub/view/admin_reports_widget.dart';
import 'package:taste_hub/view/admin_user_widget.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final SignInController _signInController = SignInController();
  int _selectedIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = <Widget>[
    const AdminReportPage(), // AdminReportPage widget added to the indexed stack
    const ManageUsersPage(), // ManageUsersPage widget added to the indexed stack
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldLogout =
            await _showLogoutDialog() ?? false; // Show logout dialog
        if (shouldLogout) {
          // ignore: use_build_context_synchronously
          await _signInController
              .logout(context); // Logout action handled by SignInController
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard,
                color: Colors.red,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.people,
                color: Colors.red,
              ),
              label: 'Manage Users',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.red,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  // Method to show the logout dialog
  Future<bool?> _showLogoutDialog() {
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
