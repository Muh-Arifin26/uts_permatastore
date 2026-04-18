import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/favorite_model.dart';
import '../pages/detail_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 GAMBAR + FAVORITE ICON
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.asset(
                      product.image[0],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    ),
                  ),

                  // ❤️ FAVORITE ICON (POJOK KANAN ATAS)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<FavoriteModel>(
                      builder: (context, favorite, child) {
                        final isFav = favorite.isFavorite(product);

                        return GestureDetector(
                          onTap: () {
                            favorite.toggleFavorite(product);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFav
                                      ? "Dihapus dari favorit"
                                      : "Ditambahkan ke favorit",
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 📦 NAMA PRODUK
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // 💰 HARGA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Rp ${product.price}",
                style: TextStyle(color: Colors.blue),
              ),
            ),

            // ⭐ RATING
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text(product.rating.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}