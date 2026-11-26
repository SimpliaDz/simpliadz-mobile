import 'package:flutter/material.dart';
import 'package:simplia_mobile/core/formatters/money_formatter.dart';
import 'package:simplia_mobile/core/network/authenticated_api_client.dart';
import 'package:simplia_mobile/features/auth/presentation/controllers/auth_controller.dart';

/// Mobile accounting is intentionally read-only: it supports review, not posting expenses.
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({required this.authController, super.key});
  final AuthController authController;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late final _client = AuthenticatedApiClient(
    tokenProvider: widget.authController.accessToken,
  );
  late Future<List<dynamic>> _expenses = _load();

  Future<List<dynamic>> _load() async =>
      (await _client.getDynamic('/expenses?page=1&pageSize=50')
          as List<dynamic>);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Expenses')),
    body: FutureBuilder<List<dynamic>>(
      future: _expenses,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => setState(() => _expenses = _load()),
              child: const Text('Retry'),
            ),
          );
        }
        final rows = snapshot.data!.cast<Map<String, dynamic>>();
        final total = rows.fold<num>(
          0,
          (sum, row) => sum + ((row['amount'] as num?) ?? 0),
        );
        return RefreshIndicator(
          onRefresh: () async => setState(() => _expenses = _load()),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent expenses',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        dzd(context, total),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No expenses found.')),
                ),
              ...rows.map(
                (row) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(row['description'] as String? ?? 'Expense'),
                    subtitle: Text(
                      '${row['expenseDate'] ?? '—'} • Category ${row['expenseCategoryId']}',
                    ),
                    trailing: Text(
                      dzd(context, (row['amount'] as num?) ?? 0),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
