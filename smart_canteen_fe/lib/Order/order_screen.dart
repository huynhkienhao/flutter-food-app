import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_canteen_fe/user/UserScreen.dart';

class OrderScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderScreen({required this.orderData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderDetails = orderData['orderDetails'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết hóa đơn"),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
                  (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mã hóa đơn: ${orderData['orderId'] ?? 'Không xác định'}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Tổng tiền: ${orderData['totalPrice'] ?? 0}",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Trạng thái: ${orderData['status'] ?? 'Không xác định'}",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "Thời gian đặt hàng: ${orderData['orderTime'] ?? 'Không xác định'}",
                  style: TextStyle(fontSize: 16),
                ),
                Divider(height: 20, thickness: 1.5),
                Text(
                  "Chi tiết đơn hàng:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: orderDetails.length,
                    itemBuilder: (context, index) {
                      final detail = orderDetails[index];
                      return ListTile(
                        title: Text(
                          detail['productName'] ?? "Không có tên sản phẩm",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text("Số lượng: ${detail['quantity'] ?? 0}"),
                        trailing: Text("Tạm tính: ${detail['subTotal'] ?? 0}"),
                      );
                    },
                  ),
                ),
                Divider(height: 20, thickness: 1.5),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Mã QR cho đơn hàng:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      QrImageView(
                        data: _generateQRCodeData(orderData),
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _generateQRCodeData(Map<String, dynamic> orderData) {
    final buffer = StringBuffer();
    buffer.writeln("Mã hóa đơn: ${orderData['orderId']}");
    buffer.writeln("Tổng tiền: ${orderData['totalPrice']}");
    buffer.writeln("Trạng thái: ${orderData['status']}");
    buffer.writeln("Thời gian đặt hàng: ${orderData['orderTime']}");
    buffer.writeln("Chi tiết đơn hàng:");
    for (var detail in orderData['orderDetails'] ?? []) {
      buffer.writeln("- ${detail['productName']} x${detail['quantity']}: ${detail['subTotal']}");
    }
    return buffer.toString();
  }
}
