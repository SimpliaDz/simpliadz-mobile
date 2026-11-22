import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/barcode/barcode_scanner.dart';
import 'package:simpliadz_mobile/core/formatters/money_formatter.dart';
import 'package:simpliadz_mobile/core/network/api_exception.dart';
import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simpliadz_mobile/features/product_lookup/data/variant_lookup_api.dart';

class ProductLookupScreen extends StatefulWidget {
  const ProductLookupScreen({required this.authController, super.key});
  final AuthController authController;
  @override
  State<ProductLookupScreen> createState() => _ProductLookupScreenState();
}

class _ProductLookupScreenState extends State<ProductLookupScreen> {
  final _barcode = TextEditingController();
  late final _api = VariantLookupApi(
    AuthenticatedApiClient(tokenProvider: widget.authController.accessToken),
  );
  Map<String, dynamic>? _variant;
  String? _error;
  bool _loading = false;
  @override
  void dispose() {
    _barcode.dispose();
    super.dispose();
  }

  Future<void> _search([String? value]) async {
    final barcode = (value ?? _barcode.text).trim();
    if (barcode.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _variant = null;
    });
    try {
      final result = await _api.byBarcode(barcode);
      if (mounted) {
        setState(() => _variant = result);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.statusCode == 404
              ? 'No product variant has this barcode.'
              : error.message,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not search for this barcode.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _scan() async {
    final result = await BarcodeScanner.scan(context);
    if (!mounted || result == null) return;
    _barcode.text = result.value;
    await _search(result.value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Product lookup')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: _barcode,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: _search,
          decoration: InputDecoration(
            labelText: 'Barcode',
            prefixIcon: const Icon(Icons.barcode_reader),
            suffixIcon: IconButton(
              onPressed: _scan,
              tooltip: 'Scan barcode',
              icon: const Icon(Icons.qr_code_scanner),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loading ? null : _search,
          icon: const Icon(Icons.search),
          label: const Text('Search barcode'),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_error case final error?)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (_variant case final v?) _VariantCard(variant: v),
      ],
    ),
  );
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({required this.variant});
  final Map<String, dynamic> variant;
  @override
  Widget build(BuildContext context) {
    final attributes = (variant['attributeValues'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    return Card(
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              variant['sku'] as String,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              variant['isActive'] == true
                  ? 'Active variant'
                  : 'Inactive variant',
            ),
            const SizedBox(height: 12),
            Text(
              'Retail price: ${dzd(context, variant['retailPrice'] as num)}',
            ),
            if (variant['wholesalePrice'] case final num price)
              Text('Wholesale price: ${dzd(context, price)}'),
            if (attributes.isNotEmpty) const Divider(),
            ...attributes.map(
              (a) => Text('${a['attributeName']}: ${a['value']}'),
            ),
          ],
        ),
      ),
    );
  }
}
