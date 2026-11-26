import 'package:simplia_mobile/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardSummaryModel {
  const DashboardSummaryModel(this.json);
  final Map<String, dynamic> json;

  DashboardSummary toEntity() => DashboardSummary(
    date: DateTime.parse(json['date'] as String),
    timeZone: json['timeZone'] as String,
    revenue: json['revenue'] as num,
    grossProfit: json['grossProfit'] as num,
    transactionCount: json['transactionCount'] as int,
    itemsSold: json['itemsSold'] as int,
    averageBasket: json['averageBasket'] as num,
    expenses: json['expenses'] as num,
    lowStockCount: json['lowStockCount'] as int,
    salesAvailable: json['salesAvailable'] as bool,
    accountingAvailable: json['accountingAvailable'] as bool,
    inventoryAvailable: json['inventoryAvailable'] as bool,
  );
}
