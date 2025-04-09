// ignore_for_file: library_private_types_in_public_api

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
  // Zamiast domyślnych kluczy ustawiamy pustą mapę
  static Map<int, List<int>> timedRecords = {};

  static final RecordsStorage _storage = RecordsStorage();

  // Wczytujemy rekordy przy uruchomieniu aplikacji
  static Future<void> loadRecords() async {
    Map<String, dynamic> data = await _storage.readRecords();
    survivalRecords = List<int>.from(data['survivalRecords'] ?? []);
    
    // Wczytujemy dynamiczne rekordy trybu czasowego
    Map<String, dynamic> timedData = data['timedRecords'] ?? {};
    timedData.forEach((key, value) {timedRecords[int.parse(key)] = List<int>.from(value);});
  }

  static Future<void> _saveToStorage() async {
    Map<String, dynamic> data = {
      'survivalRecords': survivalRecords,
      'timedRecords': timedRecords.map((key, value) => MapEntry(key.toString(), value)),
    };
    await _storage.writeRecords(data);
  }

  static Future<void> addSurvivalRecord(int score) async {
    survivalRecords.add(score);
    survivalRecords.sort((a, b) => b.compareTo(a));
    await _saveToStorage();
  }

  static Future<void> addTimedRecord(int timeLimit, int score) async {
    // Jeżeli nie istnieje rekord dla danego formatu, tworzony jest nowy wpis
    if (!timedRecords.containsKey(timeLimit)) {timedRecords[timeLimit] = [];}
    timedRecords[timeLimit]!.add(score);
    timedRecords[timeLimit]!.sort((a, b) => b.compareTo(a));
    await _saveToStorage();
  }
}

class DynamicTimeRecordsSection extends StatelessWidget {
  const DynamicTimeRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Wybieramy tylko te formaty czasu, w których rozegrano grę (rekordy niepuste)
    List<int> availableTimes = RecordsRepository.timedRecords.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();
    availableTimes.sort();

