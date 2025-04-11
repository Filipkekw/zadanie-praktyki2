import 'dart:convert';
import '../storage/records_storage.dart';

class RecordsRepository {
  static List<int> survivalRecords = [];
  // Mapa rekordów dla trybu czasowego
  static Map<int, List<int>> timedRecords = {};

  static final RecordsStorage _storage = RecordsStorage();

  // Wczytujemy rekordy przy uruchomieniu aplikacji
  static Future<void> loadRecords() async {
    Map<String, dynamic> data = await _storage.readRecords();
    survivalRecords = List<int>.from(data['survivalRecords'] ?? []);
    
    // Wczytujemy rekordy trybu czasowego (klucze jako stringi, konwertujemy na int)
    Map<String, dynamic> timedData = data['timedRecords'] ?? {};
    timedData.forEach((key, value) {
      timedRecords[int.parse(key)] = List<int>.from(value);
    });
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
    if (!timedRecords.containsKey(timeLimit)) {
      timedRecords[timeLimit] = [];
    }
    timedRecords[timeLimit]!.add(score);
    timedRecords[timeLimit]!.sort((a, b) => b.compareTo(a));
    await _saveToStorage();
  }
}
