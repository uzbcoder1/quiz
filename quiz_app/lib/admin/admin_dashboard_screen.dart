import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseHelper.instance;
    final totalQuestions = db.getAllQuestions().length;
    final totalUsers = db.getAllUsers().length;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Umumiy Statistika', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Savollar', '$totalQuestions', Icons.question_mark, Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard('Foydalanuvchilar', '$totalUsers', Icons.people, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.purple),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    "Bu admin panel orqali siz ilovadagi savollarni va foydalanuvchilarni nazorat qila olasiz. Asosiy ilova ishlashiga ta'sir qilmaydi.",
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
