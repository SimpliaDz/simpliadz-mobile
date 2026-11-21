class DashboardSummary {
  const DashboardSummary({
    required this.date,
    required this.timeZone,
    required this.revenue,
    required this.grossProfit,
    required this.transactionCount,
    required this.itemsSold,
    required this.averageBasket,
    required this.expenses,
    required this.lowStockCount,
    required this.salesAvailable,
    required this.accountingAvailable,
    required this.inventoryAvailable,
  });
  final DateTime date;
  final String timeZone;
  final num revenue;
  final num grossProfit;
  final int transactionCount;
  final int itemsSold;
  final num averageBasket;
  final num expenses;
  final int lowStockCount;
  final bool salesAvailable;
  final bool accountingAvailable;
  final bool inventoryAvailable;
}
