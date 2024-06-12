import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/controller/sign_in_controller.dart';
import 'package:taste_hub/view/gemini_ai_widget.dart';
import 'package:taste_hub/view/profile_widget.dart';
import 'package:taste_hub/view/suggested_page_widget.dart';
import 'package:taste_hub/view/your_recipes_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SignInController _signInController =
      SignInController(); // Instance of SignInController
  int _selectedIndex = 0; // Index of the selected bottom navigation bar item
  final User? user =
      FirebaseAuth.instance.currentUser; // Current Firebase user instance

  @override
  void initState() {
    super.initState();
    // Initialization logic can be added here if needed
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index based on tapped item
    });
  }

  // Pages to display in the indexed stack based on bottom navigation bar selection
  final List<Widget> _pages = <Widget>[
    const SuggestedPage(), // Widget for suggested content
    const FavoriteRecipesPage(), // Widget for favorite recipes
    const AiChatPage(), // Widget for AI chat functionality
    const ProfilePage(), // Widget for user profile
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable popping from this page
      // ignore: deprecated_member_use
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldLogout = await _showLogoutDialog() ?? false;
        if (shouldLogout) {
          // ignore: use_build_context_synchronously
          await _signInController
              .logout(context); // Logout action handled by SignInController
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages, // Display the selected page from _pages list
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.restaurant,
                color: Colors.red,
              ),
              label: 'Home', // Label for the Home bottom navigation bar item
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_outlined,
                color: Colors.red,
              ),
              label:
                  'Your Recipes', // Label for the Your Recipes bottom navigation bar item
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.auto_awesome,
                color: Colors.red,
              ),
              label:
                  'AI Chat', // Label for the AI Chat bottom navigation bar item
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: Colors.red,
              ),
              label:
                  'Profile', // Label for the Profile bottom navigation bar item
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor:
              Colors.red, // Color of the selected bottom navigation bar item
          onTap: _onItemTapped, // Callback function when an item is tapped
        ),
      ),
    );
  }

  // Show a confirmation dialog when attempting to logout
  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you trying to logout?'), // Dialog title
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'), // Option to cancel logout
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'), // Option to confirm logout
            ),
          ],
        );
      },
    );
  }
}
