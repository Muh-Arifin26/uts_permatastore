import 'package:flutter/material.dart';
import '../../catalog/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalPrice {
    return _items.fold(
      0,
          (sum, item) => sum + (item.product.price * item.quantity),
    );
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
  }

  // 🔥 TAMBAH QTY
  void increaseQty(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  // 🔥 KURANG QTY (AUTO HAPUS)
  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item); // 🔥 AUTO HAPUS
    }
    notifyListeners();
  }

  // 🔥 HAPUS ITEM MANUAL
  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  // 🔥 CLEAR CART
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}