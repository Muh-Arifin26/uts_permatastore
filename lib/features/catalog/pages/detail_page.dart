import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../../cart/models/cart_model.dart';
import 'store_page.dart';

class DetailPage extends StatefulWidget {
  final Product product;

  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  PageController _pageController = PageController();
  int currentPage = 0;
  double userRating = 0;

  // 🔥 STORE NAME
  // 🔥 STORE NAME (SUDAH SESUAI PERABOTAN)
  String getStoreName(String name) {
    if (name.contains("Wajan") || name.contains("Talenan") || name.contains("Pisau")) {
      return "PERMATA Dapur";
    }
    if (name.contains("Pel") || name.contains("Sapu") || name.contains("Pengki")) {
      return "PERMATA Cleaning";
    }
    if (name.contains("Rak")) {
      return "PERMATA Storage";
    }
    if (name.contains("Gayung") || name.contains("Serbet")) {
      return "PERMATA Essentials";
    }
    if (name.contains("Mangkok") || name.contains("Saringan")) {
      return "PERMATA Kitchenware";
    }

    return "PERMATA SHOP";
  }

// 🔥 STORE DESC (LEBIH REALISTIS)
  String getStoreDescription(String name) {
    return "PERMATA (Perabotan Rumah Tangga) menyediakan berbagai kebutuhan rumah tangga berkualitas dengan harga terjangkau.";
  }

  @override
  void dispose() {
    _pageController.dispose(); // ✅ sekarang benar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text("Detail Produk")),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔥 SLIDER GAMBAR
                  SizedBox(
                    height: 250,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                currentPage = index;
                              });
                            },
                            children: product.image.map((img) {
                              return Image.asset(
                                img,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            }).toList(),
                          ),
                        ),

                        SizedBox(height: 5),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              width: currentPage == index ? 10 : 6,
                              height: currentPage == index ? 10 : 6,
                              decoration: BoxDecoration(
                                color: currentPage == index
                                    ? Colors.orange
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // 📦 NAMA
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      product.name,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // 💰 HARGA
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Rp ${product.price}",
                      style:
                      TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                  ),

                  SizedBox(height: 10),

                  // ⭐ RATING
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  userRating = index + 1.0;
                                });
                              },
                              child: Icon(
                                Icons.star,
                                size: 22,
                                color: (index < userRating)
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                            );
                          }),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "${product.rating} (120 reviews)",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // 🧾 DESKRIPSI
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(product.description),
                  ),

                  Divider(),

                  // 🏪 TOKO
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Toko Penjual",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StorePage(
                            storeName: getStoreName(product.name),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.store),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getStoreName(product.name),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  getStoreDescription(product.name),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 🔥 BUTTON
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      Provider.of<CartModel>(context, listen: false)
                          .addToCart(product);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                            Text("Ditambahkan ke keranjang")),
                      );
                    },
                    child: Text("Add to Cart"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      Provider.of<CartModel>(context, listen: false)
                          .addToCart(product);

                      Navigator.pushNamed(context, '/cart');
                    },
                    child: Text("Checkout Now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}