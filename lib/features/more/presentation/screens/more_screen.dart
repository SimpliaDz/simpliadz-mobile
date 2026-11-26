import 'package:flutter/material.dart';
import 'package:simplia_mobile/core/network/authenticated_api_client.dart';
import 'package:simplia_mobile/features/accounting/presentation/screens/expenses_screen.dart';
import 'package:simplia_mobile/features/audit/presentation/screens/audit_log_screen.dart';
import 'package:simplia_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simplia_mobile/features/inventory/presentation/screens/inventory_counts_screen.dart';
import 'package:simplia_mobile/features/inventory/presentation/screens/warnings_screen.dart';
import 'package:simplia_mobile/features/product_lookup/presentation/product_lookup_screen.dart';
import 'package:simplia_mobile/features/reports/data/data_sources/financial_report_api.dart';
import 'package:simplia_mobile/features/reports/presentation/controllers/sales_reports_controller.dart';
import 'package:simplia_mobile/features/reports/presentation/screens/financial_report_screen.dart';
import 'package:simplia_mobile/features/reports/presentation/screens/sales_reports_screen.dart';
import 'package:simplia_mobile/features/workforce/presentation/screens/work_hours_report_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    required this.authController,
    this.salesReportsController,
    super.key,
  });

  final AuthController authController;
  final SalesReportsController? salesReportsController;

  @override
  Widget build(BuildContext context) {
    final permissions = authController.currentUser?.permissions ?? [];
    final reports = salesReportsController;
    final tools = <Widget>[];
    void add(
      String permission,
      IconData icon,
      String label,
      WidgetBuilder page,
    ) {
      if (!permissions.contains(permission)) return;
      tools.add(
        Card(
          child: ListTile(
            leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: page)),
          ),
        ),
      );
    }

    AuthenticatedApiClient client() =>
        AuthenticatedApiClient(tokenProvider: authController.accessToken);

    if (reports != null) {
      add(
        'reports.sales-summary.view',
        Icons.analytics_outlined,
        'Financial dashboard',
        (_) => FinancialReportScreen(
          api: FinancialReportApi(client()),
          canListShops: permissions.contains('locations.view'),
        ),
      );
      if (permissions.contains('reports.product-performance.view')) {
        add(
          'reports.sales-summary.view',
          Icons.insights_outlined,
          'Sales and product performance',
          (_) => SalesReportsScreen(controller: reports),
        );
      }
      add(
        'expenses.view',
        Icons.receipt_long_outlined,
        'Expenses',
        (_) => ExpensesScreen(authController: authController),
      );
      add(
        'work-sessions.report',
        Icons.schedule,
        'Worked hours',
        (_) => WorkHoursReportScreen(client: client()),
      );
    }

    if (reports == null) {
      add(
        'stock.view',
        Icons.fact_check_outlined,
        'Inventory counts',
        (_) => InventoryCountsScreen(authController: authController),
      );
      add(
        'inventory-warnings.view',
        Icons.warning_amber_outlined,
        'Inventory warnings',
        (_) => WarningsScreen(authController: authController),
      );
      add(
        'variants.view',
        Icons.qr_code_scanner,
        'Find product by barcode',
        (_) => ProductLookupScreen(authController: authController),
      );
      add(
        'audit.view',
        Icons.history,
        'Audit history',
        (_) => AuditLogScreen(authController: authController),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(reports == null ? 'More' : 'Reports')),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tools.isEmpty ? 1 : tools.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) => tools.isEmpty
              ? const ListTile(
                  title: Text('No tools are available for your account.'),
                )
              : tools[index],
        ),
      ),
    );
  }
}
