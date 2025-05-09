import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF6A1B9A), 
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ApiService {
  Future<bool> login() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  List<String> _sentenceWords = [];
  List<String> _selectedOrder = [];
  String? _selectedAnswer;
  bool _isLoading = true;
  bool _isPlayingAudio = false;
  String? _error;
  int _score = 0;
  AudioState _audioState = AudioState.idle;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final loggedIn = await _api.login();
      if (!loggedIn) throw Exception('Login failed');

      final questions = await _api.getQuestions();
      setState(() {
        _questions = questions.isNotEmpty ? questions : _getFallbackQuestions();
        _sentenceWords = List.from(_questions[_currentQuestionIndex]["words"] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _questions = _getFallbackQuestions();
        _sentenceWords = List.from(_questions[_currentQuestionIndex]["words"] ?? []);
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackQuestions() {
    return [
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
        "correctOrder": ["I", "love", "Flutter"] }];}
      
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < _questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _selectedOrder.clear();
        _sentenceWords = List.from(_questions[_currentQuestionIndex]["words"] ?? []);
        _audioState = AudioState.idle;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(score: _score, total: _questions.length)),
      );
    }
  }

  Future<void> _toggleAudio(String path) async {
    try {
      if (_isPlayingAudio) {
        await _audioPlayer.stop();
        setState(() {
          _isPlayingAudio = false;
          _audioState = AudioState.idle;
        });
      } else {
        setState(() {
          _isPlayingAudio = true;
          _audioState = AudioState.playing;
        });

        if (kIsWeb) {
          await _audioPlayer.play(UrlSource(path));
        } else {
          await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
        }

        _audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            _isPlayingAudio = false;
            _audioState = AudioState.completed;
          });
        });
      }
    } catch (e) {
      setState(() {
        _isPlayingAudio = false;
        _audioState = AudioState.error;
      });
    }
  }

  void _handleOptionSelect(String? value, Map<String, dynamic> question) {
    final isCorrect = value == question["correctAnswer"];
    if (isCorrect) _score++;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? "Correct! 🎉" : "Wrong answer! Try again ❌",
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(seconds: 1), _nextQuestion);
  }

  void _handleWordSelect(String word, Map<String, dynamic> question) {
    setState(() {
      _selectedOrder.add(word);
      _sentenceWords.remove(word);
    });

    if (_selectedOrder.length == question["correctOrder"].length) {
      final isCorrect = _selectedOrder.join(" ") == question["correctOrder"].join(" ");
      if (isCorrect) _score++;

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

      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  Color _getAudioIconColor() {
    switch (_audioState) {
      case AudioState.playing:
        return Colors.purpleAccent;
      case AudioState.completed:
        return Colors.green;
      case AudioState.error:
        return Colors.red;
      case AudioState.idle:
      default:
        return Colors.purple;
    }
  }

  IconData _getAudioIcon() {
    switch (_audioState) {
      case AudioState.playing:
        return Icons.pause;
      case AudioState.completed:
        return Icons.check;
      case AudioState.error:
        return Icons.error;
      case AudioState.idle:
      default:
        return Icons.play_arrow;
    }
  }

  String _getAudioStateText() {
    switch (_audioState) {
      case AudioState.playing:
        return "Listening...";
      case AudioState.completed:
        return "Completed!";
      case AudioState.error:
        return "Error occurred";
      case AudioState.idle:
      default:
        return "Tap to listen";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[200]!),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Play and learn"),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Question Box
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          question["text"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (question["type"] == "image_match")
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.purple[300]!, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                question["image"],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                        if (question["type"] == "audio")
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _toggleAudio(question["audio"]),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: _getAudioIconColor(),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getAudioIcon(),
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _getAudioStateText(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_isPlayingAudio) ...[
                                  const SizedBox(height: 16),
                                  LinearProgressIndicator(
                                    backgroundColor: Colors.purple[100],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.purple[400]!,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: _buildOptions(question),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(Map<String, dynamic> question) {
    switch (question["type"]) {
      case "sentence":
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedOrder.map((word) => Chip(
                  label: Text(
                    word,
                    style: const TextStyle(fontSize: 16),
                  ),
                  backgroundColor: Colors.purple,
                  labelStyle: const TextStyle(color: Colors.white),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sentenceWords.map((word) {
                return ActionChip(
                  label: Text(
                    word,
                    style: const TextStyle(fontSize: 16),
                  ),
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(color: Colors.purple),
                  ),
                  onPressed: () => _handleWordSelect(word, question),
                );
              }).toList(),
            ),
          ],
        );

      default:
        return Column(
          children: (question["options"] as List<String>).map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.purple),
                  ),
                ),
                onPressed: () {
                  setState(() => _selectedAnswer = option);
                  _handleOptionSelect(option, question);
                },
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }).toList(),
        );
    }
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).round();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Results"),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your Score",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "$score / $total",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.purple[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 70 ? Colors.green : 
                        percentage > 40 ? Colors.orange : Colors.red,
                      ),
                      strokeWidth: 10,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      percentage > 70 ? "Excellent! 🎉" : 
                      percentage > 40 ? "Good job! 👍" : "Keep practicing! 💪",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.purple[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
enum AudioState {
  idle,
  playing,
  completed,
  error,
}