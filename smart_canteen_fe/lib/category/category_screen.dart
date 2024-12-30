import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/category_service.dart';
import '../Product/ProductsByCategoryScreen.dart';

class CategoryManagementScreen extends StatefulWidget {
  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService categoryService = CategoryService();
  List<dynamic> categories = [];
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadUserRole();
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

  void _showCategoryDialog({dynamic category}) {
    final TextEditingController nameController =
    TextEditingController(text: category?['categoryName'] ?? '');
    final TextEditingController descriptionController =
    TextEditingController(text: category?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? "Thêm danh mục" : "Chỉnh sửa danh mục"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Tên danh mục"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Mô tả"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCategory = {
                  'categoryName': nameController.text,
                  'description': descriptionController.text,
                };

                try {
                  if (category == null) {
                    await categoryService.addCategory(newCategory);
                  } else {
                    await categoryService.updateCategory(
                        category['categoryId'], newCategory);
                  }
                  Navigator.pop(context);
                  _loadCategories();
                } catch (e) {
                  print("Error saving category: $e");
                }
              },
              child: Text(category == null ? "Thêm" : "Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(int categoryId) async {
    try {
      await categoryService.deleteCategory(categoryId);
      _loadCategories();
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  void _navigateToProducts(int categoryId, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsByCategoryScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Quản lý danh mục",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.green[50], // Màu nền xanh lá nhạt
        child: ListView.builder(
          itemCount: categories.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              elevation: 2, // Hiệu ứng nổi nhẹ
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green.shade200), // Viền xanh lá
              ),
              child: ListTile(
                onTap: () => _navigateToProducts(
                  category['categoryId'],
                  category['categoryName'],
                ),
                leading: Icon(
                  Icons.category,
                  size: 40,
                  color: Colors.green, // Biểu tượng xanh lá
                ),
                title: Text(
                  category['categoryName'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  category['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700], // Màu chữ mô tả
                  ),
                ),
                trailing: userRole == 'admin'
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () =>
                          _showCategoryDialog(category: category),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deleteCategory(category['categoryId']),
                    ),
                  ],
                )
                    : null,
              ),
            );
          },
        ),
      ),
      floatingActionButton: userRole == 'admin'
          ? FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
