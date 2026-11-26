import 'package:simplia_mobile/features/reports/domain/entities/sales_reports.dart';

abstract interface class SalesReportsRepository {
  Future<SalesSummary> summary(DateTime from, DateTime to);
  Future<List<ProductPerformance>> products(
    DateTime from,
    DateTime to,
    String rankBy,
    int page,
  );
  Future<List<VariantPerformance>> variants(
    String productId,
    DateTime from,
    DateTime to,
    int page,
  );
}
