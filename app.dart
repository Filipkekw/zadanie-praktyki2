import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(CoNiePasujeApp());
}

class CoNiePasujeApp extends StatelessWidget {
  const CoNiePasujeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Co nie pasuje?',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Co nie pasuje?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Witaj w grze "Co nie pasuje?"',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GamePage()),
                );
              },
              child: Text('Rozpocznij grę'),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _random = Random();
  late List<String> options;
  late int correctIndex;

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    List<String> possibleOptions = ['Jabłko', 'Banan', 'Gruszka', 'Samochód'];
    correctIndex = _random.nextInt(4); // Wybieramy poprawną odpowiedź
    options = List.of(possibleOptions);
    options.shuffle();
    correctIndex = options.indexOf('Samochód');
  }

  void _checkAnswer(int index) {
    bool isCorrect = index == correctIndex;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Dobrze! 🎉' : 'Źle! Spróbuj ponownie.'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
    if (isCorrect) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _generateNewQuestion();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Co nie pasuje?'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Wybierz opcję, która nie pasuje:',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ...List.generate(4, (index) => OptionButton(
                  optionText: options[index],
                  onPressed: () => _checkAnswer(index),
                )),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String optionText;
  final VoidCallback onPressed;

  const OptionButton({super.key, required this.optionText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(optionText),
      ),
    );
  }
}
