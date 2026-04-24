import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoriteModel extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  void toggleFavorite(Product product) {
    if (_items.contains(product)) {
      _items.remove(product);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return _items.contains(product);
  }
}