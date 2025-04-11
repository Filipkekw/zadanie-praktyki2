import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/transitions.dart';
import '../widgets/option_button.dart';
import '../widgets/records_section.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import '../models/records_repository.dart';

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

  Timer? _survivalTimer;
  AnimationController? _survivalProgressController;
  late Animation<double> _survivalProgressAnimation;

  // Mapowanie punktów na limit czasu dla trybu survival
  final Map<int, int> survivalThresholds = {
    25: 20,
    50: 15,
    75: 10,
    100: 5,
  };

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
  AnimationController? _progressController;
  late Animation<double> _progressAnimation;

  // Kategorie oraz obrazy do opcji
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

    int currentTimeLimit = getCurrentSurvivalTimeLimit();
    if (widget.isSurvival && currentTimeLimit > 0) {
      _startSurvivalTimer(currentTimeLimit);
    }
  }

  void _startSurvivalTimer(int timeLimit) {
    _cancelSurvivalTimer();

    _survivalProgressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: timeLimit),
    );

    _survivalProgressAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(_survivalProgressController!)
      ..addListener(() {
        setState(() {});
      });

    _survivalProgressController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cancelSurvivalTimer();
        _endGame(reason: 'time');
      }
    });

    _survivalProgressController!.forward();
  }

  void _cancelSurvivalTimer() {
    if (_survivalProgressController != null) {
      _survivalProgressController!.stop();
      _survivalProgressController!.dispose();
      _survivalProgressController = null;
    }
    _survivalTimer?.cancel();
    _survivalTimer = null;
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
        } else if (widget.timeLimit != null) {
          _endGameWrongAnswer();
        } else {
          _generateNewQuestion();
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
        title: const Text('Przegrałeś!'),
        content: Text('Odpowiedź jest błędna.\nTwój wynik: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Powrót do menu'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                createRoute(timeLimit: widget.timeLimit, isSurvival: false),
              );
            },
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

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
        title: const Text('Koniec gry!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
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

      _progressAnimation =
          Tween<double>(begin: 1.0, end: 0.0).animate(_progressController!)
            ..addListener(() {
              setState(() {
                _timeLeft = (widget.timeLimit! * _progressAnimation.value).ceil();
              });
            });

      _progressController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onTimeUp();
        }
      });
    }

    if (!widget.isSurvival) {
      _lives = -1;
    }

    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -10)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10, end: 10)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 10, end: 0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_shakeController);
  }

  void _onTimeUp() {
    _saveRecord();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Koniec czasu!'),
        content: Text('Twój wynik: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancelSurvivalTimer();
    _feedbackAnimationController.dispose();
    _shakeController.dispose();
    _progressController?.dispose();
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
                String imagePath = optionImages[options[index]] ??
                    'assets/images/placeholder.png';
                return OptionButton(
                  optionText: options[index],
                  imageAsset: imagePath,
                  onPressed: () => _checkAnswer(index),
                );
              },
            ),
          )
        : AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
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
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Co nie pasuje?'),
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
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Co nie pasuje?',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (widget.isSurvival && _survivalProgressController != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Pozostały czas: ${(_survivalProgressAnimation.value * getCurrentSurvivalTimeLimit()).ceil()} s',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                      child: Builder(builder: (context) {
                        int currentTimeLimit = getCurrentSurvivalTimeLimit();
                        int remainingSeconds =
                            (_survivalProgressAnimation.value * currentTimeLimit).ceil();
                        Color progressColor;
                        if (remainingSeconds <= 5) {
                          progressColor = Colors.red;
                        } else if (remainingSeconds <= 10) {
                          progressColor = Colors.yellow;
                        } else {
                          progressColor = Colors.greenAccent;
                        }
                        return LinearProgressIndicator(
                          value: _survivalProgressAnimation.value,
                          backgroundColor: Colors.white38,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        );
                      }),
                    ),
                  ] else if (widget.timeLimit != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Pozostały czas: $_timeLeft s',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.white38,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Punkty: $_score',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: ScaleTransition(
                    scale: _feedbackScaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: feedbackColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(feedbackIcon, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            feedbackMessage,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
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
