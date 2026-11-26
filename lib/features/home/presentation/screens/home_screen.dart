import 'package:flutter/material.dart';
import 'package:simplia_mobile/core/formatters/money_formatter.dart';
import 'package:simplia_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simplia_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:simplia_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:simplia_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:simplia_mobile/core/network/authenticated_api_client.dart';
import 'package:simplia_mobile/features/inventory/data/data_sources/inventory_api_data_source.dart';
import 'package:simplia_mobile/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:simplia_mobile/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:simplia_mobile/features/more/presentation/screens/more_screen.dart';
import 'package:simplia_mobile/features/reports/data/data_sources/sales_reports_api_data_source.dart';
import 'package:simplia_mobile/features/reports/data/repositories/sales_reports_repository_impl.dart';
import 'package:simplia_mobile/features/reports/presentation/controllers/sales_reports_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.authController,
    required this.dashboardController,
    super.key,
  });
  final AuthController authController;
  final DashboardController dashboardController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final InventoryController _inventoryController;
  late final SalesReportsController _reportsController;
  @override
  void initState() {
    super.initState();
    widget.dashboardController.load();
    _inventoryController = InventoryController(
      InventoryApiDataSource(
        AuthenticatedApiClient(
          tokenProvider: widget.authController.accessToken,
        ),
      ),
    );
    _reportsController = SalesReportsController(
      SalesReportsRepositoryImpl(
        SalesReportsApiDataSource(
          AuthenticatedApiClient(
            tokenProvider: widget.authController.accessToken,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.dashboardController,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('SimpliaWear'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.authController.signOut();
              if (!mounted) return;
              Navigator.of(this.context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => LoginScreen(
                    authController: widget.authController,
                    dashboardController: widget.dashboardController,
                  ),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: widget.dashboardController.load,
        child: _body(context),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MoreScreen(
                  authController: widget.authController,
                  salesReportsController: _reportsController,
                ),
              ),
            );
          }
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InventoryScreen(
                  controller: _inventoryController,
                  authController: widget.authController,
                ),
              ),
            );
          }
          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    MoreScreen(authController: widget.authController),
              ),
            );
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'More',
          ),
        ],
      ),
    ),
  );

  Widget _body(BuildContext context) {
    final controller = widget.dashboardController;
    if (controller.isLoading && controller.summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage case final error?) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            controller.isForbidden
                ? Icons.lock_outline
                : Icons.cloud_off_outlined,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: controller.load, child: const Text('Retry')),
        ],
      );
    }
    final summary = controller.summary;
    if (summary == null) return const SizedBox.shrink();
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          'Today at a glance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          '${summary.date.toIso8601String().substring(0, 10)} • ${summary.timeZone}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        _MetricsGrid(summary: summary),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        'Revenue',
        summary.salesAvailable ? dzd(context, summary.revenue) : 'Unavailable',
        Icons.payments_outlined,
      ),
      (
        'Gross profit',
        summary.salesAvailable
            ? dzd(context, summary.grossProfit)
            : 'Unavailable',
        Icons.trending_up_outlined,
      ),
      (
        'Transactions',
        summary.salesAvailable ? '${summary.transactionCount}' : 'Unavailable',
        Icons.receipt_long_outlined,
      ),
      (
        'Items sold',
        summary.salesAvailable ? '${summary.itemsSold}' : 'Unavailable',
        Icons.shopping_bag_outlined,
      ),
      (
        'Average basket',
        summary.salesAvailable
            ? dzd(context, summary.averageBasket)
            : 'Unavailable',
        Icons.shopping_cart_outlined,
      ),
      (
        'Expenses',
        summary.accountingAvailable
            ? dzd(context, summary.expenses)
            : 'Unavailable',
        Icons.account_balance_wallet_outlined,
      ),
      (
        'Low stock',
        summary.inventoryAvailable ? '${summary.lowStockCount}' : 'Unavailable',
        Icons.warning_amber_outlined,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final metric in metrics)
            SizedBox(
              width: constraints.maxWidth < 310
                  ? constraints.maxWidth
                  : (constraints.maxWidth -
                            (constraints.maxWidth >= 600 ? 24 : 12)) /
                        (constraints.maxWidth >= 600 ? 3 : 2),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        metric.$3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        metric.$1,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        metric.$2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
