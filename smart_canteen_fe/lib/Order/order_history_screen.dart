import 'package:flutter/material.dart';
import 'package:smart_canteen_fe/services/order_service.dart';

import 'order_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;

  const OrderHistoryScreen({required this.userId});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService orderService = OrderService();
  List<dynamic> orderHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    try {
      final data = await orderService.getOrderHistoryByUserId(widget.userId);
      setState(() {
        orderHistory = data;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load order history: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToOrderScreen(BuildContext context, int orderId) async {
    try {
      final orderData = await orderService.getOrderDetailsById(orderId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderScreen(orderData: orderData),
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
      appBar: AppBar(title: Text("Order History")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orderHistory.isEmpty
          ? Center(child: Text("No orders found."))
          : ListView.builder(
        itemCount: orderHistory.length,
        itemBuilder: (context, index) {
          final order = orderHistory[index];
          return ListTile(
            title: Text("Order ID: ${order['orderId']}"),
            subtitle: Text("Total: ${order['totalPrice']}"),
            trailing: Text(order['status']),
            onTap: () => _navigateToOrderScreen(
              context,
              order['orderId'],
            ), // Chuyển hướng đến OrderScreen
          );
        },
      ),
    );
  }
}
