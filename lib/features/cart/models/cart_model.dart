import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../catalog/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartItem> get items => _items;

  CartModel() {
    // 🔥 Otomatis load cart saat user login, dan bersihkan saat logout
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadCartFromFirestore(user.uid);
      } else {
        _items.clear();
        notifyListeners();
      }
    });
  }

  int get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  // 🔥 LOAD DARI FIRESTORE
  Future<void> _loadCartFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('carts').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          final List<dynamic> itemsData = data['items'];
          _items.clear();
          for (var itemMap in itemsData) {
            final productName = itemMap['name'];
            final qty = itemMap['qty'] ?? 1;
            
            // Cari produk asli di productList untuk mempertahankan data lengkap
            final product = productList.firstWhere(
              (p) => p.name == productName,
              orElse: () => Product(
                name: productName,
                image: List<String>.from(itemMap['image'] ?? []),
                price: itemMap['price'] ?? 0,
                rating: 4.5,
                description: '',
              ),
            );
            _items.add(CartItem(product: product, quantity: qty));
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }

  // 🔥 SYNC KE FIRESTORE
  Future<void> _syncToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (_items.isEmpty) {
        // Jika keranjang kosong, hapus doc agar hemat storage
        await _firestore.collection('carts').doc(user.uid).delete();
      } else {
        await _firestore.collection('carts').doc(user.uid).set({
          'items': _items.map((item) => {
            'name': item.product.name,
            'price': item.product.price,
            'qty': item.quantity,
            'image': item.product.image,
          }).toList(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Error syncing cart: $e");
    }
  }

  // 🔥 TAMBAH KE CART
  void addToCart(Product product) {
    final index =
        _items.indexWhere((item) => item.product.name == product.name);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }

    notifyListeners();
    _syncToFirestore(); // 🔥 Sync ke Firestore
  }

  // 🔥 TAMBAH QTY
  void increaseQty(CartItem item) {
    item.quantity++;
    notifyListeners();
    _syncToFirestore(); // 🔥 Sync ke Firestore
  }

  // 🔥 KURANG QTY (AUTO HAPUS)
  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item); // 🔥 AUTO HAPUS
    }
    notifyListeners();
    _syncToFirestore(); // 🔥 Sync ke Firestore
  }

  // 🔥 HAPUS ITEM MANUAL
  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
    _syncToFirestore(); // 🔥 Sync ke Firestore
  }

  // 🔥 CLEAR CART
  void clearCart() {
    _items.clear();
    notifyListeners();
    _syncToFirestore(); // 🔥 Sync ke Firestore
  }
}