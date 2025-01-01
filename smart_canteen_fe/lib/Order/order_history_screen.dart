import 'package:flutter/material.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';
import 'package:smart_canteen_fe/services/order_service.dart';
import '../../config_url/config.dart';
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
  late HubConnection _hubConnection;
  final String baseUrl = "${Config.apiBaseUrl}";

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
    _initializeSignalR();
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

  void _initializeSignalR() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      '$baseUrl/notificationHub',
      options: HttpConnectionOptions(
        transport: HttpTransportType.WebSockets,
        skipNegotiation: true,
      ),
    )
        .withAutomaticReconnect()
        .build();

    _hubConnection.on("OrderStatusUpdated", (arguments) {
      final orderId = arguments?[0];
      final status = arguments?[1];

      if (status == "Completed") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCustomNotification(context, "Order $orderId has been completed!");
        });

        _loadOrderHistory();
      }
    });

    try {
      await _hubConnection.start();
      print("SignalR connection established");
    } catch (error) {
      print("SignalR connection error: $error");
    }
  }

  void _showCustomNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      overlayEntry.remove();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
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
  void dispose() {
    _hubConnection.stop();
    super.dispose();
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
            ),
          );
        },
      ),
    );
  }
}