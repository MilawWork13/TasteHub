import 'package:flutter/material.dart';
import 'package:taste_hub/controller/admin_page_controller.dart';
import 'package:taste_hub/model/User.dart';
import 'package:taste_hub/components/user_card.dart'; // Assuming you'll create a UserCard widget

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ManageUsersPageState createState() => ManageUsersPageState();
}

class ManageUsersPageState extends State<ManageUsersPage> {
  final AdminPageController _controller = AdminPageController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  // Method to refresh the users list
  Future<void> _refreshUsers() async {
    await _controller.refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Manage Users',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: ValueListenableBuilder<List<UserModel>>(
          valueListenable: _controller.users,
          builder: (context, users, _) {
            if (users.isEmpty) {
              return const Center(
                child: Text(
                  'No users found.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserCard(
                    userName: user.name,
                    userEmail: user.email,
                    onDisable: () async {
                      _controller.disableUserByEmail(
                          users[index].email); // Method to disable user
                    },
                    onDelete: () async {
                      _controller.deleteUserByEmail(
                          users[index].email, context); // Method to delete user
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
