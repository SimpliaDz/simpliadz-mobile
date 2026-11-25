class FinancialReport {
  FinancialReport.fromJson(Map<String, dynamic> json)
    : metrics = {
        'Net sales': json['netSales'] as num,
        'Gross profit': json['grossProfit'] as num,
        'Expenses': json['expenses'] as num,
        'Operating contribution': json['operatingContribution'] as num,
        'Discounts': json['discounts'] as num,
        'Refunds': json['refunds'] as num,
        'Cost of goods sold': json['costOfGoodsSold'] as num,
        'Average sale': json['averageTransactionValue'] as num,
      },
      transactions = json['transactionCount'] as int,
      itemsSold = json['itemsSold'] as int,
      margin = json['grossMarginPercent'] as num,
      trend = _rows(json, 'dailyTrend')
          .map(
            (row) => (
              date: DateTime.parse(row['date'] as String),
              sales: row['netSales'] as num,
            ),
          )
          .toList(),
      payments = _rows(json, 'paymentMethods')
          .map(
            (row) => (
              name: row['method'] as String,
              amount: row['amount'] as num,
              share: row['percentOfPayments'] as num,
            ),
          )
          .toList(),
      locations = _rows(json, 'locations')
          .map(
            (row) => (
              id: row['locationId'] as String,
              name: row['locationName'] as String,
              sales: row['netSales'] as num,
            ),
          )
          .toList(),
      products = _rows(json, 'topProducts')
          .map(
            (row) => (
              name: row['productName'] as String,
              sales: row['netSales'] as num,
              quantity: row['netQuantity'] as int,
            ),
          )
          .toList();

  final Map<String, num> metrics;
  final int transactions, itemsSold;
  final num margin;
  final List<({DateTime date, num sales})> trend;
  final List<({String name, num amount, num share})> payments;
  final List<({String id, String name, num sales})> locations;
  final List<({String name, num sales, int quantity})> products;

  static Iterable<Map<String, dynamic>> _rows(
    Map<String, dynamic> json,
    String key,
  ) => (json[key] as List).cast<Map<String, dynamic>>();
}
