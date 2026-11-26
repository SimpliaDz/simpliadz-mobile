import 'package:simplia_mobile/core/network/authenticated_api_client.dart';
import 'package:simplia_mobile/features/reports/domain/entities/financial_report.dart';

class FinancialReportApi {
  const FinancialReportApi(this._client);

  final AuthenticatedApiClient _client;

  Future<Map<String, String>> shops() async {
    final locations = (await _client.getDynamic('/locations') as List)
        .cast<Map<String, dynamic>>();
    return {
      for (final location in locations)
        if (location['type'] == 'Store')
          location['id'] as String: location['name'] as String,
    };
  }

  Future<FinancialReport> load({
    required String fromDate,
    required String toDate,
    String? locationId,
  }) async {
    final query = Uri(
      queryParameters: {
        'fromDate': fromDate,
        'toDate': toDate,
        'locationId': ?locationId,
      },
    ).query;
    return FinancialReport.fromJson(
      await _client.get('/reports/financial-dashboard?$query'),
    );
  }
}
