import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/inventory/domain/entities/inventory_report.dart';

class InventoryApiDataSource {
  const InventoryApiDataSource(this._client);
  final AuthenticatedApiClient _client;
  Future<List<InventoryLocation>> locations() async {
    final data = await _client.getDynamic('/locations') as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(
          (x) => InventoryLocation(
            id: x['id'] as String,
            name: x['name'] as String,
            isActive: x['isActive'] as bool,
          ),
        )
        .toList();
  }

  Future<InventoryReport> report({
    String? locationId,
    required bool zero,
    required int page,
  }) async {
    final location = locationId == null ? '' : '&locationId=$locationId';
    final data = await _client.get(
      '/reports/inventory?includeZeroStock=$zero&page=$page&pageSize=25$location',
    );
    return InventoryReport(data);
  }

  Future<List<Map<String, dynamic>>> balances(String variantId) async =>
      (await _client.getDynamic('/stock/variants/$variantId') as List<dynamic>)
          .cast<Map<String, dynamic>>();

  Future<int> total(String variantId) async =>
      (await _client.get('/stock/variants/$variantId/total'))['quantityOnHand']
          as int;
}
