import 'package:flutter/material.dart';
import 'package:simplia_mobile/core/network/api_exception.dart';
import 'package:simplia_mobile/core/network/authenticated_api_client.dart';
import 'package:simplia_mobile/core/widgets/report_scaffold.dart';

class WorkHoursReportScreen extends StatefulWidget {
  const WorkHoursReportScreen({required this.client, super.key});

  final AuthenticatedApiClient client;

  @override
  State<WorkHoursReportScreen> createState() => _WorkHoursReportScreenState();
}

class _WorkHoursReportScreenState extends State<WorkHoursReportScreen> {
  DateTimeRange _range = currentMonthToDate();
  late Future<_WorkHours> _report = _load();

  Future<_WorkHours> _load() async {
    final from = reportDate(_range.start);
    final to = reportDate(_range.end);
    return _WorkHours.fromJson(
      await widget.client.get('/reports/work-hours?fromDate=$from&toDate=$to'),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _report = _load();
    });
    try {
      await _report;
    } catch (_) {
      // The future builder displays the failure.
    }
  }

  @override
  Widget build(BuildContext context) => ReportScaffold(
    title: 'Worked hours',
    onRefresh: _refresh,
    children: [
      ReportDateFilter(
        range: _range,
        onChanged: (range) {
          _range = range;
          _refresh();
        },
      ),
      FutureBuilder<_WorkHours>(
        future: _report,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return Column(
              children: [
                Text(
                  error is ApiException
                      ? error.message
                      : 'Could not load worked hours.',
                ),
                TextButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            );
          }
          final report = snapshot.requireData;
          final dates = report.byDate.keys.toList()
            ..sort((a, b) => b.compareTo(a));
          final l10n = MaterialLocalizations.of(context);
          return Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text('${report.total.toStringAsFixed(2)} hours'),
                  subtitle: Text('Total worked · ${report.timeZone}'),
                ),
                const Divider(height: 1),
                if (dates.isEmpty)
                  const ListTile(
                    title: Text('No work recorded in this period.'),
                  ),
                for (final date in dates)
                  ListTile(
                    title: Text(l10n.formatMediumDate(date)),
                    trailing: Text(
                      '${report.byDate[date]!.toStringAsFixed(2)} h',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ],
  );
}

class _WorkHours {
  _WorkHours.fromJson(Map<String, dynamic> json)
    : total = json['totalHours'] as num,
      timeZone = json['timeZoneId'] as String {
    for (final row in (json['days'] as List).cast<Map<String, dynamic>>()) {
      final date = DateTime.parse(row['date'] as String);
      byDate.update(
        date,
        (hours) => hours + (row['hours'] as num),
        ifAbsent: () => row['hours'] as num,
      );
    }
  }

  final num total;
  final String timeZone;
  final byDate = <DateTime, num>{};
}
