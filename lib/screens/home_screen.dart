import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedAnswer;
  List<String> _sentenceWords = [];
  List<String> _selectedOrder = [];
  bool _isPlayingAudio = false;

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
    {
      "type": "audio",
      "text": "Listen and identify the animal:",
      "audio": "assets/audio/lion-roaring-sfx-293295.mp3",
      "options": ["Lion", "Elephant", "Monkey"],
      "correctAnswer": "Lion"
    },
    {
      "type": "sentence",
      "text": "Arrange these words:",
      "words": ["I", "love", "Flutter"],
      "correctOrder": ["I", "love", "Flutter"]
    }
  ];

  @override
  void initState() {
    super.initState();
    _sentenceWords = List.from(questions[3]["words"]);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

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

                  if (question["type"] == "audio")
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlayingAudio ? Icons.pause : Icons.play_arrow,
                            size: 50,
                            color: Colors.blue,
                          ),
                          onPressed: () => _toggleAudio(question["audio"]),
                        ),
                        if (_isPlayingAudio) const LinearProgressIndicator(),
                      ],
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

  Future<void> _toggleAudio(String path) async {
    try {
      if (_isPlayingAudio) {
        await _audioPlayer.stop();
        setState(() => _isPlayingAudio = false);
      } else {
        setState(() => _isPlayingAudio = true);

        if (kIsWeb) {
          await _audioPlayer.play(UrlSource(path));
        } else {
          await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
        }

        _audioPlayer.onPlayerComplete.listen((event) {
          setState(() => _isPlayingAudio = false);
        });
      }
    } catch (e) {
      debugPrint('Audio error: $e');
      setState(() => _isPlayingAudio = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio error: ${e.toString().split('.').first}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOptions(Map<String, dynamic> question) {
    switch (question["type"]) {
      case "sentence":
        return Column(
          children: [
            Wrap(
              spacing: 8,
              children: _selectedOrder.map((word) => Chip(label: Text(word))).toList(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _sentenceWords.map((word) {
                return ActionChip(
                  label: Text(word),
                  onPressed: () => _handleWordSelect(word, question),
                );
              }).toList(),
            ),
          ],
        );

      default:
        return Column(
          children: (question["options"] as List<String>).map((option) {
            return RadioListTile(
              title: Text(option),
              value: option,
              groupValue: _selectedAnswer,
              onChanged: (value) => _handleOptionSelect(value, question),
            );
          }).toList(),
        );
    }
  }

  void _handleOptionSelect(String? value, Map<String, dynamic> question) {
    setState(() => _selectedAnswer = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value == question["correctAnswer"]
              ? "Correct! 🎉"
              : "Wrong answer! Try again ❌",
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor:
            value == question["correctAnswer"] ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleWordSelect(String word, Map<String, dynamic> question) {
    setState(() {
      _selectedOrder.add(word);
      _sentenceWords.remove(word);
    });

    if (_selectedOrder.length == question["correctOrder"].length) {
      final isCorrect = _selectedOrder.join(" ") == question["correctOrder"].join(" ");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCorrect ? "Perfect! ✅" : "Incorrect order! Try again 🔄",
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: isCorrect ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      if (isCorrect) {
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _selectedOrder.clear();
            _sentenceWords = List.from(question["words"]);
          });
        });
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _sentenceWords.addAll(_selectedOrder);
            _selectedOrder.clear();
            _sentenceWords.shuffle();
          });
        });
      }
    }
  }
}
