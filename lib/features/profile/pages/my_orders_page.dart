import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../cart/pages/waiting_payment_page.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Pesanan Saya")),
        body: const Center(child: Text("Silakan login terlebih dahulu")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Pesanan Saya")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('user_id', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);

          // 🔥 Urutkan secara lokal di memori agar tidak perlu membuat Index di Firebase Console
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['created_at'] as Timestamp?;
            final bTime = bData['created_at'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // descending (terbaru di atas)
          });

          if (docs.isEmpty) {
            return const Center(child: Text("Anda belum memiliki pesanan"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['created_at'] as Timestamp?)?.toDate();
              final formattedDate = date != null
                  ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}"
                  : '-';
              final total = data['total'] ?? 0;
              final items = data['items'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            data['status'] ?? 'Berhasil',
                            style: TextStyle(
                              color: (data['status'] ?? 'Berhasil') == 'Berhasil' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ...items.map((item) {
                        final name = item['name'] ?? '';
                        final price = item['price'] ?? 0;
                        final qty = item['qty'] ?? 1;
                        final image = item['image'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  image,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image,
                                      size: 40),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Rp $price x $qty",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Pembayaran:"),
                          Text(
                            "Rp $total",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      if ((data['status'] ?? 'Berhasil') == 'Menunggu Pembayaran') ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () async {
                                final orderId = docs[index].id;
                                final paymentMethod = data['payment_method'] ?? 'Dompet Ku';
                                if (paymentMethod == 'Dompet Ku') {
                                  final deepLink = Uri.parse(
                                    "dompetkampus://pay?merchant_id=permata_store&merchant_name=Permata%20Store&amount=$total&description=Pembayaran%20Order%20$orderId&reference=$orderId&callback=permatastore://payment-callback"
                                  );
                                  if (await canLaunchUrl(deepLink)) {
                                    await launchUrl(deepLink, mode: LaunchMode.externalApplication);
                                  }
                                }
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WaitingPaymentPage(
                                        orderId: orderId,
                                        total: total.toDouble(),
                                        paymentMethod: paymentMethod,
                                        onPaymentSuccess: () {},
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
