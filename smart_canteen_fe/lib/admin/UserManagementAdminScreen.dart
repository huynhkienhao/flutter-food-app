import 'package:flutter/material.dart';
import 'package:smart_canteen_fe/services/user_service.dart';

class UserManagementAdminScreen extends StatefulWidget {
  @override
  _UserManagementAdminScreenState createState() => _UserManagementAdminScreenState();
}

class _UserManagementAdminScreenState extends State<UserManagementAdminScreen> {
  final UserService userService = UserService();
  List<dynamic> adminUsers = [];
  List<dynamic> regularUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsersForTabs();
  }

  Future<void> _loadUsersForTabs() async {
    try {
      final admins = await userService.getUsersForCurrentTab(true);
      final users = await userService.getUsersForCurrentTab(false);
      setState(() {
        adminUsers = admins;
        regularUsers = users;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load users: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(BuildContext context, String userId) async {
    try {
      await userService.deleteUser(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User deleted successfully")),
      );
      _loadUsersForTabs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete user: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("User Management"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Admins"),
              Tab(text: "Users"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Admin Users Tab
            isLoading
                ? Center(child: CircularProgressIndicator())
                : adminUsers.isEmpty
                ? Center(child: Text("No admin accounts found."))
                : ListView.builder(
              itemCount: adminUsers.length,
              itemBuilder: (context, index) {
                final user = adminUsers[index];
                return ListTile(
                  title: Text("Username: ${user['userName']}"),
                  subtitle: Text("Email: ${user['email']} | ID: ${user['id']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(context, user['id']),
                  ),
                );
              },
            ),

            // Regular Users Tab
            isLoading
                ? Center(child: CircularProgressIndicator())
                : regularUsers.isEmpty
                ? Center(child: Text("No user accounts found."))
                : ListView.builder(
              itemCount: regularUsers.length,
              itemBuilder: (context, index) {
                final user = regularUsers[index];
                return ListTile(
                  title: Text("Username: ${user['userName']}"),
                  subtitle: Text("Email: ${user['email']} | ID: ${user['id']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(context, user['id']),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
