import 'package:flutter/material.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartModel extends ChangeNotifier {
  List<CartItem> items = [];

  // ➕ Tambah ke cart
  void addToCart(Product product) {
    final index =
    items.indexWhere((item) => item.product.name == product.name);

    if (index != -1) {
      items[index].quantity++;
    } else {
      items.add(CartItem(product: product));
    }

    notifyListeners();
  }

  // 🔼 Tambah qty
  void increaseQty(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  // 🔽 Kurangi qty
  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      items.remove(item);
    }
    notifyListeners();
  }

  // 💰 Total harga
  int get totalPrice {
    int total = 0;
    for (var item in items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  // 🔥 FIX UTAMA (INI YANG BIKIN ERROR HILANG)
  void clearCart() {
    items = [];
    notifyListeners();
  }
}