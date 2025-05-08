import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedImageAnswer;
  String? _selectedTextAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      "type": "fill",
      "text": "Complete the sentence: The cat ___ on the mat.",
      "options": ["sat", "sit", "sitting"],
      "correctAnswer": "sat" 
    },
    {
      "type": "image_match",
      "text": "What do you see?",
      "image": "assets/images/owl.jpg",
      "options": ["Owl", "Pigeon", "Hawk"],
      "correctAnswer": "Owl"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Questions")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: questions.map((question) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question["text"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (question["type"] == "image_match")
                    Image.asset(
                      question["image"],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  
                  const SizedBox(height: 12),
                  _buildOptions(question),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptions(Map<String, dynamic> question) {
    return Column(
      children: (question["options"] as List<String>).map((option) {
        final isSelected = question["type"] == "image_match"
            ? _selectedImageAnswer == option
            : _selectedTextAnswer == option;

        return ListTile(
          title: Text(option),
          leading: Radio<String>(
            value: option,
            groupValue: question["type"] == "image_match"
                ? _selectedImageAnswer
                : _selectedTextAnswer,
            onChanged: (value) {
              setState(() {
                if (question["type"] == "image_match") {
                  _selectedImageAnswer = value;
                } else {
                  _selectedTextAnswer = value;
                }
              });
              
              _showFeedback(
                context,
                isCorrect: value == question["correctAnswer"],
              );
            },
          ),
        );
      }).toList(),
    );
  }

  void _showFeedback(BuildContext context, {required bool isCorrect}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct! ✅" : "Try again! ❌"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1), 
      ),
    );
  }
}