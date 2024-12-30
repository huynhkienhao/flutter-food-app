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
    // Dialog logic here
  }

  void _deleteProduct(int productId) async {
    try {
      await productService.deleteProduct(productId);
      _loadProducts();
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi xóa sản phẩm: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quản lý sản phẩm",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final GlobalKey itemKey = GlobalKey();

          return GestureDetector(
            key: itemKey,
            onLongPress: () => _showPopupMenu(context, product, itemKey),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product['image'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image,
                              size: 50, color: Colors.grey);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['productName'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Giá: \$${product['price']}',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: userRole == 'admin'
          ? FloatingActionButton(
              onPressed: () => _showProductDialog(),
              backgroundColor: Colors.green,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  void _showPopupMenu(
      BuildContext context, dynamic product, GlobalKey itemKey) {
    final RenderBox itemBox =
        itemKey.currentContext!.findRenderObject() as RenderBox;
    final Offset itemPosition = itemBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        itemPosition.dx, // Vị trí x của Card
        itemPosition.dy, // Vị trí y của Card
        itemPosition.dx + itemBox.size.width, // Chiều rộng của Card
        itemPosition.dy + itemBox.size.height, // Chiều cao của Card
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit, color: Colors.blue),
            title: Text('Sửa sản phẩm'),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Xóa sản phẩm'),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _showProductDialog(product: product);
      } else if (value == 'delete') {
        _deleteProduct(product['productId']);
      }
    });
  }
}
