import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  final db = DatabaseHelper.instance;

  void _deleteQuestion(int id) async {
    await db.deleteQuestion(id);
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Savol o'chirildi")));
  }

  void _showAddQuestionDialog() {
    final textController = TextEditingController();
    final aController = TextEditingController();
    final bController = TextEditingController();
    final cController = TextEditingController();
    final dController = TextEditingController();
    String correctOption = 'A';
    int categoryId = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Yangi savol qo'shish"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: categoryId,
                  isExpanded: true,
                  items: db.getCategories().map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) => setDialogState(() => categoryId = val!),
                ),
                TextField(controller: textController, decoration: const InputDecoration(labelText: 'Savol matni')),
                TextField(controller: aController, decoration: const InputDecoration(labelText: 'Variant A')),
                TextField(controller: bController, decoration: const InputDecoration(labelText: 'Variant B')),
                TextField(controller: cController, decoration: const InputDecoration(labelText: 'Variant C')),
                TextField(controller: dController, decoration: const InputDecoration(labelText: 'Variant D')),
                const SizedBox(height: 10),
                const Text("To'g'ri javob:"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['A', 'B', 'C', 'D'].map((opt) => Row(
                    children: [
                      Radio<String>(
                        value: opt,
                        groupValue: correctOption,
                        onChanged: (val) => setDialogState(() => correctOption = val!),
                      ),
                      Text(opt),
                    ],
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Bekor qilish")),
            ElevatedButton(
              onPressed: () async {
                if (textController.text.isEmpty) return;
                final newQ = Question(
                  id: DateTime.now().millisecondsSinceEpoch,
                  categoryId: categoryId,
                  questionText: textController.text,
                  optionA: aController.text,
                  optionB: bController.text,
                  optionC: cController.text,
                  optionD: dController.text,
                  correctOption: correctOption,
                );
                await db.addQuestion(newQ);
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Qo'shish"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = db.getAllQuestions();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddQuestionDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(q.questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Kat: ${db.getCategories().firstWhere((c) => c.id == q.categoryId).name} | Javob: ${q.correctOption}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteQuestion(q.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
