import 'package:simplia_mobile/core/network/authenticated_api_client.dart';

class PosApi {
  const PosApi(this._client);
  final AuthenticatedApiClient _client;
  Future<List<Map<String, dynamic>>> locations() async => _list('/locations');
  Future<List<Map<String, dynamic>>> priceLists() async =>
      _list('/price-lists');
  Future<List<Map<String, dynamic>>> sessions(String id) async =>
      _list('/cash-sessions/current?locationId=$id');
  Future<Map<String, dynamic>> createSale(
    String location,
    String prices,
  ) async => _map(
    await _client.postDynamic('/sales', {
      'locationId': location,
      'customerId': null,
      'priceListId': prices,
    }),
  );
  Future<List<Map<String, dynamic>>> search(
    String q,
    String prices,
    String location,
  ) async => _list(
    '/pos/products?search=${Uri.encodeQueryComponent(q)}&priceListId=$prices&locationId=$location&pageSize=25',
  );
  Future<Map<String, dynamic>> barcode(
    String code,
    String prices,
    String location,
  ) async => _map(
    await _client.getDynamic(
      '/pos/products/by-barcode/${Uri.encodeComponent(code)}?priceListId=$prices&locationId=$location',
    ),
  );
  Future<Map<String, dynamic>> addLine(
    String sale, {
    String? sku,
    String? barcode,
  }) async => _map(
    await _client.postDynamic('/sales/$sale/lines', {
      'sku': sku,
      'barcode': barcode,
      'quantity': 1,
      'discountAmount': 0,
    }),
  );
  Future<Map<String, dynamic>> sale(String id) async =>
      _map(await _client.getDynamic('/sales/$id'));
  Future<void> pay(
    String sale,
    num amount,
    String method,
    String? session,
  ) async {
    await _client.postDynamic('/sales/$sale/payments', {
      'id': _guid(),
      'amount': amount,
      'paymentMethod': method,
      'cashSessionId': session,
    });
  }

  Future<Map<String, dynamic>> complete(String sale) async =>
      _map(await _client.postDynamic('/sales/$sale/complete', null));
  Future<List<Map<String, dynamic>>> _list(String path) async =>
      (await _client.getDynamic(path) as List).cast<Map<String, dynamic>>();
  Map<String, dynamic> _map(dynamic value) => value as Map<String, dynamic>;
  String _guid() {
    final h = DateTime.now().microsecondsSinceEpoch
        .toRadixString(16)
        .padLeft(32, '0')
        .substring(0, 32);
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-4${h.substring(13, 16)}-8${h.substring(17, 20)}-${h.substring(20)}';
  }
}
