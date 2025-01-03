import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_canteen_fe/Order/AdminOrderScreen.dart';
import 'package:smart_canteen_fe/services/order_service.dart';

class OrderHistoryAdminScreen extends StatefulWidget {
  @override
  _OrderHistoryAdminScreenState createState() =>
      _OrderHistoryAdminScreenState();
}

class _OrderHistoryAdminScreenState extends State<OrderHistoryAdminScreen> {
  final OrderService orderService = OrderService();
  List<dynamic> orderHistories = [];
  bool isLoading = true;

  NumberFormat getCurrencyFormat() {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  }

  @override
  void initState() {
    super.initState();
    _loadAllOrderHistories();
  }

  Future<void> _loadAllOrderHistories() async {
    try {
      setState(() {
        isLoading = true; // Hiển thị loading trước khi gọi API
      });

      final data = await orderService.getAllOrderHistories();

      // Kiểm tra nếu API trả về null hoặc danh sách trống
      if (data == null || data.isEmpty) {
        throw Exception("Không có dữ liệu đơn hàng.");
      }

      setState(() {
        orderHistories = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        orderHistories = []; // Đặt danh sách về rỗng nếu có lỗi
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải lịch sử đơn hàng: $e")),
      );
    }
  }

  Future<void> _updateOrderStatus(BuildContext context, int orderId) async {
    try {
      setState(() {
        isLoading = true; // Hiển thị loading khi cập nhật trạng thái
      });

      await orderService.updateOrderStatus(orderId, "Completed");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trạng thái đơn hàng đã cập nhật thành Hoàn tất")),
      );

      await _loadAllOrderHistories(); // Tải lại danh sách đơn hàng sau khi cập nhật
    } catch (e) {
      setState(() {
        isLoading = false; // Tắt loading nếu có lỗi
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể cập nhật trạng thái đơn hàng: $e")),
      );
    }
  }

  void _navigateToOrderScreen(BuildContext context, int orderId) async {
    try {
      final orderData = await orderService.getOrderDetailsById(orderId);

      if (orderData == null) {
        throw Exception("Không tìm thấy chi tiết đơn hàng.");
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminOrderScreen(orderData: orderData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải chi tiết đơn hàng: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lịch sử đơn hàng"),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orderHistories.isEmpty
          ? Center(
        child: Text(
          "Không có đơn hàng nào.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: orderHistories.length,
        itemBuilder: (context, index) {
          final order = orderHistories[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(
                "Mã đơn hàng: ${order['orderId']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.0),
                  Text(
                    "Mã khách hàng: ${order['userId']}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "Tổng cộng: ${getCurrencyFormat().format(order['totalPrice'] ?? 0)}",
                    style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "Trạng thái: ${order['status']}",
                    style: TextStyle(
                      color: order['status'] == "Pending"
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              trailing: order['status'] == "Pending"
                  ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: Icon(Icons.check_circle),
                label: Text("Hoàn tất"),
                onPressed: () =>
                    _updateOrderStatus(context, order['orderId']),
              )
                  : Icon(Icons.done_all, color: Colors.green),
              onTap: () =>
                  _navigateToOrderScreen(context, order['orderId']),
            ),
          );
        },
      ),
    );
  }
}