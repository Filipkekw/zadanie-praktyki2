import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

// Klasa przechowująca rekordy
class RecordsRepository {
  static List<int> survivalRecords = [];
  static Map<int, List<int>> timedRecords = {
    30: [],
    60: [],
    90: [],
  };

  static final RecordsStorage _storage = RecordsStorage();

  // Wczytujemy rekordy przy uruchomieniu aplikacji
  static Future<void> loadRecords() async {
    Map<String, dynamic> data = await _storage.readRecords();
    survivalRecords = List<int>.from(data['survivalRecords'] ?? []);
    Map<String, dynamic> timedData = data['timedRecords'] ?? {};
    timedRecords[30] = List<int>.from(timedData['30'] ?? []);
    timedRecords[60] = List<int>.from(timedData['60'] ?? []);
    timedRecords[90] = List<int>.from(timedData['90'] ?? []);
  }

  static Future<void> _saveToStorage() async {
    Map<String, dynamic> data = {
      'survivalRecords': survivalRecords,
      'timedRecords': {
        '30': timedRecords[30],
        '60': timedRecords[60],
        '90': timedRecords[90],
      },
    };
    await _storage.writeRecords(data);
  }

  static Future<void> addSurvivalRecord(int score) async {
    survivalRecords.add(score);
    survivalRecords.sort((a, b) => b.compareTo(a));
    await _saveToStorage();
  }

  static Future<void> addTimedRecord(int timeLimit, int score) async {
    if (timedRecords.containsKey(timeLimit)) {
      timedRecords[timeLimit]!.add(score);
      timedRecords[timeLimit]!.sort((a, b) => b.compareTo(a));
      await _saveToStorage();
    }
  }
}


class RecordsStorage {
  static const String _fileName = "records.json";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<Map<String, dynamic>> readRecords() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String contents = await file.readAsString();
        return json.decode(contents);
      } else {
        // Jeśli plik nie istnieje, zwracamy strukturę domyślną
        return {
          'survivalRecords': [],
          'timedRecords': {
            '30': [],
            '60': [],
            '90': [],
          }
        };
      }
    } catch (e) {
      return {
        'survivalRecords': [],
        'timedRecords': {
          '30': [],
          '60': [],
          '90': [],
        }
      };
    }
  }

  Future<File> writeRecords(Map<String, dynamic> records) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(records));
  }
}

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await RecordsRepository.loadRecords();
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
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade500],
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
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(_createRoute(isSurvival: false));
                },
                child: Text('Tryb Nieskończony'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    _createTimeSelectionRoute(),
                  );
                },
                child: Text('Tryb Czasowy'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(_createRoute(isSurvival: true));
                },
                child: Text('Tryb Przetrwania'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecordsPage()),
                  );
                },
                child: Text('Rekordy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route _createRoute({int? timeLimit, required bool isSurvival}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => GamePage(timeLimit: timeLimit, isSurvival: isSurvival),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
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

Route _createTimeSelectionRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        TimeSelectionScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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


class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Główne zakładki: Tryb Czasowy i Tryb Survival
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rekordy'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Tryb Czasowy'),
              Tab(text: 'Tryb Survival'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Zakładka dla trybu czasowego z podziałem na 30, 60 i 90 sekund
            TimeRecordsSection(),
            // Zakładka z rekordami dla trybu survival
            RecordsSection(
              title: 'Rekordy trybu survival',
              records: RecordsRepository.survivalRecords,
              emptyMessage: 'Brak rekordów dla trybu survival.',
            ),
          ],
        ),
      ),
    );
  }
}

