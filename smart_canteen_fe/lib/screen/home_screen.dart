import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../services/category_service.dart';
import '../Cart/cart_screen.dart';
import '../product/product_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();
  final CartService cartService = CartService();
  final CategoryService categoryService = CategoryService();

  final NumberFormat currencyFormat =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  List<dynamic> categories = [];
  String? selectedCategory;

  bool isLoading = true;
  bool isCategoryLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  // Hàm để tải sản phẩm theo danh mục
  Future<void> _loadProducts({int? categoryId}) async {
    setState(() => isLoading = true);
    try {
      final data = categoryId == null
          ? await productService.getProducts() // Gọi API lấy sản phẩm
          : await productService.getProductsByCategory(categoryId);

      setState(() {
        products = data ?? [];
        filteredProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading products: $e");
      setState(() {
        products = [];
        filteredProducts = [];
        isLoading = false;
      });
    }
  }

  // Hàm để tải danh mục từ API
  Future<void> _loadCategories() async {
    setState(() => isCategoryLoading = true);
    try {
      final data = await categoryService.getCategories(); // Gọi API lấy danh mục

      categories = data;

      setState(() {
        isCategoryLoading = false;
      });
    } catch (e) {
      print("Error loading categories: $e");
      setState(() => isCategoryLoading = false);
    }
  }

  // Hàm lọc sản phẩm theo từ khóa
  void _filterProducts(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) => product['productName']
            .toString()
            .toLowerCase()
            .contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  // Chuyển tới trang chi tiết sản phẩm
  void _navigateToProductDetail(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: GestureDetector(
          onTap: () {},
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.search, color: Colors.grey),
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm sản phẩm...",
                      hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 14),
                    onChanged: _filterProducts,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Hiển thị danh mục mà không có biểu tượng
          isCategoryLoading
              ? LinearProgressIndicator()
              : Container(
            height: 100,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      selectedCategory == category['categoryName'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category['categoryName'];
                      });
                      _loadProducts(categoryId: category['categoryId']);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.orange.shade100
                                : Colors.grey.shade200,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.fastfood, // Không dùng biểu tượng riêng
                            size: 40,
                            color: isSelected ? Colors.orange : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          category['categoryName'] ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.orange
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Danh sách sản phẩm
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                ? Center(
              child: Text(
                "Không tìm thấy sản phẩm nào.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    _navigateToProductDetail(product['productId']);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              product['image'] ??
                                  'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Icon(Icons.broken_image,
                                    size: 50);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['productName'] ??
                                    "Không có tên",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Giá: ${currencyFormat.format(product['price'] ?? 0)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
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
          ),
        ],
      ),
    );
  }
}
