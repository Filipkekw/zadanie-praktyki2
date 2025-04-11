import 'package:flutter/material.dart';

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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        records.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    emptyMessage,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              )
            : Column(
                children: records
                    .map(
                      (score) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.star),
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