class TimeRecordsSection extends StatelessWidget {
  const TimeRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Podzakładki dla 30, 60 i 90 sekund
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: '30 s'),
              Tab(text: '60 s'),
              Tab(text: '90 s'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                RecordsSection(
                  title: 'Rekordy 30 s',
                  records: RecordsRepository.timedRecords[30] ?? [],
                  emptyMessage: 'Brak rekordów dla trybu 30 sekund.',
                ),
                RecordsSection(
                  title: 'Rekordy 60 s',
                  records: RecordsRepository.timedRecords[60] ?? [],
                  emptyMessage: 'Brak rekordów dla trybu 60 sekund.',
                ),
                RecordsSection(
                  title: 'Rekordy 90 s',
                  records: RecordsRepository.timedRecords[90] ?? [],
                  emptyMessage: 'Brak rekordów dla trybu 90 sekund.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget do wyświetlania listy rekordów z opcjonalnym nagłówkiem
class RecordsSection extends StatelessWidget {
  final String title;
  final List<int> records;
  final String emptyMessage;

  const RecordsSection({
    super.key,
    required this.title,
    required this.records,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        records.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    emptyMessage,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            : Column(
                children: records
                    .map(
                      (score) => Card(
                        child: ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Wynik: $score'),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}

class GamePage extends StatefulWidget {
  final int? timeLimit; // Opcjonalny limit czasu
  final bool isSurvival;

  const GamePage({Key? key, this.timeLimit, required this.isSurvival}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool showFeedback = false;
  String feedbackMessage = '';
  Color feedbackColor = Colors.green;
  IconData feedbackIcon = Icons.check;
  int? _timeLeft;
  Timer? _timer;
  int _score = 0;
  int _lives = 3;

  final Random _random = Random();

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

  final Map<String, String> optionImages = {
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

  void _generateNewQuestion() {
    List<String> categoryKeys = categories.keys.toList();
    String matchingCategory =
        categoryKeys[_random.nextInt(categoryKeys.length)];
    String nonMatchingCategory;
    do {
      nonMatchingCategory =
          categoryKeys[_random.nextInt(categoryKeys.length)];
    } while (nonMatchingCategory == matchingCategory);
    List<String> matchingItems = List.from(categories[matchingCategory]!);
    matchingItems.shuffle();
    List<String> selectedMatching = matchingItems.take(2).toList();
    List<String> nonMatchingItems = List.from(categories[nonMatchingCategory]!);
    nonMatchingItems.shuffle();
    String selectedNonMatching = nonMatchingItems.first;
    options = List.from(selectedMatching);
    options.add(selectedNonMatching);
    options.shuffle();
    correctIndex = options.indexOf(selectedNonMatching);
  }

  // Metoda zapisująca rekord w zależności od trybu
  void _saveRecord() {
    if (widget.isSurvival) {
      RecordsRepository.addSurvivalRecord(_score);
    } else if (widget.timeLimit != null) {
      RecordsRepository.addTimedRecord(widget.timeLimit!, _score);
    }
  }

  void _checkAnswer(int index) {
    bool isCorrect = index == correctIndex;
    setState(() {
      showFeedback = true;
      if (isCorrect) {
        feedbackMessage = 'Dobrze! 🎉';
        feedbackColor = Colors.green;
        feedbackIcon = Icons.check;
        _score++;
      } else {
        feedbackMessage = 'Źle! Spróbuj ponownie.';
        feedbackColor = Colors.red;
        feedbackIcon = Icons.close;
        if (widget.isSurvival || widget.timeLimit != null) {
          _lives--;
        }
      }
    });
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        showFeedback = false;
      });
      if (widget.isSurvival || widget.timeLimit != null) {
        if (_lives <= 0) {
          _endGame();
        } else {
          _generateNewQuestion();
        }
      } else {
        if (isCorrect) {
          _generateNewQuestion();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
    if (widget.timeLimit != null) {
      _timeLeft = widget.timeLimit;
      _startTimer();
    }
    if (!widget.isSurvival) {
      _lives = -1;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft! > 0) {
        setState(() {
          _timeLeft = _timeLeft! - 1;
        });
      } else {
        _timer?.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    _saveRecord();
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

  void _endGame() {
    _saveRecord();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Koniec gry!'),
        content: Text('Twój wynik: $_score punktów\n${widget.isSurvival ? 'Nie masz już więcej żyć!' : 'Czas minął!'}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
            colors: [Colors.blue.shade300, Colors.purple.shade500],
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
                  if (widget.isSurvival || widget.timeLimit != null)
                    Text(
                      'Życia: $_lives ❤️',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 20),
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
                    transitionBuilder: (Widget child, Animation<double> animation) {
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
                        Icon(feedbackIcon, color: Colors.white),
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
      ),
    );
  }
}

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
  int? _selectedTime;
  int _countdown = 3;
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
      _createRoute(timeLimit: _selectedTime, isSurvival: true),
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
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        _countdown > 0 ? '$_countdown' : 'Start!',
                        key: ValueKey<int>(_countdown),
                        style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
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
