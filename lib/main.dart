import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:math';

void main() {
  runApp(CoNiePasujeApp());

  doWhenWindowReady(() { // zmiana rozmiaru okna
    final initialSize = Size(600, 800);
    appWindow.minSize = Size(600, 800);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  }
  );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Co nie pasuje?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color.fromARGB(255, 128, 185, 233), const Color.fromARGB(255, 154, 66, 170)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
      ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Witaj w grze "Co nie pasuje?"',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Przyciski wyboru trybu gry
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GamePage()),
                  );
                },
                
                child: Text('Tryb Klasyczny'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimeSelectionScreen()),
                  );
                },
                child: Text('Tryb Czasowy'),
              ),
            ],
          ),
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
  bool showFeedback = false;
  String feedbackMessage = '';
  Color feedbackColor = Colors.green;
  IconData feedbackIcon = Icons.check; // Ikona domyślna dla poprawnej odpowiedzi

  final Random _random = Random();

  // Mapowanie kategorii z 10 elementami każda
  final Map<String, List<String>> categories = {
    'Fruits': [
      'Jabłko',
      'Banan',
      'Gruszka',
      'Pomarańcza',
      'Winogrono',
      'Truskawka',
      'Kiwi',
      'Mango',
      'Ananas',
      'Cytryna'
    ],
    'Vehicles': [
      'Samochód',
      'Rower',
      'Motocykl',
      'Autobus',
      'Pociąg',
      'Samolot',
      'Statek',
      'Helikopter',
      'Skuter',
      'Ciężarówka'
    ],
    'Animals': [
      'Kot',
      'Pies',
      'Królik',
      'Koń',
      'Lew',
      'Tygrys',
      'Słoń',
      'Żyrafa',
      'Małpa',
      'Niedźwiedź'
    ],
    'Colors': [
      'Czerwony',
      'Niebieski',
      'Zielony',
      'Żółty',
      'Fioletowy',
      'Pomarańczowy',
      'Różowy',
      'Brązowy',
      'Czarny',
      'Biały'
    ],
    'Cartoon and Movie Characters': [
      'Myszka Miki',
      'Kubuś Puchatek',
      'Spider-Man',
      'Elsa',
      'Shrek',
      'Minionek',
      'Scooby-Doo',
      'Batman',
      'Świnka Peppa',
    ],
  };

  // Mapowanie nazw opcji na ścieżki do obrazków
  final Map<String, String> optionImages = {
    // Fruits
    'Jabłko': 'assets/images/jablko.png',
    'Banan': 'assets/images/banan.png',
    'Gruszka': 'assets/images/gruszka.png',
    'Pomarańcza': 'assets/images/pomarancza.png',
    'Winogrono': 'assets/images/winogrono.png',
    'Truskawka': 'assets/images/truskawka.png',
    'Kiwi': 'assets/images/kiwi.png',
    'Mango': 'assets/images/mango.png',
    'Ananas': 'assets/images/ananas.png',
    'Cytryna': 'assets/images/cytryna.png',
    // Vehicles
    'Samochód': 'assets/images/samochod.png',
    'Rower': 'assets/images/rower.png',
    'Motocykl': 'assets/images/motocykl.png',
    'Autobus': 'assets/images/autobus.png',
    'Pociąg': 'assets/images/pociag.png',
    'Samolot': 'assets/images/samolot.png',
    'Statek': 'assets/images/statek.png',
    'Helikopter': 'assets/images/helikopter.png',
    'Skuter': 'assets/images/skuter.png',
    'Ciężarówka': 'assets/images/ciezarowka.png',
    // Animals
    'Kot': 'assets/images/kot.png',
    'Pies': 'assets/images/pies.png',
    'Królik': 'assets/images/krolik.png',
    'Koń': 'assets/images/kon.png',
    'Lew': 'assets/images/lew.png',
    'Tygrys': 'assets/images/tygrys.png',
    'Słoń': 'assets/images/slon.png',
    'Żyrafa': 'assets/images/zyrafa.png',
    'Małpa': 'assets/images/malpa.png',
    'Niedźwiedź': 'assets/images/niedzwiedz.png',
    // Colors
    'Czerwony': 'assets/images/czerwony.png',
    'Niebieski': 'assets/images/niebieski.png',
    'Zielony': 'assets/images/zielony.png',
    'Żółty': 'assets/images/zolty.png',
    'Fioletowy': 'assets/images/fioletowy.png',
    'Pomarańczowy': 'assets/images/pomaranczowy.png',
    'Różowy': 'assets/images/rozowy.png',
    'Brązowy': 'assets/images/brazowy.png',
    'Czarny': 'assets/images/czarny.png',
    'Biały': 'assets/images/bialy.png',
    // Cartoon and Movie Characters
    'Myszka Miki': 'assets/images/miki.png',
    'Kubuś Puchatek': 'assets/images/kubus.png',
    'Spider-Man': 'assets/images/spiderman.png',
    'Elsa': 'assets/images/elsa.png',
    'Shrek': 'assets/images/shrek.png',
    'Minionek': 'assets/images/minionek.png',
    'Scooby-Doo': 'assets/images/scooby.png',
    'Batman': 'assets/images/batman.png',
    'Świnka Peppa': 'assets/images/peppa.png',
  };

  late List<String> options;
  late int correctIndex;

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    // Losowanie kategorii pasujących
    List<String> categoryKeys = categories.keys.toList();
    String matchingCategory =
        categoryKeys[_random.nextInt(categoryKeys.length)];

    // Losowanie kategorii niepasującej (upewnij się, że jest inna)
    String nonMatchingCategory;
    do {
      nonMatchingCategory =
          categoryKeys[_random.nextInt(categoryKeys.length)];
    } while (nonMatchingCategory == matchingCategory);

    // Z kategorii pasujących losujemy 2 unikalne elementy
    List<String> matchingItems = List.from(categories[matchingCategory]!);
    matchingItems.shuffle();
    List<String> selectedMatching = matchingItems.take(2).toList();

    // Z kategorii niepasującej losujemy 1 element
    List<String> nonMatchingItems = List.from(categories[nonMatchingCategory]!);
    nonMatchingItems.shuffle();
    String selectedNonMatching = nonMatchingItems.first;

    // Łączymy odpowiedzi
    options = List.from(selectedMatching);
    options.add(selectedNonMatching);
    options.shuffle();

    // Znajdujemy indeks elementu, który nie pasuje (pochodzi z nonMatchingCategory)
    correctIndex = options.indexOf(selectedNonMatching);
  }

  void _checkAnswer(int index) {
    bool isCorrect = index == correctIndex;
    setState(() {
      showFeedback = true;
      if (isCorrect) {
        feedbackMessage = 'Dobrze! 🎉';
        feedbackColor = Colors.green;
        feedbackIcon = Icons.check;
      } else {
        feedbackMessage = 'Źle! Spróbuj ponownie.';
        feedbackColor = Colors.red;
        feedbackIcon = Icons.close;
      }
    });
    // Ukryj komunikat po 1,5 sekundach
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        showFeedback = false;
      });
      if (isCorrect) {
        _generateNewQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Co nie pasuje?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Co nie pasuje?',
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Wrap(
                    key: ValueKey<int>(options.hashCode),
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 10,
                    children: List.generate(
                      options.length,
                      (index) {
                        String imagePath = optionImages[options[index]] ??
                            'assets/images/placeholder.png';
                        return OptionButton(
                          optionText: options[index],
                          imageAsset: imagePath,
                          onPressed: () => _checkAnswer(index),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Komunikat informujący o wyniku
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: showFeedback ? 1 : 0,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: feedbackColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        feedbackIcon,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        feedbackMessage,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionButton extends StatefulWidget {
  final String optionText;
  final String imageAsset;
  final VoidCallback onPressed;

  const OptionButton({
    super.key,
    required this.optionText,
    required this.imageAsset,
    required this.onPressed,
  });

  @override
  _OptionButtonState createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Transform.scale(
          scale: _scale,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 120, maxWidth: 160),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(widget.imageAsset, height: 80, fit: BoxFit.contain),
                  SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      widget.optionText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Ekran wyboru czasu w trybie czasowym
class TimeSelectionScreen extends StatefulWidget {
  const TimeSelectionScreen({super.key});

  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  double _selectedTime = 5; // Domyślnie 5 minut

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wybierz czas gry")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Ilość minut: ${_selectedTime.toInt()}",
            style: TextStyle(fontSize: 20),
          ),
          Slider(
            value: _selectedTime,
            min: 1,
            max: 30,
            divisions: 29, // 1-minutowe skoki
            label: "${_selectedTime.toInt()} min",
            onChanged: (double value) {
              setState(() {
                _selectedTime = value;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TimedGameScreen(timeLimit: _selectedTime.toInt()),
                ),
              );
            },
            child: Text("Start"),
          ),
        ],
      ),
    );
  }
}

// Ekran gry w trybie czasowym – tutaj możesz rozbudować logikę o licznik i punktację
class TimedGameScreen extends StatelessWidget {
  final int timeLimit;

  const TimedGameScreen({super.key, required this.timeLimit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tryb Czasowy")),
      body: Center(
        child: Text(
          "Masz $timeLimit minut na grę!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
