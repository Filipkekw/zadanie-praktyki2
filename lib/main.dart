import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'models/records_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RecordsRepository.loadRecords();
  runApp(const CoNiePasujeApp());

  doWhenWindowReady(() {
    final initialSize = const Size(600, 800);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Co nie pasuje?';
    appWindow.show();
  });
}
