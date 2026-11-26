import 'package:flutter/material.dart';
import 'package:simplia_mobile/core/barcode/barcode_scan_result.dart';
import 'package:simplia_mobile/core/barcode/presentation/barcode_scanner_screen.dart';

class BarcodeScanner {
  const BarcodeScanner._();
  static Future<BarcodeScanResult?> scan(BuildContext context) =>
      Navigator.of(context).push<BarcodeScanResult>(
        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
      );
}
