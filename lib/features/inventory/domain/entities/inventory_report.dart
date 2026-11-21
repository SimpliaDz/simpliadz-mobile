class InventoryLocation {
  const InventoryLocation({
    required this.id,
    required this.name,
    required this.isActive,
  });
  final String id, name;
  final bool isActive;
}

class InventoryRow {
  const InventoryRow(this.json);
  final Map<String, dynamic> json;
  String get id => json['productVariantId'] as String;
  String get productName => json['productName'] as String;
  String get sku => json['sku'] as String;
  String? get barcode => json['barcode'] as String?;
  int get quantity => json['quantityOnHand'] as int;
  num? get unitCost => json['unitCost'] as num?;
  num? get stockValue => json['stockValue'] as num?;
}

class InventoryReport {
  const InventoryReport(this.json);
  final Map<String, dynamic> json;
  int get totalVariants => json['totalVariants'] as int;
  int get totalQuantity => json['totalQuantityOnHand'] as int;
  num get knownValue => json['knownStockValue'] as num;
  int get unvaluedQuantity => json['unvaluedQuantity'] as int;
  num? get totalValue => json['totalStockValue'] as num?;
  List<InventoryRow> get items => (json['items'] as List)
      .cast<Map<String, dynamic>>()
      .map(InventoryRow.new)
      .toList();
}
