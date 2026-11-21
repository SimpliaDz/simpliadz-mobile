import 'package:flutter/foundation.dart';
import 'package:simpliadz_mobile/features/reports/domain/entities/sales_reports.dart';
import 'package:simpliadz_mobile/features/reports/domain/repositories/sales_reports_repository.dart';

class SalesReportsController extends ChangeNotifier {
  SalesReportsController(this._repository);
  final SalesReportsRepository _repository;
  SalesReportsRepository get repository => _repository;
  DateTime from = DateTime.now().subtract(const Duration(days: 29));
  DateTime to = DateTime.now();
  String rankBy = 'Quantity';
  int page = 1;
  SalesSummary? summary;
  List<ProductPerformance> products = [];
  bool loading = false;
  String? error;
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      summary = await _repository.summary(from, to);
      products = await _repository.products(from, to, rankBy, page);
    } catch (_) {
      error = 'Could not load sales reports. Please retry.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setRange(DateTime nextFrom, DateTime nextTo) async {
    from = nextFrom;
    to = nextTo;
    page = 1;
    await load();
  }

  Future<void> setRank(String value) async {
    rankBy = value;
    page = 1;
    await load();
  }

  Future<void> next() async {
    page++;
    await load();
  }

  Future<void> previous() async {
    if (page > 1) {
      page--;
      await load();
    }
  }
}
