import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/features/inventory/data/data_sources/inventory_api_data_source.dart';
import 'package:simpliadz_mobile/features/inventory/domain/entities/inventory_report.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({required this.api, required this.row, super.key});
  final InventoryApiDataSource api;
  final InventoryRow row;
  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late Future<(int, List<Map<String, dynamic>>)> _data = _load();
  Future<(int, List<Map<String, dynamic>>)> _load() async => (
    await widget.api.total(widget.row.id),
    await widget.api.balances(widget.row.id),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.row.productName)),
    body: FutureBuilder<(int, List<Map<String, dynamic>>)>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => setState(() => _data = _load()),
              child: const Text('Retry'),
            ),
          );
        }
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.row.sku,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Current total balance: ${data.$1}'),
            const SizedBox(height: 12),
            const Text(
              'Current balance by location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...data.$2.map(
              (x) => ListTile(
                title: Text(x['locationId'] as String),
                trailing: Text('${x['quantityOnHand']}'),
                subtitle: Text('Updated ${x['updatedAt']}'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'These are current balances. Movement history will be added in the next read-only stock-detail milestone.',
              ),
            ),
          ],
        );
      },
    ),
  );
}
