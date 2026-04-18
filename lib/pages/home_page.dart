import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'cart_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    HomeContent(),
    CartPage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorite"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ================= HOME CONTENT =================

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String selectedCategory = "Semua";
  TextEditingController searchController = TextEditingController();
  PageController _pageController = PageController();
  int currentPage = 0;
  Timer? _timer;

  // 🔥 FILTER PRODUK
  List<Product> getFilteredProducts() {
    final keyword = searchController.text.toLowerCase();

    return productList.where((product) {
      final name = product.name.toLowerCase();

      bool matchCategory = true;

      if (selectedCategory == "Dapur") {
        matchCategory = name.contains("wajan") ||
            name.contains("talenan") ||
            name.contains("pisau") ||
            name.contains("mangkok") ||
            name.contains("saringan");
      } else if (selectedCategory == "Cleaning") {
        matchCategory = name.contains("pel") ||
            name.contains("sapu") ||
            name.contains("pengki");
      } else if (selectedCategory == "Storage") {
        matchCategory = name.contains("rak");
      } else if (selectedCategory == "Essentials") {
        matchCategory = name.contains("gayung") ||
            name.contains("serbet");
      }

      final matchSearch = name.contains(keyword);

      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        currentPage++;

        if (currentPage > 2) currentPage = 0;

        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text("PERMATA SHOP"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartPage()),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Cari perabotan rumah tangga...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            // 🎴 BANNER
            SizedBox(
              height: 160,
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
                      children: [
                        buildBanner("assets/image/banner1.jpg", "Promo Perabotan Dapur"),
                        buildBanner("assets/image/banner2.jpg", "Diskon Alat Kebersihan"),
                        buildBanner("assets/image/banner3.jpg", "Perlengkapan Rumah Terbaru"),
                      ],
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

            SizedBox(height: 10),

            // 🏷️ KATEGORI
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 10),
                children: [
                  buildCategory("Semua"),
                  buildCategory("Dapur"),
                  buildCategory("Cleaning"),
                  buildCategory("Storage"),
                  buildCategory("Essentials"),
                ],
              ),
            ),

            SizedBox(height: 10),

            // 🛍️ PRODUK
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORY =================

  Widget buildCategory(String category) {
    final isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ================= BANNER =================

  Widget buildBanner(String imagePath, String title) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black.withOpacity(0.4),
        ),
        padding: EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}