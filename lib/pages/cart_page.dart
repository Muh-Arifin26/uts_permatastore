import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';
import 'success_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // 🔥 CHECKOUT FUNCTION
  Future<void> checkout(BuildContext context) async {
    final cart = Provider.of<CartModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login dulu")),
      );
      return;
    }

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Keranjang kosong")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'user_id': user.uid,
        'total': cart.totalPrice,
        'items': cart.items.map((item) {
          return {
            'name': item.product.name,
            'price': item.product.price,
            'qty': item.quantity,
            'image': item.product.image[0],
          };
        }).toList(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // 🔥 CLEAR CART
      cart.clearCart();

      // 🔥 LANGSUNG KE SUCCESS PAGE (TANPA POPUP)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SuccessPage(),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang")),

      body: cart.items.isEmpty
          ? const Center(child: Text("Keranjang kosong"))
          : ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),

              // 🖼️ GAMBAR
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    item.product.image[0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 📦 NAMA
              title: Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              // 💰 HARGA
              subtitle: Text("Rp ${item.product.price}"),

              // 🔢 QTY
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      cart.decreaseQty(item);
                    },
                  ),
                  Text(item.quantity.toString()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      cart.increaseQty(item);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // 💰 TOTAL + CHECKOUT
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Total: Rp ${cart.totalPrice}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  checkout(context);
                },
                child: const Text("Checkout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}