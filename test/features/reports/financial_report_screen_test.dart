import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simpliadz_mobile/app/app_theme.dart';
import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/reports/data/data_sources/financial_report_api.dart';
import 'package:simpliadz_mobile/features/reports/presentation/screens/financial_report_screen.dart';

void main() {
  testWidgets('selecting a shop requests its figures on a narrow dark screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final requests = <Uri>[];
    final client = AuthenticatedApiClient(
      tokenProvider: ({bool refresh = false}) async => 'test',
      client: MockClient((request) async {
        requests.add(request.url);
        final filtered = request.url.queryParameters['locationId'] == 'shop-a';
        return http.Response(
          jsonEncode({
            'netSales': filtered ? 25 : 100,
            'grossProfit': 15,
            'expenses': 5,
            'operatingContribution': 10,
            'discounts': 0,
            'refunds': 0,
            'costOfGoodsSold': 10,
            'averageTransactionValue': 10,
            'transactionCount': 1,
            'itemsSold': 1,
            'grossMarginPercent': 10,
            'dailyTrend': [],
            'paymentMethods': [],
            'topProducts': [],
            'locations': [
              {
                'locationId': 'shop-a',
                'locationName': 'Shop A',
                'netSales': 25,
              },
            ],
          }),
          200,
        );
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.dark),
        home: FinancialReportScreen(api: FinancialReportApi(client)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('100.00'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shop A').hitTestable().last);
    await tester.pumpAndSettle();

    expect(requests.last.queryParameters['locationId'], 'shop-a');
    expect(
      requests.last.queryParameters['fromDate'],
      requests.first.queryParameters['fromDate'],
    );
    expect(find.text('25.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
