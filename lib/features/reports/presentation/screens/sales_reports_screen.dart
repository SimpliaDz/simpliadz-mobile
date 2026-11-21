import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/formatters/money_formatter.dart';
import 'package:simpliadz_mobile/features/reports/presentation/controllers/sales_reports_controller.dart';
import 'package:simpliadz_mobile/features/reports/presentation/screens/variant_performance_screen.dart';

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({required this.controller, super.key});
  final SalesReportsController controller;
  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
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
      return Scaffold(
        appBar: AppBar(title: const Text('Sales reports')),
        body: RefreshIndicator(
          onRefresh: c.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Original sales summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text('Returns do not alter these original-sale figures.'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: DateTimeRange(start: c.from, end: c.to),
                  );
                  if (range != null) await c.setRange(range.start, range.end);
                },
                icon: const Icon(Icons.date_range),
                label: Text(
                  '${c.from.toIso8601String().substring(0, 10)} – ${c.to.toIso8601String().substring(0, 10)}',
                ),
              ),
              if (c.loading && c.summary == null)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (c.error case final error?) ...[
                Text(error),
                FilledButton(onPressed: c.load, child: const Text('Retry')),
              ],
              if (c.summary case final summary?) ...[
                Text('Revenue: ${dzd(context, summary.revenue)}'),
                Text('Gross profit: ${dzd(context, summary.grossProfit)}'),
                Text(
                  'Transactions: ${summary.transactionCount} • Items: ${summary.itemsSold}',
                ),
                Text(
                  'Average transaction: ${dzd(context, summary.averageTransactionValue)}',
                ),
                const Divider(height: 36),
                Text(
                  'Product performance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text('Net figures include accepted returns.'),
                DropdownButton<String>(
                  value: c.rankBy,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'Quantity',
                      child: Text('Rank by quantity'),
                    ),
                    DropdownMenuItem(
                      value: 'Revenue',
                      child: Text('Rank by revenue'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) c.setRank(value);
                  },
                ),
                ...c.products.map(
                  (p) => ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VariantPerformanceScreen(
                          repository: c.repository,
                          productId: p.productId,
                          productName: p.productName,
                          from: c.from,
                          to: c.to,
                        ),
                      ),
                    ),
                    title: Text(p.productName),
                    subtitle: Text(
                      'Net qty ${p.netQuantity} • Returns ${p.returnedQuantity}',
                    ),
                    trailing: Text(dzd(context, p.netRevenue)),
                  ),
                ),
                if (c.products.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No product activity for this range.'),
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
                      onPressed: c.products.isNotEmpty ? c.next : null,
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
