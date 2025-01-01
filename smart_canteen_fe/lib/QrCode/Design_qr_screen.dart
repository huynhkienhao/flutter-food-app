import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  DetailScreen({required this.orderData});

  String formatCurrency(double amount) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return currencyFormat.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final orderDetails = orderData['orderDetails'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết đơn hàng"),
        backgroundColor: Colors.blue[800],
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
                  "Mã hóa đơn: ${orderData['orderId']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Tổng tiền: ${formatCurrency(orderData['totalPrice'] ?? 0)}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Trạng thái: ${orderData['status']}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Thời gian đặt hàng: ${orderData['orderTime']}",
                  style: TextStyle(fontSize: 16),
                ),
                Divider(thickness: 1.5, height: 20),
                Text(
                  "Chi tiết đơn hàng:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: orderDetails.length,
                    itemBuilder: (context, index) {
                      final item = orderDetails[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['productName'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Số lượng: ${item['quantity']}",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Text(
                              "Tạm tính: ${formatCurrency(item['subTotal'] ?? 0)}",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