    if (availableTimes.isEmpty) {
      return Center(
        child: Text(
          'Brak rekordów dla trybu czasowego.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return DefaultTabController(
      length: availableTimes.length,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: availableTimes
                .map((time) => Tab(text: '$time s'))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: availableTimes.map((time) {
                return RecordsSection(
                  title: 'Rekordy $time s',
                  records: RecordsRepository.timedRecords[time]!,
                  emptyMessage: 'Brak rekordów dla trybu $time sekund.',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
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
                child: Text('Czasówka'),
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
                child: Text('Rekordy🏆'),
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
      length: 2, // Główne zakładki: Czasówka i Tryb Przetrwania
      child: Scaffold(
        backgroundColor: Color(0xFFBBDEFB),
        appBar: AppBar(
          title: Text('Rekordy🏆'),
          backgroundColor: Color(0xFFBBDEFB),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Czasówka'),
              Tab(text: 'Tryb Przetrwania'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Zmieniamy na dynamiczną wersję, która pokaże tylko rozegrane tryby
            DynamicTimeRecordsSection(),
            // Zakładka z rekordami dla trybu survival
            RecordsSection(
              title: 'Rekordy trybu przetrwania',
              records: RecordsRepository.survivalRecords,
              emptyMessage: 'Brak rekordów dla trybu przetrwania.',
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

  const GamePage({super.key, this.timeLimit, required this.isSurvival});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  bool showFeedback = false;
  bool _questionAnswered = false;
  String feedbackMessage = '';
  Color feedbackColor = Colors.green;
  IconData feedbackIcon = Icons.check;
  int? _timeLeft;
  Timer? _timer;
  int _score = 0;
  int _lives = 3;

  // Zmienne dla dodatkowego timera w trybie przetrwania
  int _survivalTimeLeft = 0;
  Timer? _survivalTimer;

  // Mapowanie progu punktowego na limit czasu (w sekundach)
  final Map<int, int> survivalThresholds = {
    25: 20,  // przy 25 punktach -> 20 sekund
    50: 15,  // przy 50 punktach -> 15 sekund
    75: 10,  // przy 75 punktach -> 10 sekund
    100: 5,  // przy 100 punktach -> 5 sekund
  };

  // Metoda wybiera limit czasu na podstawie aktualnego wyniku.
  // Iterujemy po progach posortowanych rosnąco – gdy _score jest większy lub równy progowi,
  // przypisujemy nowy limit. Dzięki temu dla wyniku np. 60 otrzymamy limit 15 sekund.
  int getCurrentSurvivalTimeLimit() {
    int limit = 0;
    var keys = survivalThresholds.keys.toList()..sort();
    for (var threshold in keys) {
      if (_score >= threshold) {
        limit = survivalThresholds[threshold]!;
      } else {
        break;
      }
    }
    return limit;
  }

  final Random _random = Random();

  // Animacje
  late AnimationController _feedbackAnimationController;
  late Animation<double> _feedbackScaleAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final Map<String, List<String>> categories = {
    'Owoce': [
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
    'Pojazdy': [
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
    'Zwierzeta': [
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
    'Kolory': [
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
    'Postacie z kreskówek': [
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
    'Rzeczy w kuchni': [
      'Kubek',
      'Garnek',
      'Talerz',
      'Patelnia',
      'Czajnik',
      'Miska',
      'Dzbanek',
      'Widelec',
      'Łyżka',
    ],
    'Ubrania': [
      'Koszulka',
      'Spodnie',
      'Sukienka',
      'Buty',
      'Czapka',
      'Sweter',
      'Kurtka',
      'Spódnica',
      'Bluza',
      'Szalik',
    ],
    'Przedmioty szkolne': [
      'Plecak',
      'Zeszyt',
      'Długopis',
      'Ołówek',
      'Linijka',
      'Temperówka',
      'Gumka',
      'Teczka',
      'Książka',
      'Zakreślacz',
    ],
    'Warzywa': [
      'Marchewka',
      'Ogórek',
      'Pomidor',
      'Ziemniak',
      'Sałata',
      'Cebula',
      'Brokuł',
      'Kalafior',
      'Papryka',
      'Burak',
    ],
    'Budynki': [
      'Zamek',
      'Wieża Eiffla',
      'Piramida',
      'Most',
      'Latarnia morska',
      'Kościół',
      'Wieżowiec',
      'Stadion',
      'Młyn',
    ],
    'Napoje': [
      'Woda',
      'Sok',
      'Herbata',
      'Mleko',
      'Cola',
      'Kawa',
      'Fanta',
      'Lemoniada',
    ],
    'Kraje świata': [
      'Polska',
      'Stany Zjednoczone',
      'Turcja',
      'Australia',
      'Brazylia',
      'Hiszpania',
      'Francja',
      'Włochy',
      'Egipt',
      'Dania',
    ],
    'Instrumenty': [
      'Fortepian',
      'Gitara',
      'Skrzypce',
      'Trąbka',
      'Perkusja',
      'Saksofon',
      'Flet',
      'Wiolonczela',
      'Harfa',
      'Akordeon',
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
    'Zygzak Mcqueen': 'assets/images/zygzak.png',
    'Kubek': 'assets/images/kubek.png',
    'Garnek': 'assets/images/garnek.png',
    'Talerz': 'assets/images/talerz.png',
    'Patelnia': 'assets/images/patelnia.png',
    'Czajnik': 'assets/images/czajnik.png',
    'Miska': 'assets/images/miska.png',
    'Dzbanek': 'assets/images/dzbanek.png',
    'Widelec': 'assets/images/widelec.png',
    'Łyżka': 'assets/images/lyzka.png',
    'Plecak': 'assets/images/plecak.png',
    'Zeszyt': 'assets/images/zeszyt.png',
    'Długopis': 'assets/images/dlugopis.png',
    'Ołówek': 'assets/images/olowek.png',
    'Linijka': 'assets/images/linijka.png',
    'Temperówka': 'assets/images/temperowka.png',
    'Gumka': 'assets/images/gumka.png',
    'Teczka': 'assets/images/teczka.png',
    'Książka': 'assets/images/ksiazka.png',
    'Zakreślacz': 'assets/images/zakreslacz.png',
    'Koszulka': 'assets/images/koszulka.png',
    'Spodnie': 'assets/images/spodnie.png',
    'Sukienka': 'assets/images/sukienka.png',
    'Buty': 'assets/images/buty.png',
    'Czapka': 'assets/images/czapka.png',
    'Sweter': 'assets/images/sweter.png',
    'Kurtka': 'assets/images/kurtka.png',
    'Spódnica': 'assets/images/spodnica.png',
    'Bluza': 'assets/images/bluza.png',
    'Szalik': 'assets/images/szalik.png',
    'Marchewka': 'assets/images/marchewka.png',
    'Ogórek': 'assets/images/ogorek.png',
    'Pomidor': 'assets/images/pomidor.png',
    'Ziemniak': 'assets/images/ziemniak.png',
    'Sałata': 'assets/images/salata.png',
    'Cebula': 'assets/images/cebula.png',
    'Brokuł': 'assets/images/brokul.png',
    'Kalafior': 'assets/images/kalafior.png',
    'Papryka': 'assets/images/papryka.png',
    'Burak': 'assets/images/burak.png',
    'Zamek': 'assets/images/zamek.png',
    'Wieża Eiffla': 'assets/images/wieza.png',
    'Piramida': 'assets/images/piramida.png',
    'Most': 'assets/images/most.png',
    'Latarnia morska': 'assets/images/latarnia.png',
    'Kościół': 'assets/images/kosciol.png',
    'Wieżowiec': 'assets/images/wiezowiec.png',
    'Stadion': 'assets/images/stadion.png',
    'Młyn': 'assets/images/mlyn.png',
    'Woda': 'assets/images/woda.png',
    'Sok': 'assets/images/sok.png',
    'Herbata': 'assets/images/herbata.png',
    'Mleko': 'assets/images/mleko.png',
    'Cola': 'assets/images/cola.png',
    'Kawa': 'assets/images/kawa.png',
    'Fanta': 'assets/images/fanta.png',
    'Lemoniada': 'assets/images/lemoniada.png',
    'Polska': 'assets/images/polska.png',
    'Stany Zjednoczone': 'assets/images/usa.png',
    'Turcja': 'assets/images/turcja.png',
    'Australia': 'assets/images/australia.png',
    'Brazylia': 'assets/images/brazylia.png',
    'Hiszpania': 'assets/images/hiszpania.png',
    'Francja': 'assets/images/francja.png',
    'Włochy': 'assets/images/wlochy.png',
    'Egipt': 'assets/images/egipt.png',
    'Dania': 'assets/images/dania.png',
    'Fortepian': 'assets/images/fortepian.png',
    'Gitara': 'assets/images/gitara.png',
    'Skrzypce': 'assets/images/skrzypce.png',
    'Trąbka': 'assets/images/trabka.png',
    'Perkusja': 'assets/images/perkusja.png',
    'Saksofon': 'assets/images/saksofon.png',
    'Flet': 'assets/images/flet.png',
    'Wiolonczela': 'assets/images/wiolonczela.png',
    'Harfa': 'assets/images/harfa.png',
    'Akordeon': 'assets/images/akordeon.png',
  };

  late List<String> options;
  late int correctIndex;

  void _generateNewQuestion() {
    // Anulujemy ewentualny wcześniejszy timer przetrwania
    _cancelSurvivalTimer();

    List<String> categoryKeys = categories.keys.toList();
    String matchingCategory = categoryKeys[_random.nextInt(categoryKeys.length)];
    String nonMatchingCategory;
    do {
      nonMatchingCategory = categoryKeys[_random.nextInt(categoryKeys.length)];
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

    // Jeśli gramy w trybie przetrwania i przekroczono próg punktowy, uruchamiamy timer
    int currentTimeLimit = getCurrentSurvivalTimeLimit();
    if (widget.isSurvival && currentTimeLimit > 0) {
      _startSurvivalTimer(currentTimeLimit);
    }
  }

  void _startSurvivalTimer(int timeLimit) {
    _cancelSurvivalTimer();
    setState(() {
      _survivalTimeLeft = timeLimit;
    });
    _survivalTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_survivalTimeLeft > 0) {
        setState(() {
          _survivalTimeLeft--;
        });
      } else {
        _cancelSurvivalTimer();
        _endGame(reason: 'time');
      }
    });
  }

  void _cancelSurvivalTimer() {
    if (_survivalTimer != null) {
      _survivalTimer!.cancel();
      _survivalTimer = null;
    }
  }

  void _saveRecord() {
    if (widget.isSurvival) {
      RecordsRepository.addSurvivalRecord(_score);
    } else if (widget.timeLimit != null) {
      RecordsRepository.addTimedRecord(widget.timeLimit!, _score);
    }
  }

  void _checkAnswer(int index) {
    if (_questionAnswered) return;
    _questionAnswered = true;

    bool isCorrect = index == correctIndex;
    setState(() {
      showFeedback = true;
      if (isCorrect) {
        feedbackMessage = 'Dobrze! 🎉';
        feedbackColor = Colors.green;
        feedbackIcon = Icons.check;
        _score++;
        _feedbackAnimationController.forward(from: 0);
      } else {
        feedbackMessage = 'Źle! Spróbuj ponownie.';
        feedbackColor = Colors.red;
        feedbackIcon = Icons.close;
        if (widget.isSurvival) {
          _lives--;
        }
        _shakeController.forward(from: 0);
      }
    });

    int delay = widget.timeLimit != null ? 500 : 1500;
    Future.delayed(Duration(milliseconds: delay), () {
      setState(() {
        showFeedback = false;
        _questionAnswered = false;
      });
      if (!isCorrect) {
        if (widget.isSurvival) {
          if (_lives <= 0) {
            _endGame(reason: 'lives');
          } else {
            _generateNewQuestion();
          }
        } else {
          _endGameWrongAnswer();
        }
      } else {
        _generateNewQuestion();
      }
    });
  }

  void _endGameWrongAnswer() {
    _saveRecord();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Przegrałeś!'),
        content: Text('Odpowiedź jest błędna.\nTwój wynik: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Powrót do menu'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                _createRoute(timeLimit: widget.timeLimit, isSurvival: false),
              );
            },
            child: Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  // Dodajemy parametr reason, by rozróżnić komunikaty końcowe
  void _endGame({String reason = 'lives'}) {
    _saveRecord();
    _cancelSurvivalTimer();
    String message;
    if (reason == 'time') {
      message = 'Czas minął!\nTwój wynik: $_score punktów';
    } else {
      message = 'Nie masz już więcej żyć!\nTwój wynik: $_score punktów';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Koniec gry!'),
        content: Text(message),
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
void initState() {
  super.initState();
  _generateNewQuestion();

  if (widget.timeLimit != null) {
    _timeLeft = widget.timeLimit;

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timeLimit!),
    )..forward();

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_progressController)
      ..addListener(() {
        setState(() {
          _timeLeft = (widget.timeLimit! * _progressAnimation.value).ceil();
        });
      });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onTimeUp();
      }
    });
  }

  if (!widget.isSurvival) {
    _lives = -1;
  }

  // Animacje odpowiedzi
  _feedbackAnimationController = AnimationController(
    duration: Duration(milliseconds: 300),
    vsync: this,
  );
  _feedbackScaleAnimation = Tween<double>(begin: 1.0, end: 1.2)
      .chain(CurveTween(curve: Curves.easeOut))
      .animate(_feedbackAnimationController);
  _feedbackAnimationController.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      _feedbackAnimationController.reverse();
    }
  });

  _shakeController = AnimationController(
    duration: Duration(milliseconds: 500),
    vsync: this,
  );
  _shakeAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 0, end: -10).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: -10, end: 10).chain(CurveTween(curve: Curves.easeInOut)), weight: 2),
    TweenSequenceItem(tween: Tween<double>(begin: 10, end: 0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
  ]).animate(_shakeController);
}

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft! > 0) {
        setState(() {
          int newTimeLeft = _timeLeft! - 1;
          double newProgress = newTimeLeft / widget.timeLimit!;
          _progressAnimation = Tween<double>(
            begin: _progressAnimation.value,
            end: newProgress,
          ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));

          _progressController.forward(from: 0);

          setState(() {
            _timeLeft = newTimeLeft;
          });
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
  void dispose() {
    _timer?.cancel();
    _survivalTimer?.cancel();
    _feedbackAnimationController.dispose();
    _shakeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget optionsWidget = widget.timeLimit != null
        ? Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children: List.generate(
              options.length,
              (index) {
                String imagePath =
                    optionImages[options[index]] ?? 'assets/images/placeholder.png';
                return OptionButton(
                  optionText: options[index],
                  imageAsset: imagePath,
                  onPressed: () => _checkAnswer(index),
                );
              },
            ),
          )
        : AnimatedSwitcher(
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
                  String imagePath =
                      optionImages[options[index]] ?? 'assets/images/placeholder.png';
                  return OptionButton(
                    optionText: options[index],
                    imageAsset: imagePath,
                    onPressed: () => _checkAnswer(index),
                  );
                },
              ),
            ),
          );

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
                  if (widget.isSurvival) ...[
                    Text(
                      'Życia: $_lives ❤️',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    if (_survivalTimer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Pozostały czas: $_survivalTimeLeft s',
                          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                  SizedBox(height: 20),
                  Text(
                    'Co nie pasuje?',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (widget.timeLimit != null) ...[
                    Text(
                      'Pozostały czas: $_timeLeft s',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    // Dodany pasek postępu
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 10),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _progressAnimation.value,
                                backgroundColor: Colors.white38,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: 10),
                  Text(
                    'Punkty: $_score',
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: optionsWidget,
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
                  child: ScaleTransition(
                    scale: _feedbackScaleAnimation,
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
            minimumSize: Size(100, 100),
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
  const TimeSelectionScreen({super.key});

  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  int _currentTime = 30; // Domyślnie 30 sekund.
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
      _createRoute(timeLimit: _currentTime, isSurvival: false),
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
        title: Text('Czasówka'),
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
                    Text('Czas: $_currentTime s', style: TextStyle(fontSize: 24, color: Colors.white)),
                    SizedBox(height: 20),
                    Slider(
                      value: _currentTime.toDouble(),
                      min: 15,
                      max: 120,
                      divisions: 7, // Skoki co 15 sekund (15, 30, 45, ... 120)
                      label: '$_currentTime s',
                      onChanged: (double value) {
                        setState(() {
                          _currentTime = value.toInt();
                        });
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _startCountdown,
                      child: Text('Rozpocznij grę'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
