import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/dashboard/data/models/dashboard_summary_model.dart';

class DashboardApiDataSource {
  const DashboardApiDataSource(this._client);
  final AuthenticatedApiClient _client;

  Future<DashboardSummaryModel> getToday() async =>
      DashboardSummaryModel(await _client.get('/reports/dashboard/today'));
}
