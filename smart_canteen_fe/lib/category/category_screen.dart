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
          title: Text(category == null ? "Add category" : "Edit category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "category Name"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
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
              child: Text(category == null ? "Add" : "Save"),
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
        title: Text("category Management"),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            onTap: () =>
                _navigateToProducts(category['categoryId'], category['categoryName']),
            title: Text(category['categoryName']),
            subtitle: Text(category['description']),
            trailing: userRole == 'admin'
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showCategoryDialog(category: category),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () =>
                      _deleteCategory(category['categoryId']),
                ),
              ],
            )
                : null,
          );
        },
      ),
      floatingActionButton: userRole == 'admin'
          ? FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
