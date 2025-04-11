import 'package:flutter/material.dart';
import '../widgets/dynamic_time_records_section.dart';
import '../widgets/records_section.dart';
import '../models/records_repository.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dwie zakładki: Czasówka i Tryb Przetrwania
      child: Scaffold(
        backgroundColor: const Color(0xFFBBDEFB),
        appBar: AppBar(
          title: const Text('Rekordy🏆'),
          backgroundColor: const Color(0xFFBBDEFB),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Czasówka'),
              Tab(text: 'Tryb Przetrwania'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Dynamiczna zakładka pokazująca rekordy dla trybu czasowego
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
