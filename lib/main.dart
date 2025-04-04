import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(CoNiePasujeApp());

  doWhenWindowReady(() {
    final initialSize = Size(600, 800);
    appWindow.minSize = Size(600, 800);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
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
          gradient: LinearGradient(colors: [Color.fromARGB(255, 128, 185, 233), Color.fromARGB(255, 154, 66, 170)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                  Navigator.of(context).push(_createRoute());
                },
                child: Text('Tryb Nieskończony'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TimeSelectionScreen()),
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

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GamePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0); // Start na dole ekranu
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}

class GamePage extends StatefulWidget {
  final int? timeLimit; // Opcjonalny limit czasu

  const GamePage({Key? key, this.timeLimit}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool showFeedback = false;
  String feedbackMessage = '';
  Color feedbackColor = Colors.green;
  IconData feedbackIcon = Icons.check; // Ikona domyślna dla poprawnej odpowiedzi
  int? _timeLeft;
  Timer? _timer;
  int _score = 0; // Zmienna do liczenia punktów

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

  // Generowanie nowego pytania
  void _generateNewQuestion() {
    List<String> categoryKeys = categories.keys.toList();
    String matchingCategory =
        categoryKeys[_random.nextInt(categoryKeys.length)];

    // Losowanie kategorii niepasującej
    String nonMatchingCategory;
    do {
      nonMatchingCategory =
          categoryKeys[_random.nextInt(categoryKeys.length)];
    } while (nonMatchingCategory == matchingCategory);

    // Losowanie 2 unikalnych elementów z kategorii pasujących
    List<String> matchingItems = List.from(categories[matchingCategory]!);
    matchingItems.shuffle();
    List<String> selectedMatching = matchingItems.take(2).toList();

    // Losowanie 1 elementu z kategorii niepasującej
    List<String> nonMatchingItems = List.from(categories[nonMatchingCategory]!);
    nonMatchingItems.shuffle();
    String selectedNonMatching = nonMatchingItems.first;

    // Łączenie opcji i tasowanie
    options = List.from(selectedMatching);
    options.add(selectedNonMatching);
    options.shuffle();

    // Znajdowanie indeksu niepasującej opcji
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
        _score++; // ZWIĘKSZENIE LICZNIKA PUNKTÓW
      } else {
        feedbackMessage = 'Źle! Spróbuj ponownie.';
        feedbackColor = Colors.red;
        feedbackIcon = Icons.close;
      }
    });

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
  void initState() {
    super.initState();
    _generateNewQuestion(); // Generujemy pierwsze pytanie
    if (widget.timeLimit != null) {
      _timeLeft = widget.timeLimit;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft! > 0) {
        setState(() {
          _timeLeft = _timeLeft! - 1;
        });
      } else {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Koniec czasu!'),
        content: Text('Twój wynik: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Zamknięcie dialogu
              Navigator.of(context).pop(); // Powrót do ekranu wyboru trybu
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade200, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Co nie pasuje?',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (widget.timeLimit != null)
                    Text(
                      'Pozostały czas: $_timeLeft s',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 10),
                    Text(
                      'Punkty: $_score',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    key: ValueKey<int>(options.hashCode),
                    child: Wrap(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          style:
                              TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Uproszczona wersja OptionButton – korzysta wyłącznie z ElevatedButton
class OptionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 120, maxWidth: 160),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imageAsset, height: 80, fit: BoxFit.contain),
              SizedBox(height: 10),
              Flexible(
                child: Text(
                  optionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeSelectionScreen extends StatefulWidget {
  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  int? _selectedTime; // Wybrany czas gry
  int _countdown = 3; // Odliczanie przed startem
  bool _isCountingDown = false;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _startGame();
      }
    });
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => GamePage(timeLimit: _selectedTime)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Tryb Czasowy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _isCountingDown
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _countdown > 0 ? '$_countdown' : 'Start!',
                      style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Wybierz czas gry:',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeButton(30),
                        _buildTimeButton(60),
                        _buildTimeButton(90),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(int time) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTime = time;
          });
          _startCountdown();
        },
        child: Text('$time s'),
      ),
    );
  }
}
