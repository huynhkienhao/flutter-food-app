import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService productService = ProductService();
  final CategoryService categoryService = CategoryService();

  List<dynamic> products = [];
  List<dynamic> categories = [];
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
    _loadUserRole();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await productService.getProducts();
      setState(() {
        products = data;
      });
    } catch (e) {
      print("Error loading products: $e");
    }
  }

  Future<void> _loadCategories() async {
    try {
      final data = await categoryService.getCategories();
      setState(() {
        categories = data;
      });
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("user_role");
    });
  }

  void _showProductDialog({dynamic product}) {
    final TextEditingController nameController =
    TextEditingController(text: product?['productName'] ?? '');
    final TextEditingController priceController =
    TextEditingController(text: product?['price']?.toString() ?? '');
    final TextEditingController descriptionController =
    TextEditingController(text: product?['description'] ?? '');
    final TextEditingController stockController =
    TextEditingController(text: product?['stock']?.toString() ?? '');
    final TextEditingController imageController =
    TextEditingController(text: product?['image'] ?? '');
    int? selectedCategoryId = product?['categoryId'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? "Add product" : "Edit product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "product Name"),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(labelText: "Stock"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(labelText: "Image URL"),
                ),
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(labelText: "Select category"),
                  items: categories
                      .map<DropdownMenuItem<int>>(
                          (category) => DropdownMenuItem<int>(
                        value: category['categoryId'],
                        child: Text(category['categoryName']),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select a category")),
                  );
                  return;
                }

                final newProduct = {
                  'productName': nameController.text,
                  'price': double.parse(priceController.text),
                  'description': descriptionController.text,
                  'image': imageController.text,
                  'stock': int.parse(stockController.text),
                  'categoryId': selectedCategoryId,
                };

                try {
                  if (product == null) {
                    await productService.addProduct(newProduct);
                  } else {
                    await productService.updateProduct(
                        product['productId'], newProduct);
                  }
                  _loadProducts();
                  Navigator.pop(context);
                } catch (e) {
                  print("Error saving product: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error saving product: $e")),
                  );
                }
              },
              child: Text(product == null ? "Add" : "Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(int productId) async {
    try {
      await productService.deleteProduct(productId);
      _loadProducts();
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting product: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("product Management"),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['productName']),
            subtitle: Text('Price: \$${product['price']}'),
            trailing: userRole == 'admin'
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showProductDialog(product: product),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteProduct(product['productId']),
                ),
              ],
            )
                : null,
          );
        },
      ),
      floatingActionButton: userRole == 'admin'
          ? FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
