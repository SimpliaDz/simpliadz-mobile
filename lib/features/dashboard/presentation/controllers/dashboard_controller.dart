import 'package:flutter/foundation.dart';
import 'package:simplia_mobile/core/network/api_exception.dart';
import 'package:simplia_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:simplia_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._repository);
  final DashboardRepository _repository;
  DashboardSummary? summary;
  String? errorMessage;
  bool isLoading = false;
  bool get isForbidden => _forbidden;
  bool _forbidden = false;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    _forbidden = false;
    notifyListeners();
    try {
      summary = await _repository.getToday();
    } on ApiException catch (error) {
      _forbidden = error.statusCode == 403;
      errorMessage = _forbidden
          ? 'You do not have permission to view the dashboard.'
          : error.message;
    } catch (_) {
      errorMessage = 'Could not load the dashboard. Please retry.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
