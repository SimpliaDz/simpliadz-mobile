import 'package:simplia_mobile/core/network/authenticated_api_client.dart';

class VariantLookupApi {
  const VariantLookupApi(this._client);
  final AuthenticatedApiClient _client;

  Future<Map<String, dynamic>> byBarcode(String barcode) =>
      _client.get('/variants/by-barcode/${Uri.encodeComponent(barcode)}');
}
