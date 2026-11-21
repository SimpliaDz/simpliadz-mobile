class SalesSummary {
  const SalesSummary(this.json);
  final Map<String, dynamic> json;
  num get revenue => json['revenue'] as num;
  num get costOfGoodsSold => json['costOfGoodsSold'] as num;
  num get grossProfit => json['grossProfit'] as num;
  int get transactionCount => json['transactionCount'] as int;
  int get itemsSold => json['itemsSold'] as int;
  num get averageTransactionValue => json['averageTransactionValue'] as num;
}

class ProductPerformance {
  const ProductPerformance(this.json);
  final Map<String, dynamic> json;
  String get productId => json['productId'] as String;
  String get productName => json['productName'] as String;
  int get netQuantity => json['netQuantitySold'] as int;
  num get netRevenue => json['netRevenue'] as num;
  int get returnedQuantity => json['returnedQuantity'] as int;
}

class VariantPerformance extends ProductPerformance {
  const VariantPerformance(super.json);
  String get sku => json['sku'] as String;
  String? get barcode => json['barcode'] as String?;
}
