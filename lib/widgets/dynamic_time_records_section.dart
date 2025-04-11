import 'package:flutter/material.dart';
import '../models/records_repository.dart';
import 'records_section.dart';

class DynamicTimeRecordsSection extends StatelessWidget {
  const DynamicTimeRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<int> availableTimes = RecordsRepository.timedRecords.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();
    availableTimes.sort();

    if (availableTimes.isEmpty) {
      return const Center(
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
