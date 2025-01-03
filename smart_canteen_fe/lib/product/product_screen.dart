import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Thêm import
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

  NumberFormat getCurrencyFormat() {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  }

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
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product == null ? "Thêm sản phẩm" : "Chỉnh sửa sản phẩm",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product?['image'] ?? 'https://via.placeholder.com/150',
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Tên sản phẩm",
                    labelStyle: TextStyle(color: Colors.deepOrange),
                    prefixIcon: Icon(Icons.label, color: Colors.deepOrange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Giá (₫)",
                    labelStyle: TextStyle(color: Colors.deepOrange),
                    prefixIcon: Icon(Icons.attach_money, color: Colors.deepOrange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Mô tả",
                    labelStyle: TextStyle(color: Colors.deepOrange),
                    prefixIcon: Icon(Icons.description, color: Colors.deepOrange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Tồn kho",
                    labelStyle: TextStyle(color: Colors.deepOrange),
                    prefixIcon: Icon(Icons.store, color: Colors.deepOrange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: "URL hình ảnh",
                    labelStyle: TextStyle(color: Colors.deepOrange),
                    prefixIcon: Icon(Icons.image, color: Colors.deepOrange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: "Chọn danh mục",
                    labelStyle: TextStyle(color: Colors.deepOrange),
                    prefixIcon: Icon(Icons.category, color: Colors.deepOrange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                  items: categories
                      .map<DropdownMenuItem<int>>(
                        (category) => DropdownMenuItem<int>(
                      value: category['categoryId'],
                      child: Text(category['categoryName']),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Hủy",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedCategoryId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Vui lòng chọn danh mục")),
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
                              SnackBar(content: Text("Lỗi lưu sản phẩm: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(product == null ? "Thêm" : "Lưu"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        SnackBar(content: Text("Lỗi xóa sản phẩm: $e")),
      );
    }
  }

  void _showPopupMenu(
      BuildContext context, dynamic product, GlobalKey itemKey) {
    final RenderBox itemBox =
    itemKey.currentContext!.findRenderObject() as RenderBox;
    final Offset itemPosition = itemBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        itemPosition.dx,
        itemPosition.dy,
        itemPosition.dx + itemBox.size.width,
        itemPosition.dy + itemBox.size.height,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quản lý sản phẩm",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: [
          if (userRole == 'Admin' || userRole == 'admin')
            IconButton(
              onPressed: () => _showProductDialog(),
              icon: Icon(Icons.add),
            ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image, size: 50, color: Colors.grey);
                  },
                ),
              ),
              title: Text(
                product['productName'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    'Giá: ${getCurrencyFormat().format(product['price'] ?? 0)}',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tồn kho: ${product['stock'] ?? 0}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showProductDialog(product: product);
                  } else if (value == 'delete') {
                    _deleteProduct(product['productId']);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit, color: Colors.blue),
                      title: Text('Sửa sản phẩm'),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Xóa sản phẩm'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),



    );
  }

}