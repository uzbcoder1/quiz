import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final db = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    final users = db.getAllUsers();

    if (users.isEmpty) {
      return const Center(child: Text("Foydalanuvchilar topilmadi"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final u = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
            title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(u.email),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Level: ${u.level}"),
                Text("Coins: ${u.coins}", style: const TextStyle(color: Colors.orange)),
              ],
            ),
          ),
        );
      },
    );
  }
}
