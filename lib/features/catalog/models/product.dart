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
    name: "Teko Keramik Elegan Premium",
    image: [
      "assets/image/t1.jpg",
      "assets/image/t2.jpg",
      "assets/image/t3.jpg",
    ],
    price: 85000,
    rating: 4.8,
    description:
    "Teko keramik dengan desain elegan dan warna pastel yang aesthetic. Cocok untuk menyajikan teh atau minuman hangat dengan tampilan mewah. Material berkualitas, tahan panas, dan mempercantik suasana dapur atau ruang tamu.",
  ),

  Product(
    name: "Mug Keramik Premium Handle Gold",
    image: [
      "assets/image/g1.jpg",
      "assets/image/g2.jpg",
      "assets/image/g3.jpg",
    ],
    price: 45000,
    rating: 4.7,
    description:
    "Mug keramik dengan desain modern dan handle warna emas yang elegan. Cocok untuk kopi, teh, atau minuman favoritmu. Tampilan mewah, nyaman digenggam, dan cocok untuk dekorasi meja.",
  ),

  Product(
    name: "Cangkir Keramik Motif Bunga Set",
    image: [
      "assets/image/gp1.jpg",
      "assets/image/gp2.jpg",
      "assets/image/gp3.jpg",
    ],
    price: 50000,
    rating: 4.6,
    description:
    "Cangkir keramik dengan motif bunga klasik yang elegan, dilengkapi dengan tatakan. Cocok untuk menyajikan teh atau kopi dengan nuansa estetik dan mewah.",
  ),

  Product(
    name: "Mangkok Keramik Canyon Brown",
    image: [
      "assets/image/k1.jpg",
      "assets/image/k2.jpg",
      "assets/image/k3.jpg",
    ],
    price: 40000,
    rating: 4.7,
    description:
    "Mangkok keramik dengan warna canyon brown yang unik dan aesthetic. Cocok untuk menyajikan mie, sup, atau makanan favorit dengan tampilan premium.",
  ),

  Product(
    name: "Mangkok Keramik Motif Aesthetic Set",
    image: [
      "assets/image/m1.jpg",
      "assets/image/m2.jpg",
      "assets/image/m3.jpg",
    ],
    price: 60000,
    rating: 4.8,
    description:
    "Set mangkok keramik dengan berbagai motif elegan dan aesthetic. Cocok untuk kebutuhan makan sehari-hari sekaligus mempercantik tampilan meja makan.",
  ),

  Product(
    name: "Piring Keramik Motif Biru Elegan",
    image: [
      "assets/image/p1.jpg",
      "assets/image/p2.jpg",
      "assets/image/p3.jpg",
    ],
    price: 35000,
    rating: 4.7,
    description:
    "Piring keramik dengan motif biru klasik yang cantik dan elegan. Cocok untuk menyajikan berbagai makanan dengan tampilan lebih menarik dan estetik.",
  ),
];