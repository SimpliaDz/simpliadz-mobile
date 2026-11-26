import 'package:flutter/material.dart';
import 'package:simplia_mobile/features/inventory/data/data_sources/inventory_api_data_source.dart';

class StockMovementsScreen extends StatefulWidget {
  const StockMovementsScreen({
    required this.api,
    required this.variantId,
    super.key,
  });
  final InventoryApiDataSource api;
  final String variantId;
  @override
  State<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends State<StockMovementsScreen> {
  int page = 1;
  late Future<List<Map<String, dynamic>>> data = widget.api.movements(
    widget.variantId,
    page,
  );
  void load(int next) => setState(() {
    page = next;
    data = widget.api.movements(widget.variantId, page);
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Stock movements')),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: data,
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => load(page),
              child: const Text('Retry'),
            ),
          );
        }
        final rows = s.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Historical movement events. These explain how stock changed; they are not the current balance.',
            ),
            const Divider(),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No movements found.'),
              ),
            ...rows.map(
              (x) => ListTile(
                leading: Icon(
                  (x['quantityDelta'] as int) >= 0
                      ? Icons.add_circle_outline
                      : Icons.remove_circle_outline,
                ),
                title: Text(
                  '${x['movementType']} • ${x['quantityDelta'] > 0 ? '+' : ''}${x['quantityDelta']}',
                ),
                subtitle: Text(
                  '${x['occurredAt']}\n${x['reason'] ?? x['reference'] ?? 'No note'}',
                ),
                isThreeLine: true,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: page > 1 ? () => load(page - 1) : null,
                  child: const Text('Previous'),
                ),
                Text('Page $page'),
                TextButton(
                  onPressed: rows.isNotEmpty ? () => load(page + 1) : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
