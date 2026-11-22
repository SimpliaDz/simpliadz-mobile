import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/core/barcode/barcode_scanner.dart';
import 'package:simpliadz_mobile/features/product_lookup/presentation/product_lookup_screen.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({required this.authController, super.key});
  final AuthController authController;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('More')),
    body: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Find product by barcode'),
          subtitle: const Text('Search manually or scan with the camera'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  ProductLookupScreen(authController: authController),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.qr_code_scanner),
          title: const Text('Scan barcode'),
          subtitle: const Text('Test the device camera scanner'),
          onTap: () async {
            final result = await BarcodeScanner.scan(context);
            if (!context.mounted || result == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Scanned: ${result.value} (${result.format})'),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Worked hours'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _DataScreen(
                authController: authController,
                title: 'Worked hours',
                path:
                    '/reports/work-hours?fromDate=2026-11-01&toDate=2026-11-30',
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Audit history'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _DataScreen(
                authController: authController,
                title: 'Audit history',
                path: '/audit/entries?page=1&pageSize=50',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DataScreen extends StatefulWidget {
  const _DataScreen({
    required this.authController,
    required this.title,
    required this.path,
  });
  final AuthController authController;
  final String title, path;
  @override
  State<_DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<_DataScreen> {
  late final _client = AuthenticatedApiClient(
    tokenProvider: widget.authController.accessToken,
  );
  late Future<dynamic> _load = _client.getDynamic(widget.path);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: FutureBuilder<dynamic>(
      future: _load,
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () =>
                  setState(() => _load = _client.getDynamic(widget.path)),
              child: const Text('Retry'),
            ),
          );
        }
        final value = s.data;
        if (value is Map<String, dynamic>) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: value.entries
                .map(
                  (x) => ListTile(
                    title: Text(x.key),
                    subtitle: Text('${x.value}'),
                  ),
                )
                .toList(),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: (value as List)
              .map((x) => ListTile(title: Text('$x')))
              .toList(),
        );
      },
    ),
  );
}
