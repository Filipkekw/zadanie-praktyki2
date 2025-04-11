import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/transitions.dart';

class TimeSelectionScreen extends StatefulWidget {
  const TimeSelectionScreen({super.key});

  @override
  _TimeSelectionScreenState createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  int _currentTime = 30;
  int _countdown = 3;
  bool _isCountingDown = false;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      createRoute(timeLimit: _currentTime, isSurvival: false),
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
        title: const Text('Czasówka'),
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
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        _countdown > 0 ? '$_countdown' : 'Start!',
                        key: ValueKey<int>(_countdown),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Wybierz czas gry:',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Czas: $_currentTime s',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: _currentTime.toDouble(),
                      min: 15,
                      max: 120,
                      divisions: 7,
                      label: '$_currentTime s',
                      onChanged: (double value) {
                        setState(() {
                          _currentTime = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _startCountdown,
                      child: const Text('Rozpocznij grę'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
