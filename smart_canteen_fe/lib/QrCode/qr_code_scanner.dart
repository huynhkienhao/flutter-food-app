import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:smart_canteen_fe/Order/order_screen.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class QrCodeScanner extends StatefulWidget {
  @override
  _QrCodeScannerState createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  String formatCurrency(double amount) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return currencyFormat.format(amount);
  }

  Future<void> scanQrCode(BuildContext context) async {
    try {
      final result = await BarcodeScanner.scan();

      if (result.type == ResultType.Barcode) {
        final scannedData = result.rawContent.trim();
        print('Scanned Data: $scannedData');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderScreen(orderData: _parseScannedData(scannedData)),
          ),
        );
      }
    } catch (e) {
      print('Error occurred while scanning QR Code: $e');
    }
  }

  Map<String, dynamic> _parseScannedData(String data) {
    try {
      return json.decode(data);
    } catch (e) {
      print('Invalid QR Code format: $e');
      return _parseTextBasedQRCode(data);
    }
  }

  Map<String, dynamic> _parseTextBasedQRCode(String data) {
    final Map<String, dynamic> parsedData = {
      "orderId": null,
      "totalPrice": null,
      "status": null,
      "orderTime": null,
      "orderDetails": []
    };

    try {
      final lines = data.split('\n');
      for (var line in lines) {
        if (line.startsWith("Mã hóa đơn:")) {
          parsedData["orderId"] = int.tryParse(line.split(':').last.trim());
        } else if (line.startsWith("Tổng tiền:")) {
          final price = double.tryParse(line.split(':').last.trim()) ?? 0;
          parsedData["totalPrice"] = formatCurrency(price);
        } else if (line.startsWith("Trạng thái:")) {
          parsedData["status"] = line.split(':').last.trim();
        } else if (line.startsWith("Thời gian đặt hàng:")) {
          parsedData["orderTime"] = line.split(':').last.trim();
        } else if (line.startsWith("-")) {
          final parts = line.substring(1).split('x');
          if (parts.length == 2) {
            final subTotal = double.tryParse(parts[1].split(':').last.trim()) ?? 0;
            parsedData["orderDetails"].add({
              "productName": parts[0].trim(),
              "quantity": int.tryParse(parts[1].split(':').first.trim()),
              "subTotal": formatCurrency(subTotal),
            });
          }
        }
      }
    } catch (e) {
      print('Failed to parse text-based QR code: $e');
    }

    return parsedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Scanner"),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => scanQrCode(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            "Scan QR Code",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
