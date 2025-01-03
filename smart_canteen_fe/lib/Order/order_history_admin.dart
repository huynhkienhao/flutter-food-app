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
      final data = await orderService.getAllOrderHistories(); // Fetch all orders
      setState(() {
        orderHistories = data;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load order histories: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(BuildContext context, int orderId) async {
    try {
      await orderService.updateOrderStatus(orderId, "Completed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order status updated to Completed")),
      );
      _loadAllOrderHistories(); // Reload order histories
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update order status: $e")),
      );
    }
  }

  void _navigateToOrderScreen(BuildContext context, int orderId) async {
    try {
      final orderData = await orderService.getOrderDetailsById(orderId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminOrderScreen(orderData: orderData), // Sử dụng AdminOrderScreen từ đoạn code 1
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load order details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Order Histories")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orderHistories.isEmpty
          ? Center(child: Text("No orders found."))
          : ListView.builder(
        itemCount: orderHistories.length,
        itemBuilder: (context, index) {
          final order = orderHistories[index];
          return ListTile(
            title: Text("Order ID: ${order['orderId']}"),
            subtitle: Text(
              "User ID: ${order['userId']} | Total: ${getCurrencyFormat().format(order['totalPrice'] ?? 0)}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(order['status']),
                if (order['status'] == "Pending")
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _updateOrderStatus(
                      context,
                      order['orderId'],
                    ),
                  ),
              ],
            ),
            onTap: () => _navigateToOrderScreen(
              context,
              order['orderId'],
            ),
          );
        },
      ),
    );
  }
}
