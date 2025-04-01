import 'package:flutter/material.dart';

void main() {
  runApp(CoNiePasujeApp());
}

class CoNiePasujeApp extends StatelessWidget {
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
  // Strona główna aplikacji
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Przejście do ekranu gry
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

class GamePage extends StatelessWidget {
  // Strona, na której będzie odbywać się rozgrywka
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Co nie pasuje?'),
      ),
      body: Center(
        child: Text(
          'Work in progress. ;)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
