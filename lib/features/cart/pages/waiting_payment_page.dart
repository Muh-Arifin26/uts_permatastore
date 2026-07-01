import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'success_page.dart';
import '../../profile/pages/my_orders_page.dart';

class WaitingPaymentPage extends StatefulWidget {
  final String orderId;
  final double total;
  final String paymentMethod;
  final VoidCallback onPaymentSuccess;

  const WaitingPaymentPage({
    super.key,
    required this.orderId,
    required this.total,
    required this.paymentMethod,
    required this.onPaymentSuccess,
  });

  @override
  State<WaitingPaymentPage> createState() => _WaitingPaymentPageState();
}

class _WaitingPaymentPageState extends State<WaitingPaymentPage> {
  bool _isChecking = false;

  Future<void> _checkPayment() async {
    setState(() => _isChecking = true);
    
    // Tunggu sebentar untuk simulasi loading pengecekan
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Ambil dokumen order terbaru dari Firestore
      final doc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      final currentStatus = doc.data()?['status'] ?? 'Menunggu Pembayaran';

      if (currentStatus == 'Berhasil') {
        widget.onPaymentSuccess();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SuccessPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pembayaran belum masuk. Silakan selesaikan pembayaran di aplikasi Dompet Ku terlebih dahulu."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memeriksa status: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menunggu Pembayaran"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_empty_rounded,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                "Menunggu Pembayaran",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Silakan selesaikan pembayaran Anda melalui ${widget.paymentMethod}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("ID Pesanan:"),
                          Text(
                            widget.orderId,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Tagihan:"),
                          Text(
                            "Rp ${widget.total}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isChecking ? null : _checkPayment,
                  child: _isChecking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Refresh Status Pembayaran",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                    );
                  },
                  child: const Text(
                    "Lihat History Pembayaran",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
