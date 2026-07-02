import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cart_model.dart';
import 'receipt_page.dart';
import 'waiting_payment_page.dart';

class PaymentDetailPage extends StatefulWidget {
  final CartModel cart;

  const PaymentDetailPage({super.key, required this.cart});

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  String _selectedMethod = 'dompet_ku'; // default
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isProcessing = true);

    try {
      final status = _selectedMethod == 'cod' ? 'Berhasil' : 'Menunggu Pembayaran';

      // 1. Simpan order ke Firestore
      final orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'user_id': user.uid,
        'total': widget.cart.totalPrice,
        'items': widget.cart.items.map((item) {
          return {
            'name': item.product.name,
            'price': item.product.price,
            'qty': item.quantity,
            'image': item.product.image[0],
          };
        }).toList(),
        'payment_method': _selectedMethod == 'dompet_ku' ? 'Dompet Ku' : (_selectedMethod == 'cod' ? 'COD' : 'Transfer Bank'),
        'status': status,
        'created_at': FieldValue.serverTimestamp(),
      });

      final orderId = orderRef.id;

      if (_selectedMethod == 'cod') {
        // COD langsung sukses, bersihkan cart & buka ReceiptPage
        widget.cart.clearCart();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiptPage(
                orderId: orderId,
                showBackToHome: true,
              ),
            ),
          );
        }
      } else {
        // Selain COD (Dompet Ku / VA), masuk ke halaman Menunggu Pembayaran
        final total = widget.cart.totalPrice.toDouble();
        // Bersihkan keranjang belanja karena pesanan sudah masuk antrean pending
        widget.cart.clearCart();

        if (_selectedMethod == 'dompet_ku') {
          final deepLink = Uri(
            scheme: 'dompetkampus',
            host: 'pay',
            queryParameters: {
              'merchant_id': 'permata_store',
              'merchant_name': 'Permata Store',
              'amount': total.toString(),
              'description': 'Pembayaran Order $orderId',
              'reference': orderId,
              'callback': 'permatastore://payment-callback',
            },
          );
          if (await canLaunchUrl(deepLink)) {
            await launchUrl(deepLink, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Aplikasi Dompet Ku tidak terinstal. Silakan selesaikan pembayaran.")),
            );
          }
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WaitingPaymentPage(
                orderId: orderId,
                total: total,
                paymentMethod: _selectedMethod == 'dompet_ku' ? 'Dompet Ku' : 'Transfer Bank',
                onPaymentSuccess: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pembayaran")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Metode Pembayaran",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 🟢 DOMPET KU (E-MONEY)
              _buildPaymentMethodTile(
                id: 'dompet_ku',
                title: 'Dompet Ku',
                subtitle: 'Bayar instan pakai saldo Dompet Ku',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
                isRecommended: true,
              ),

              // 🔵 TRANSFER BANK
              _buildPaymentMethodTile(
                id: 'bank_transfer',
                title: 'Transfer Bank (VA)',
                subtitle: 'Mandiri, BCA, BRI, BNI',
                icon: Icons.account_balance,
                color: Colors.blue,
              ),

              // 🟠 COD
              _buildPaymentMethodTile(
                id: 'cod',
                title: 'Bayar di Tempat (COD)',
                subtitle: 'Bayar saat kurir sampai di rumah',
                icon: Icons.local_shipping,
                color: Colors.orange,
              ),

              const SizedBox(height: 24),
              const Text(
                "Ringkasan Belanja",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Ringkasan Harga
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Harga Barang:"),
                          Text("Rp ${widget.cart.totalPrice}"),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Pembayaran:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Rp ${widget.cart.totalPrice}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedMethod == 'dompet_ku' ? Colors.green : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isProcessing ? null : _processPayment,
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Konfirmasi & Bayar",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.04) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Rekomendasi",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedMethod,
              activeColor: color,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMethod = val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
