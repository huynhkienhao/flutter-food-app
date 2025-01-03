import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../services/category_service.dart';
import '../../services/favorite_service.dart';
import '../Cart/cart_screen.dart';
import '../Favorite/favorite_screen.dart';
import 'package:intl/intl.dart';

import '../product/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();
  final CartService cartService = CartService();
  final CategoryService categoryService = CategoryService();
  final FavoriteService favoriteService = FavoriteService();

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

  Future<void> _loadProducts({int? categoryId}) async {
    setState(() => isLoading = true);
    try {
      final data = categoryId == null
          ? await productService.getProducts()
          : await productService.getProductsByCategory(categoryId);

      // Lấy danh sách sản phẩm yêu thích
      final favorites = await favoriteService.getFavorites();
      final favoriteProductIds = favorites.map((item) => item['productId']).toSet();

      setState(() {
        products = data?.map((product) {
          product['isFavorite'] = favoriteProductIds.contains(product['productId']);
          return product;
        }).toList() ?? [];
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

  Future<void> _loadCategories() async {
    setState(() => isCategoryLoading = true);
    try {
      final data = await categoryService.getCategories();
      setState(() {
        categories = data;
        isCategoryLoading = false;
      });
    } catch (e) {
      print("Error loading categories: $e");
      setState(() => isCategoryLoading = false);
    }
  }

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

  Future<void> _toggleFavorite(int productId) async {
    try {
      final productIndex = products.indexWhere((product) => product['productId'] == productId);

      if (productIndex != -1) {
        final isCurrentlyFavorite = products[productIndex]['isFavorite'] ?? false;
        if (isCurrentlyFavorite) {
          // Xóa khỏi danh sách yêu thích
          final favorites = await favoriteService.getFavorites();
          final favoriteItem = favorites.firstWhere(
                  (item) => item['productId'] == productId,
              orElse: () => null);
          if (favoriteItem != null) {
            await favoriteService.removeFromFavorite(favoriteItem['favoriteId']);
          }
        } else {
          // Thêm vào danh sách yêu thích
          await favoriteService.addToFavorite(productId);
        }

        // Cập nhật trạng thái sản phẩm
        setState(() {
          products[productIndex]['isFavorite'] = !isCurrentlyFavorite;
          filteredProducts = List.from(products);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyFavorite
                  ? "Đã xóa khỏi danh sách yêu thích!"
                  : "Đã thêm vào danh sách yêu thích!",
            ),
          ),
        );
      }
    } catch (e) {
      print("Error toggling favorite: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể cập nhật trạng thái yêu thích.")),
      );
    }
  }

  void _navigateToProductDetail(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: productId),
      ),
    ).then((_) {
      _loadProducts();
    });
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
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen(
                    navigateToPage: (pageIndex) {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  product['image'] ??
                                      'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 50);
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
                                    product['productName'] ?? "Không có tên",
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _toggleFavorite(product['productId']),
                            child: Icon(
                              product['isFavorite'] == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 24,
                            ),
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
