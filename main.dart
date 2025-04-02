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
    // Shapes
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
            // Dla każdej opcji tworzymy przycisk z obrazkiem i tekstem.
            ...List.generate(
              options.length,
              (index) {
                // Pobieramy ścieżkę do obrazka – jeśli nie ma, używamy placeholdera
                String imagePath = optionImages[options[index]] ??
                    'assets/images/placeholder.png';
                return OptionButton(
                  optionText: options[index],
                  imageAsset: imagePath,
                  onPressed: () => _checkAnswer(index),
                );
              },
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

  const OptionButton({super.key, required this.optionText, required this.imageAsset, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
            // Wyświetlamy obrazek – ustawiamy rozmiar wg potrzeb
            Image.asset(imageAsset, height: 80, fit: BoxFit.contain),
            SizedBox(height: 8),
            Text(optionText, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
