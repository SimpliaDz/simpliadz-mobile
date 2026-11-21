import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/formatters/money_formatter.dart';
import 'package:simpliadz_mobile/features/reports/domain/repositories/sales_reports_repository.dart';

class VariantPerformanceScreen extends StatefulWidget {
  const VariantPerformanceScreen({
    required this.repository,
    required this.productId,
    required this.productName,
    required this.from,
    required this.to,
    super.key,
  });
  final SalesReportsRepository repository;
  final String productId, productName;
  final DateTime from, to;
  @override
  State<VariantPerformanceScreen> createState() =>
      _VariantPerformanceScreenState();
}

class _VariantPerformanceScreenState extends State<VariantPerformanceScreen> {
  late Future<List<dynamic>> _load = widget.repository.variants(
    widget.productId,
    widget.from,
    widget.to,
    1,
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.productName)),
    body: FutureBuilder<List<dynamic>>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => setState(
                () => _load = widget.repository.variants(
                  widget.productId,
                  widget.from,
                  widget.to,
                  1,
                ),
              ),
              child: const Text('Retry'),
            ),
          );
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return const Center(child: Text('No variants found.'));
        }
        return ListView(
          children: [
            for (final row in rows)
              ListTile(
                title: Text(row.sku),
                subtitle: Text('Net quantity: ${row.netQuantity}'),
                trailing: Text(dzd(context, row.netRevenue)),
              ),
          ],
        );
      },
    ),
  );
}
