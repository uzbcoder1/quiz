import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'results_screen.dart';

class QuestionScreen extends StatefulWidget {
  final Category category;
  const QuestionScreen({super.key, required this.category});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late List<Question> questions;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    questions = DatabaseHelper.instance.getQuestionsForCategory(widget.category.id);
  }

  void _answerQuestion(String option) {
    setState(() {
      selectedOption = option;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (option == questions[currentQuestionIndex].correctOption) {
        correctAnswers++;
      }
      
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedOption = null;
        });
      } else {
        // Quiz finished
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultsScreen(correctAnswers: correctAnswers, totalQuestions: questions.length)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text("No questions found.")));
    }

    final question = questions[currentQuestionIndex];
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
            children: [
              const SizedBox(height: 10),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Question ${currentQuestionIndex + 1}/${questions.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text('${DatabaseHelper.instance.currentUser?.coins ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Timer Placeholder
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(Colors.orange),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('20s', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 40),
              // Question
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 10))
                  ],
                ),
                child: Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              // Options
              _buildOption('A', question.optionA),
              const SizedBox(height: 15),
              _buildOption('B', question.optionB),
              const SizedBox(height: 15),
              _buildOption('C', question.optionC),
              const SizedBox(height: 15),
              _buildOption('D', question.optionD),
            ],
          ),
        ),
      ),
      )
    );
  }

  Widget _buildOption(String letter, String text) {
    final isSelected = selectedOption == letter;
    final isCorrect = selectedOption != null && letter == questions[currentQuestionIndex].correctOption;
    final isWrong = isSelected && !isCorrect;

    Color? bgColor = Colors.white;
    if (selectedOption != null) {
      if (isCorrect) bgColor = Colors.green;
      else if (isWrong) bgColor = Colors.red;
      else if (letter == questions[currentQuestionIndex].correctOption) bgColor = Colors.green; // reveal correct
    }

    return GestureDetector(
      onTap: selectedOption == null ? () => _answerQuestion(letter) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (bgColor == Colors.white)
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Text(letter, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: bgColor == Colors.white ? Colors.black : Colors.white,
                  fontWeight: bgColor == Colors.white ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
