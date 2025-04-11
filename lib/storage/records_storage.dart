import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

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
        // Struktura domyślna, gdy plik nie istnieje
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
