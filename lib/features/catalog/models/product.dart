class Product {
  final String name;
  final List<String> image;
  final int price;
  final double rating;
  final String description;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.description,
  });
}

List<Product> productList = [
  Product(
    name: "Wajan Anti Lengket Premium",
    image: [
      "assets/image/w1.jpg",
      "assets/image/w2.jpg",
      "assets/image/w3.jpg",
    ],
    price: 65000,
    rating: 4.7,
    description:
    "Wajan anti lengket berkualitas dengan lapisan teflon, cocok untuk masak tanpa lengket. Hemat minyak, mudah dibersihkan, dan awet digunakan sehari-hari.",
  ),

  Product(
    name: "Talenan Dapur Serbaguna",
    image: [
      "assets/image/t1.jpg",
      "assets/image/t2.jpg",
      "assets/image/t3.jpg",
    ],
    price: 18000,
    rating: 4.5,
    description:
    "Talenan praktis dan kuat untuk kebutuhan dapur harian. Aman digunakan untuk sayur, buah, dan daging. Ringan dan mudah dicuci.",
  ),

  Product(
    name: "Pengki & Sapu Kecil Set",
    image: [
      "assets/image/sa1.jpg",
      "assets/image/sa2.jpg",
      "assets/image/sa3.jpg",
    ],
    price: 22000,
    rating: 4.6,
    description:
    "Set sapu kecil dan pengki yang praktis untuk membersihkan debu dan kotoran ringan. Cocok untuk rumah, kamar, dan dapur.",
  ),

  Product(
    name: "Saringan Parabola Stainless",
    image: [
      "assets/image/s1.jpg",
      "assets/image/s2.jpg",
      "assets/image/s3.jpg",
    ],
    price: 28000,
    rating: 4.7,
    description:
    "Saringan stainless anti karat dengan desain parabola, cocok untuk meniriskan gorengan dan mencuci bahan makanan.",
  ),

  Product(
    name: "Rak Sepatu & Sandal Minimalis",
    image: [
      "assets/image/r1.jpg",
      "assets/image/r2.jpg",
      "assets/image/r3.jpg",
    ],
    price: 70000,
    rating: 4.6,
    description:
    "Rak sepatu minimalis hemat tempat, membantu menjaga rumah tetap rapi. Cocok untuk berbagai jenis sepatu dan sandal.",
  ),

  Product(
    name: "Alat Pel Lantai Stainless",
    image: [
      "assets/image/pe1.jpg",
      "assets/image/pe2.jpg",
      "assets/image/pe3.jpg",
    ],
    price: 80000,
    rating: 4.8,
    description:
    "Pel lantai dengan gagang stainless kuat dan tahan karat. Dilengkapi kain microfiber yang menyerap air dengan maksimal.",
  ),

  Product(
    name: "Pisau Dapur Tajam Stainless",
    image: [
      "assets/image/p1.jpg",
      "assets/image/p2.jpg",
      "assets/image/p3.jpg",
    ],
    price: 25000,
    rating: 4.7,
    description:
    "Pisau dapur tajam berbahan stainless steel, cocok untuk memotong sayur, buah, dan daging dengan mudah.",
  ),

  Product(
    name: "Mangkok Warna-Warni Set",
    image: [
      "assets/image/m1.jpg",
      "assets/image/m2.jpg",
      "assets/image/m3.jpg",
    ],
    price: 22000,
    rating: 4.6,
    description:
    "Set mangkok plastik warna-warni yang menarik, ringan dan aman digunakan untuk makanan sehari-hari.",
  ),

  Product(
    name: "Serbet Lap Serbaguna",
    image: [
      "assets/image/l1.jpg",
      "assets/image/l2.jpg",
      "assets/image/l3.jpg",
    ],
    price: 8000,
    rating: 4.5,
    description:
    "Lap serbaguna dengan daya serap tinggi, cocok untuk dapur, meja, dan membersihkan berbagai perabot rumah tangga.",
  ),

  Product(
    name: "Gayung Love Plastik Tebal",
    image: [
      "assets/image/g1.jpg",
      "assets/image/g2.jpg",
      "assets/image/g3.jpg",
    ],
    price: 12000,
    rating: 4.8,
    description:
    "Gayung plastik bentuk hati yang unik dan lucu. Bahan tebal, nyaman digenggam, dan tidak mudah pecah.",
  ),
];