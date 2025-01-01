import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../product/product_detail_screen.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService = ProductService();
  final CartService cartService = CartService();
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');


  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await productService.getProducts();
      setState(() {
        products = data ?? [];
        filteredProducts = products; // Hiển thị tất cả sản phẩm ban đầu
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

  // Điều hướng đến trang chi tiết sản phẩm
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
    return Column(
      children: [
        // Thanh tìm kiếm
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Tìm kiếm sản phẩm...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: _filterProducts, // Gọi hàm lọc khi nhập từ khóa
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
                  _navigateToProductDetail(product['productId']); // Chuyển đến trang chi tiết sản phẩm
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hiển thị hình ảnh sản phẩm
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            product['image'] ?? 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 50);
                            },
                          ),
                        ),
                      ),
                      // Hiển thị thông tin sản phẩm
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
