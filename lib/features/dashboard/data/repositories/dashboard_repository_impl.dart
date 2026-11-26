import 'package:simplia_mobile/features/dashboard/data/data_sources/dashboard_api_data_source.dart';
import 'package:simplia_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:simplia_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._source);
  final DashboardApiDataSource _source;

  @override
  Future<DashboardSummary> getToday() async =>
      (await _source.getToday()).toEntity();
}
