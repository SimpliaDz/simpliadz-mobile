import 'package:simpliadz_mobile/features/reports/data/data_sources/sales_reports_api_data_source.dart';
import 'package:simpliadz_mobile/features/reports/domain/entities/sales_reports.dart';
import 'package:simpliadz_mobile/features/reports/domain/repositories/sales_reports_repository.dart';

class SalesReportsRepositoryImpl implements SalesReportsRepository {
  const SalesReportsRepositoryImpl(this._source);
  final SalesReportsApiDataSource _source;
  @override
  Future<SalesSummary> summary(DateTime from, DateTime to) async =>
      SalesSummary(await _source.summary(from, to));
  @override
  Future<List<ProductPerformance>> products(
    DateTime from,
    DateTime to,
    String rankBy,
    int page,
  ) async => (await _source.products(
    from,
    to,
    rankBy,
    page,
  )).cast<Map<String, dynamic>>().map(ProductPerformance.new).toList();
  @override
  Future<List<VariantPerformance>> variants(
    String id,
    DateTime from,
    DateTime to,
    int page,
  ) async => (await _source.variants(
    id,
    from,
    to,
    page,
  )).cast<Map<String, dynamic>>().map(VariantPerformance.new).toList();
}
