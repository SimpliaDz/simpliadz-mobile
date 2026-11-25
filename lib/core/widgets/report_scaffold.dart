import 'package:flutter/material.dart';

class ReportScaffold extends StatelessWidget {
  const ReportScaffold({
    required this.title,
    required this.onRefresh,
    required this.children,
    super.key,
  });

  final String title;
  final Future<void> Function() onRefresh;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ReportDateFilter extends StatelessWidget {
  const ReportDateFilter({
    required this.range,
    required this.onChanged,
    super.key,
  });

  final DateTimeRange range;
  final ValueChanged<DateTimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = MaterialLocalizations.of(context);
    return OutlinedButton.icon(
      icon: const Icon(Icons.date_range_outlined),
      label: Text(
        '${l10n.formatCompactDate(range.start)} – ${l10n.formatCompactDate(range.end)}',
      ),
      onPressed: () async {
        final result = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDateRange: range,
        );
        if (result != null && context.mounted) onChanged(result);
      },
    );
  }
}

String reportDate(DateTime value) => value.toIso8601String().substring(0, 10);

DateTimeRange currentMonthToDate() {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month),
    end: DateUtils.dateOnly(now),
  );
}
