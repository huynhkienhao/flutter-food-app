import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smart_canteen_fe/user/UserScreen.dart';

class OrderScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderScreen({required this.orderData, Key? key}) : super(key: key);

  NumberFormat getCurrencyFormat() {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  }

  String formatOrderTime(String? rawDate) {
    if (rawDate == null) return "Không xác định";
    try {
      final DateTime parsedDate = DateTime.parse(rawDate);
      final DateFormat formatter = DateFormat("dd-MM-yyyy 'lúc' HH:mm");
      return formatter.format(parsedDate);
    } catch (e) {
      return "Không xác định";
    }
  }

  String translateStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Đang chờ xử lý';
      case 'completed':
        return 'Hoàn thành';
      case 'canceled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange; // Màu cam cho trạng thái "Đang chờ xử lý"
      case 'completed':
        return Colors.green; // Màu xanh cho trạng thái "Hoàn thành"
      case 'canceled':
        return Colors.red; // Màu đỏ cho trạng thái "Đã hủy"
      default:
        return Colors.grey; // Màu xám cho trạng thái không xác định
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderDetails = orderData['orderDetails'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chi tiết hóa đơn",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
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
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Hóa Đơn",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInfoRow("Mã hóa đơn:", "${orderData['orderId']}"),
                  _buildInfoRow("Tổng tiền:",
                      getCurrencyFormat().format(orderData['totalPrice'] ?? 0)),
                  _buildInfoRow(
                    "Trạng thái:",
                    translateStatus(orderData['status']),
                    color: getStatusColor(orderData['status']),
                  ),
                  _buildInfoRow("Thời gian:",
                      formatOrderTime(orderData['orderTime'])),
                  Divider(
                      height: 30, thickness: 1.5, color: Colors.grey.shade300),
                  Text(
                    "Chi tiết đơn hàng:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orderDetails.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade300),
                    itemBuilder: (context, index) {
                      final detail = orderDetails[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5, // Phần tên sản phẩm chiếm 50% độ rộng
                              child: Text(
                                detail['productName'] ??
                                    "Không có tên sản phẩm",
                                style: TextStyle(fontSize: 16),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            SizedBox(
                              width: 50, // Chiều rộng cố định cho số lượng
                              child: Text(
                                "x${detail['quantity']}",
                                style: TextStyle(fontSize: 16),
                                textAlign:
                                    TextAlign.center, // Căn giữa số lượng
                              ),
                            ),
                            Expanded(
                              flex: 2, // Phần giá chiếm 20% độ rộng
                              child: Text(
                                getCurrencyFormat()
                                    .format(detail['subTotal'] ?? 0),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right, // Căn phải giá
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Divider(
                      height: 30, thickness: 1.5, color: Colors.grey.shade300),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Mã QR cho đơn hàng",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.teal, width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: QrImageView(
                            data: _generateQRCodeData(orderData),
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn dòng trên cùng
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black, // Dùng màu được truyền hoặc mặc định màu đen
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }


  String _generateQRCodeData(Map<String, dynamic> orderData) {
    final buffer = StringBuffer();
    buffer.writeln("Mã hóa đơn: ${orderData['orderId']}");
    buffer.writeln(
        "Tổng tiền: ${getCurrencyFormat().format(orderData['totalPrice'] ?? 0)}");
    buffer.writeln("Trạng thái: ${orderData['status']}");
    buffer.writeln("Ngày đặt hàng: ${orderData['orderTime']}");
    buffer.writeln("Chi tiết đơn hàng:");
    for (var detail in orderData['orderDetails'] ?? []) {
      buffer.writeln(
          "- ${detail['productName']} x${detail['quantity']}: ${getCurrencyFormat().format(detail['subTotal'] ?? 0)}");
    }
    return buffer.toString();
  }
}
