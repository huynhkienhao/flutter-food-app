import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/cart_service.dart';
import '../../services/product_service.dart';
import '../cart/cart_screen.dart';

class ProductsByCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  ProductsByCategoryScreen({required this.categoryId, required this.categoryName});

  @override
  _ProductsByCategoryScreenState createState() =>
      _ProductsByCategoryScreenState();
}

class _ProductsByCategoryScreenState extends State<ProductsByCategoryScreen> {
  final ProductService productService = ProductService();
  final CartService cartService = CartService();
  List<dynamic> products = [];
  bool isLoading = true;

  void _addToCart(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("user not logged in.")),
      );
      return;
    }

    try {
      await cartService.addToCart(userId, productId, 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("product added to cart.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add product to cart.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await productService.getProductsByCategory(
          widget.categoryId);
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products in ${widget.categoryName}"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['productName']),
            subtitle: Text('Price: \$${product['price']}'),
            trailing: ElevatedButton(
              onPressed: () => _addToCart(product['productId']),
              child: Text("Add to Cart"),
            ),
          );
        },
      ),
    );
  }
}
