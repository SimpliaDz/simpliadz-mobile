import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/formatters/money_formatter.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:simpliadz_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:simpliadz_mobile/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:simpliadz_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/reports/data/data_sources/sales_reports_api_data_source.dart';
import 'package:simpliadz_mobile/features/reports/data/repositories/sales_reports_repository_impl.dart';
import 'package:simpliadz_mobile/features/reports/presentation/controllers/sales_reports_controller.dart';
import 'package:simpliadz_mobile/features/reports/presentation/screens/sales_reports_screen.dart';
import 'package:simpliadz_mobile/features/inventory/data/data_sources/inventory_api_data_source.dart';
import 'package:simpliadz_mobile/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:simpliadz_mobile/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:simpliadz_mobile/features/more/presentation/screens/more_screen.dart';

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
  late final SalesReportsController _salesController;
  late final InventoryController _inventoryController;
  @override
  void initState() {
    super.initState();
    widget.dashboardController.load();
    _salesController = SalesReportsController(
      SalesReportsRepositoryImpl(
        SalesReportsApiDataSource(
          AuthenticatedApiClient(
            tokenProvider: widget.authController.accessToken,
          ),
        ),
      ),
    );
    _inventoryController = InventoryController(
      InventoryApiDataSource(
        AuthenticatedApiClient(
          tokenProvider: widget.authController.accessToken,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.dashboardController,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('SimpliaDz'),
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
                builder: (_) =>
                    SalesReportsScreen(controller: _salesController),
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
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
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
      padding: const EdgeInsets.all(20),
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
        const SizedBox(height: 20),
        Text(
          'Pull down to refresh. Metric links will open reports as those pages are added.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
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
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metrics.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth >= 600 ? 3 : 2,
          childAspectRatio: 1.35,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(metric.$3, color: Theme.of(context).colorScheme.primary),
                  const Spacer(),
                  Text(
                    metric.$1,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    metric.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
