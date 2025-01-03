import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Định dạng tiền tệ
import '../services/favorite_service.dart';

class FavoriteScreen extends StatefulWidget {
  final void Function(int index)? navigateToPage;

  const FavoriteScreen({Key? key, this.navigateToPage}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  late Future<List<dynamic>> _favoriteItems;

  // Định dạng tiền tệ
  final NumberFormat currencyFormat =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _favoriteItems = _fetchUniqueFavorites();
  }

  /// Lấy danh sách yêu thích và loại bỏ trùng lặp
  Future<List<dynamic>> _fetchUniqueFavorites() async {
    try {
      final favorites = await _favoriteService.getFavorites();
      final Set<int> seenProductIds = {}; // Set lưu trữ các productId đã gặp
      final uniqueFavorites = <dynamic>[];

      for (var item in favorites) {
        final productId = item['productId'];
        if (!seenProductIds.contains(productId)) {
          seenProductIds.add(productId); // Đánh dấu productId đã gặp
          uniqueFavorites.add(item);
        }
      }

      return uniqueFavorites;
    } catch (e) {
      print("Error fetching favorites: $e");
      return [];
    }
  }

  void _loadFavorites() {
    setState(() {
      _favoriteItems = _fetchUniqueFavorites();
    });
  }

  void _removeFavorite(int favoriteId) async {
    try {
      await _favoriteService.removeFromFavorite(favoriteId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa khỏi danh sách yêu thích")),
      );
      _loadFavorites(); // Tải lại danh sách sau khi xóa
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách yêu thích"),
        leading: widget.navigateToPage != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.navigateToPage!(0),
        )
            : null,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _favoriteItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Danh sách yêu thích trống."));
          } else {
            final favorites = snapshot.data!;
            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Dismissible(
                  key: Key(item['favoriteId'].toString()), // Unique key
                  direction: DismissDirection.endToStart, // Quét từ phải qua trái
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _removeFavorite(item['favoriteId']);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: item['productImage'] != null
                          ? Image.network(
                        item['productImage'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.favorite,
                          size: 50, color: Colors.red),
                      title: Text(item['productName'] ?? "Không có tên"),
                      subtitle: Text(
                        "Giá: ${currencyFormat.format(item['productPrice'] ?? 0)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
