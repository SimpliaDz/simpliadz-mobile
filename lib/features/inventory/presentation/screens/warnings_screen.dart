import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';

class WarningsScreen extends StatefulWidget {
  const WarningsScreen({required this.authController, super.key});
  final AuthController authController;
  @override
  State<WarningsScreen> createState() => _WarningsScreenState();
}

class _WarningsScreenState extends State<WarningsScreen> {
  late final _api = AuthenticatedApiClient(
    tokenProvider: widget.authController.accessToken,
  );
  late Future<(Map<String, dynamic>, List<dynamic>)> _data = _load();
  Future<(Map<String, dynamic>, List<dynamic>)> _load() async => (
    await _api.get('/inventory-warnings/settings'),
    await _api.getDynamic(
      '/inventory-warnings?activeOnly=true&page=1&pageSize=50',
    ) as List<dynamic>,
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Inventory warnings')),
    body: FutureBuilder<(Map<String, dynamic>, List<dynamic>)>(
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
        final settings = snapshot.data!.$1;
        final rows = snapshot.data!.$2;
        return RefreshIndicator(
          onRefresh: () async => setState(() => _data = _load()),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Schedule: ${settings['enabled'] == true ? 'Enabled' : 'Disabled'} • every ${settings['intervalMinutes']} minutes',
              ),
              Text(
                'Low stock: ${settings['lowStockEnabled']} • Ageing: ${settings['ageingEnabled']} • threshold: ${settings['ageThresholdDays']} days',
              ),
              const Divider(),
              if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No active inventory warnings.'),
                ),
              ...rows.cast<Map<String, dynamic>>().map(
                (x) => ListTile(
                  leading: Icon(
                    x['kind'] == 'Ageing'
                        ? Icons.schedule
                        : Icons.warning_amber,
                  ),
                  title: Text('${x['productName']} • ${x['sku']}'),
                  subtitle: Text(
                    '${x['locationName']}\nOn hand: ${x['quantityOnHand']}${x['reorderPoint'] == null ? '' : ' • Reorder: ${x['reorderPoint']}'}',
                  ),
                  isThreeLine: true,
                  trailing: x['quantityOnHand'] == 0
                      ? const Chip(label: Text('Out'))
                      : Chip(label: Text(x['kind'] as String)),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
