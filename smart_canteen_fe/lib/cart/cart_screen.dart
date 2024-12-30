import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cartService = CartService();
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("user not logged in.")),
      );
      return;
    }

    try {
      final data = await cartService.getCartItems(userId);
      setState(() {
        cartItems = data;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load cart items.")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeItem(int cartId) async {
    try {
      await cartService.removeFromCart(cartId);
      _loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove item.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            title: Text(item['productName']),
            subtitle: Text("Quantity: ${item['quantity']}"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeItem(item['cartId']),
            ),
          );
        },
      ),
    );
  }
}
