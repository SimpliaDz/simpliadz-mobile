import 'package:simplia_mobile/features/dashboard/domain/entities/dashboard_summary.dart';

abstract interface class DashboardRepository {
  Future<DashboardSummary> getToday();
}
