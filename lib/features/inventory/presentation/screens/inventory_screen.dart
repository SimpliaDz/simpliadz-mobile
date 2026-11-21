import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/formatters/money_formatter.dart';
import 'package:simpliadz_mobile/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:simpliadz_mobile/features/inventory/presentation/screens/stock_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({required this.controller, super.key});
  final InventoryController controller;
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final r = c.report;
      return Scaffold(
        appBar: AppBar(title: const Text('Inventory')),
        body: RefreshIndicator(
          onRefresh: c.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String?>(
                initialValue: c.locationId,
                decoration: const InputDecoration(labelText: 'Location'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All locations'),
                  ),
                  ...c.locations.map(
                    (x) => DropdownMenuItem(
                      value: x.id,
                      child: Text(x.isActive ? x.name : '${x.name} (inactive)'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  c.selectLocation(value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: c.includeZero,
                title: const Text('Include zero stock'),
                onChanged: c.setZero,
              ),
              if (c.loading && r == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (c.error case final error?) ...[
                Text(error),
                FilledButton(onPressed: c.load, child: const Text('Retry')),
              ],
              if (r case final report?) ...[
                Text(
                  '${report.totalVariants} variants • ${report.totalQuantity} units',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  report.totalValue == null
                      ? 'Not fully valued • known: ${dzd(context, report.knownValue)} • unvalued: ${report.unvaluedQuantity}'
                      : 'Estimated stock value: ${dzd(context, report.totalValue!)}',
                ),
                const Divider(),
                ...report.items.map(
                  (row) => ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StockDetailScreen(api: c.api, row: row),
                      ),
                    ),
                    title: Text(
                      row.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${row.sku} • On hand: ${row.quantity}\n${row.stockValue == null ? 'Value unknown' : dzd(context, row.stockValue!)}',
                    ),
                    isThreeLine: true,
                  ),
                ),
                if (report.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No stock matches these filters.'),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: c.page > 1 ? c.previous : null,
                      child: const Text('Previous'),
                    ),
                    Text('Page ${c.page}'),
                    TextButton(
                      onPressed: report.items.isNotEmpty ? c.next : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
