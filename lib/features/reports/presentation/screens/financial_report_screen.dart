import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/network/api_exception.dart';
import 'package:simpliadz_mobile/core/widgets/report_scaffold.dart';
import 'package:simpliadz_mobile/features/reports/data/data_sources/financial_report_api.dart';
import 'package:simpliadz_mobile/features/reports/domain/entities/financial_report.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({
    required this.api,
    this.canListShops = false,
    super.key,
  });

  final FinancialReportApi api;
  final bool canListShops;

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  DateTimeRange _range = currentMonthToDate();
  String? _location;
  final _locations = <String, String>{};
  late Future<FinancialReport> _report;

  @override
  void initState() {
    super.initState();
    _report = _fetch();
    if (widget.canListShops) _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      final shops = await widget.api.shops();
      if (mounted) setState(() => _locations.addAll(shops));
    } catch (_) {
      // The report can still supply locations with recorded sales.
    }
  }

  Future<FinancialReport> _fetch() {
    final location = _location;
    final range = _range;
    return widget.api
        .load(
          fromDate: reportDate(range.start),
          toDate: reportDate(range.end),
          locationId: location,
        )
        .then((report) {
          if (mounted &&
              location == null &&
              _location == null &&
              range == _range) {
            setState(
              () => _locations.addEntries(
                report.locations.map((shop) => MapEntry(shop.id, shop.name)),
              ),
            );
          }
          return report;
        });
  }

  Future<void> _refresh() async {
    setState(() {
      _report = _fetch();
      if (widget.canListShops) _loadShops();
    });
    try {
      await _report;
    } catch (_) {
      // The future builder displays the failure.
    }
  }

  @override
  Widget build(BuildContext context) => ReportScaffold(
    title: 'Financial dashboard',
    onRefresh: _refresh,
    children: [
      ReportDateFilter(
        range: _range,
        onChanged: (range) {
          _range = range;
          _refresh();
        },
      ),
      DropdownButtonFormField<String>(
        initialValue: _location ?? '',
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Shop'),
        items: [
          const DropdownMenuItem(value: '', child: Text('All shops')),
          for (final shop in _locations.entries)
            DropdownMenuItem(value: shop.key, child: Text(shop.value)),
        ],
        onChanged: (value) {
          _location = value == '' ? null : value;
          _refresh();
        },
      ),
      FutureBuilder<FinancialReport>(
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
                      : 'Could not load the financial report.',
                ),
                TextButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            );
          }
          return _FinancialReportView(
            report: snapshot.requireData,
            allShops: _location == null,
          );
        },
      ),
    ],
  );
}

class _FinancialReportView extends StatelessWidget {
  const _FinancialReportView({required this.report, required this.allShops});

  final FinancialReport report;
  final bool allShops;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    String amount(num n) => n.toStringAsFixed(2);
    final recentTrend = report.trend.reversed.take(7);
    final peak = report.trend.fold<num>(
      0,
      (max, point) => math.max(max, point.sales.abs()),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _Section(
          title: 'Performance',
          rows: [
            for (final entry in report.metrics.entries)
              _ReportRow(label: entry.key, value: amount(entry.value)),
            _ReportRow(
              label: 'Gross margin',
              value: '${report.margin.toStringAsFixed(1)}%',
            ),
            _ReportRow(
              label: 'Transactions',
              value: localizations.formatDecimal(report.transactions),
            ),
            _ReportRow(
              label: 'Items sold',
              value: localizations.formatDecimal(report.itemsSold),
            ),
          ],
        ),
        _Section(
          title: 'Daily net sales · latest 7 days with activity',
          rows: [
            for (final point in recentTrend)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    _ReportRow(
                      label: localizations.formatShortDate(point.date),
                      value: amount(point.sales),
                    ),
                    LinearProgressIndicator(
                      value: peak == 0 ? 0 : (point.sales.abs() / peak),
                      color: point.sales < 0
                          ? Theme.of(context).colorScheme.error
                          : null,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
          ],
        ),
        _Section(
          title: 'Payment methods',
          rows: [
            for (final item in report.payments)
              _ReportRow(
                label: item.name,
                value:
                    '${amount(item.amount)} · ${item.share.toStringAsFixed(1)}%',
              ),
          ],
        ),
        if (allShops)
          _Section(
            title: 'Net sales by shop',
            rows: [
              for (final shop in report.locations)
                _ReportRow(label: shop.name, value: amount(shop.sales)),
            ],
          ),
        _Section(
          title: 'Top products',
          rows: [
            for (final product in report.products)
              _ReportRow(
                label: product.name,
                value: '${amount(product.sales)} · ${product.quantity} units',
              ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (rows.isEmpty) const Text('No data in this period.'),
          ...rows,
        ],
      ),
    ),
  );
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
