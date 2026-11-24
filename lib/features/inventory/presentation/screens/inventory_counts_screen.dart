import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';

/// Read-only mobile view: counts are reviewed here, while count execution stays on web.
class InventoryCountsScreen extends StatefulWidget {
  const InventoryCountsScreen({required this.authController, super.key});
  final AuthController authController;
  @override
  State<InventoryCountsScreen> createState() => _InventoryCountsScreenState();
}

class _InventoryCountsScreenState extends State<InventoryCountsScreen> {
  late final _client = AuthenticatedApiClient(
    tokenProvider: widget.authController.accessToken,
  );
  late Future<List<dynamic>> _counts = _load();
  Future<List<dynamic>> _load() async =>
      (await _client.getDynamic('/inventory-counts?page=1&pageSize=50')
          as List<dynamic>);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Inventory counts')),
    body: FutureBuilder<List<dynamic>>(
      future: _counts,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => setState(() => _counts = _load()),
              child: const Text('Retry'),
            ),
          );
        }
        final counts = snapshot.data!.cast<Map<String, dynamic>>();
        return RefreshIndicator(
          onRefresh: () async => setState(() => _counts = _load()),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Review active and completed stock counts.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (counts.isEmpty)
                const _Empty(message: 'No inventory counts have been started.'),
              ...counts.map((count) {
                final lines = (count['lines'] as List? ?? []).length;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      count['status'] == 'Completed'
                          ? Icons.task_alt
                          : Icons.inventory_outlined,
                    ),
                    title: Text('Count ${count['status'] ?? 'Draft'}'),
                    subtitle: Text(
                      '$lines lines • Started ${count['startedAt'] ?? '—'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _CountDetail(
                          client: _client,
                          id: count['id'] as String,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    ),
  );
}

class _CountDetail extends StatelessWidget {
  const _CountDetail({required this.client, required this.id});
  final AuthenticatedApiClient client;
  final String id;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Count details')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: client.get('/inventory-counts/$id'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return snapshot.hasError
              ? const Center(child: Text('Could not load this count.'))
              : const Center(child: CircularProgressIndicator());
        }
        final count = snapshot.data!;
        final lines = (count['lines'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count['status'] as String? ?? 'Count',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('Started: ${count['startedAt'] ?? '—'}'),
                    if (count['completedAt'] != null)
                      Text('Completed: ${count['completedAt']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...lines.map(
              (line) => ListTile(
                title: Text('Variant ${line['productVariantId']}'),
                subtitle: Text(
                  'Expected: ${line['expectedQuantity']} • Counted: ${line['countedQuantity'] ?? 'Not counted'}',
                ),
                trailing: line['difference'] == null
                    ? null
                    : Text(
                        '${line['difference'] > 0 ? '+' : ''}${line['difference']}',
                      ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(child: Text(message)),
  );
}
