import 'package:flutter/foundation.dart';
import 'package:simplia_mobile/features/inventory/data/data_sources/inventory_api_data_source.dart';
import 'package:simplia_mobile/features/inventory/domain/entities/inventory_report.dart';

class InventoryController extends ChangeNotifier {
  InventoryController(this._api);
  final InventoryApiDataSource _api;
  InventoryApiDataSource get api => _api;
  List<InventoryLocation> locations = [];
  InventoryReport? report;
  String? locationId, error;
  bool includeZero = false, loading = false;
  int page = 1;
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      locations = await _api.locations();
      report = await _api.report(
        locationId: locationId,
        zero: includeZero,
        page: page,
      );
    } catch (_) {
      error = 'Could not load inventory. Please retry.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> selectLocation(String? id) async {
    locationId = id;
    page = 1;
    await load();
  }

  Future<void> setZero(bool value) async {
    includeZero = value;
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
