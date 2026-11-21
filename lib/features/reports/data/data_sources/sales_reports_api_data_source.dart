import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';

class SalesReportsApiDataSource {
  const SalesReportsApiDataSource(this._client);
  final AuthenticatedApiClient _client;

  Future<Map<String, dynamic>> summary(DateTime from, DateTime to) =>
      _client.get(
        '/reports/sales/summary?fromDate=${_date(from)}&toDate=${_date(to)}',
      );
  Future<List<dynamic>> products(
    DateTime from,
    DateTime to,
    String rankBy,
    int page,
  ) => _list(
    '/reports/products/performance?fromDate=${_date(from)}&toDate=${_date(to)}&rankBy=$rankBy&page=$page&pageSize=25',
  );
  Future<List<dynamic>> variants(
    String id,
    DateTime from,
    DateTime to,
    int page,
  ) => _list(
    '/reports/products/$id/variants?fromDate=${_date(from)}&toDate=${_date(to)}&page=$page&pageSize=25',
  );

  Future<List<dynamic>> _list(String path) async {
    final value = await _client.getDynamic(path);
    return value as List<dynamic>;
  }

  String _date(DateTime value) => value.toIso8601String().substring(0, 10);
}
