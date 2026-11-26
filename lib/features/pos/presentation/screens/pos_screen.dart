import 'package:flutter/material.dart';
import 'package:simplia_mobile/core/barcode/barcode_scanner.dart';
import 'package:simplia_mobile/core/formatters/money_formatter.dart';
import 'package:simplia_mobile/core/network/api_exception.dart';
import 'package:simplia_mobile/core/network/authenticated_api_client.dart';
import 'package:simplia_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simplia_mobile/features/pos/data/pos_api.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({required this.authController, super.key});
  final AuthController authController;
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  late final PosApi _api = PosApi(
    AuthenticatedApiClient(tokenProvider: widget.authController.accessToken),
  );
  final _search = TextEditingController();
  List<Map<String, dynamic>> _locations = [],
      _prices = [],
      _results = [],
      _sessions = [];
  Map<String, dynamic>? _sale;
  String? _location, _price, _session, _error;
  bool _loading = true, _busy = false;
  @override
  void initState() {
    super.initState();
    _loadSetup();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadSetup() async {
    try {
      final values = await Future.wait([_api.locations(), _api.priceLists()]);
      if (!mounted) return;
      setState(() {
        _locations = values[0].where((x) => x['isActive'] == true).toList();
        _prices = values[1].where((x) => x['isActive'] == true).toList();
        _location = _locations.isEmpty
            ? null
            : _locations.first['id'] as String;
        _price = _prices.isEmpty ? null : _prices.first['id'] as String;
        _loading = false;
      });
      await _loadSessions();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _message(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadSessions() async {
    if (_location == null) {
      return;
    }
    try {
      final sessions = await _api.sessions(_location!);
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _session = sessions.isEmpty ? null : sessions.first['id'] as String;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _sessions = [];
          _session = null;
        });
      }
    }
  }

  Future<void> _start() async {
    if (_location == null || _price == null) return;
    await _run(() async {
      _sale = await _api.createSale(_location!, _price!);
      _results = [];
    });
  }

  Future<void> _searchProducts() async {
    final q = _search.text.trim();
    if (q.isEmpty || _price == null || _location == null) return;
    await _run(() async {
      _results = await _api.search(q, _price!, _location!);
    });
  }

  Future<void> _scan() async {
    final scan = await BarcodeScanner.scan(context);
    if (!mounted || scan == null || _price == null || _location == null) return;
    await _run(() async {
      final product = await _api.barcode(scan.value, _price!, _location!);
      await _add(product, barcode: scan.value);
    });
  }

  Future<void> _add(Map<String, dynamic> product, {String? barcode}) async {
    if (_sale == null) return;
    _sale = await _api.addLine(
      _sale!['id'] as String,
      sku: barcode == null ? product['sku'] as String : null,
      barcode: barcode,
    );
    _results = [];
    _search.clear();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      _error = _message(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(Object e) => e is ApiException
      ? e.message
      : 'Something went wrong. Check the API and your permissions.';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_sale == null ? 'Point of sale' : 'Current sale'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _sale == null
        ? _setup(context)
        : _checkout(context),
  );
  Widget _setup(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Start a counter sale',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 16),
      _drop('Location', _location, _locations, (v) async {
        setState(() => _location = v);
        await _loadSessions();
      }),
      const SizedBox(height: 12),
      _drop('Price list', _price, _prices, (v) => setState(() => _price = v)),
      const SizedBox(height: 12),
      _drop(
        'Cash session (optional for card)',
        _session,
        _sessions,
        (v) => setState(() => _session = v),
        allowNull: true,
      ),
      if (_sessions.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'No open cash session found. Cash payment may require one.',
            style: TextStyle(color: Colors.orange),
          ),
        ),
      if (_error != null) _errorText(),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: _busy ? null : _start,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start sale'),
      ),
    ],
  );
  Widget _drop(
    String label,
    String? value,
    List<Map<String, dynamic>> values,
    ValueChanged<String?> onChanged, {
    bool allowNull = false,
  }) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: [
      if (allowNull) const DropdownMenuItem(value: null, child: Text('None')),
      ...values.map(
        (x) => DropdownMenuItem(
          value: x['id'] as String,
          child: Text((x['name'] ?? x['code'] ?? x['id']) as String),
        ),
      ),
    ],
    onChanged: _busy ? null : onChanged,
  );
  Widget _checkout(BuildContext context) {
    final sale = _sale!;
    final lines = (sale['lines'] as List? ?? []).cast<Map<String, dynamic>>();
    final due = (sale['balanceDue'] as num?) ?? 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onSubmitted: (_) => _searchProducts(),
                  decoration: InputDecoration(
                    labelText: 'Search product',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _busy ? null : _searchProducts,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _busy ? null : _scan,
              ),
            ],
          ),
        ),
        if (_results.isNotEmpty)
          SizedBox(
            height: 160,
            child: ListView(
              children: _results
                  .map(
                    (p) => ListTile(
                      title: Text(p['productName'] as String),
                      subtitle: Text(
                        '${p['sku']} • ${dzd(context, p['price'] as num)}',
                      ),
                      trailing: const Icon(Icons.add),
                      onTap: _busy ? null : () => _run(() => _add(p)),
                    ),
                  )
                  .toList(),
            ),
          ),
        Expanded(
          child: lines.isEmpty
              ? const Center(
                  child: Text('Scan a barcode or search for a product.'),
                )
              : ListView(
                  children: lines
                      .map(
                        (l) => ListTile(
                          title: Text('Item ${l['productVariantId']}'),
                          subtitle: Text(
                            '${l['quantity']} × ${dzd(context, l['unitPrice'] as num)}',
                          ),
                          trailing: Text(dzd(context, l['lineTotal'] as num)),
                        ),
                      )
                      .toList(),
                ),
        ),
        if (_error != null) _errorText(),
        _totalBar(context, sale, due),
      ],
    );
  }

  Widget _totalBar(BuildContext context, Map<String, dynamic> sale, num due) =>
      SafeArea(
        top: false,
        child: Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: ${dzd(context, sale['total'] as num)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('Balance due: ${dzd(context, due)}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy || due <= 0
                            ? null
                            : () => _payment(context, due),
                        child: const Text('Take payment'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy || due > 0 ? null : () => _complete(),
                        child: const Text('Complete sale'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  Future<void> _payment(BuildContext context, num due) async {
    String method = 'Cash';
    final amount = TextEditingController(text: due.toString());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Take payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            DropdownButtonFormField(
              initialValue: method,
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(
                  value: 'BankTransfer',
                  child: Text('Bank transfer'),
                ),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) => method = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Record'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(() async {
        await _api.pay(
          _sale!['id'] as String,
          num.parse(amount.text),
          method,
          _session,
        );
        _sale = await _api.sale(_sale!['id'] as String);
      });
    }
  }

  Future<void> _complete() async => _run(() async {
    final done = await _api.complete(_sale!['id'] as String);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sale completed'),
        content: Text('Sale number: ${done['saleNumber'] ?? done['id']}'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    _sale = null;
  });
  Widget _errorText() => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      _error!,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}
