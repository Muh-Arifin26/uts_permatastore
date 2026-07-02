import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptPage extends StatelessWidget {
  final String orderId;
  final bool showBackToHome;

  const ReceiptPage({
    super.key,
    required this.orderId,
    this.showBackToHome = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Struk Pembayaran"),
        centerTitle: true,
        automaticallyImplyLeading: !showBackToHome,
        leading: showBackToHome
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (route) => false);
                },
              )
            : null,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text("Gagal memuat struk"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Kembali"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final date = (data['created_at'] as Timestamp?)?.toDate();
          final items = data['items'] as List<dynamic>? ?? [];
          final total = data['total'] ?? 0;
          final paymentMethod = data['payment_method'] ?? '-';
          final status = data['status'] ?? 'Berhasil';
          final transactionId = data['transaction_id'] as String?;

          final formattedDate = date != null
              ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}"
              : '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ─── Receipt Card ────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ─── Header ────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: status == 'Berhasil'
                                ? [
                                    const Color(0xFF4CAF50),
                                    const Color(0xFF2E7D32),
                                  ]
                                : [Colors.orange, Colors.deepOrange],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              status == 'Berhasil'
                                  ? Icons.check_circle
                                  : Icons.hourglass_top,
                              color: Colors.white,
                              size: 56,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              status == 'Berhasil'
                                  ? "Pembayaran Berhasil"
                                  : "Menunggu Pembayaran",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ─── Dashed Divider ────────────
                      _DashedDivider(),

                      // ─── Order Info ────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Column(
                          children: [
                            _InfoRow(
                              label: "No. Pesanan",
                              value: orderId.length > 12
                                  ? '${orderId.substring(0, 12)}...'
                                  : orderId,
                            ),
                            if (transactionId != null)
                              _InfoRow(
                                label: "ID Transaksi",
                                value: transactionId.length > 12
                                    ? '${transactionId.substring(0, 12)}...'
                                    : transactionId,
                              ),
                            _InfoRow(
                              label: "Metode Bayar",
                              value: paymentMethod,
                            ),
                            _InfoRow(
                              label: "Status",
                              value: status,
                              valueColor: status == 'Berhasil'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ),

                      // ─── Dashed Divider ────────────
                      _DashedDivider(),

                      // ─── Item List ─────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Detail Produk",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...items.map((item) {
                              final name = item['name'] ?? '';
                              final price = item['price'] ?? 0;
                              final qty = item['qty'] ?? 1;
                              final image = item['image'] ?? '';
                              final subtotal = (price is int
                                      ? price.toDouble()
                                      : (price as double)) *
                                  qty;

                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: Image.asset(
                                        image,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    8),
                                          ),
                                          child: const Icon(Icons.image,
                                              size: 24),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "$qty x Rp ${_formatNumber(price)}",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "Rp ${_formatNumber(subtotal)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      // ─── Dashed Divider ────────────
                      _DashedDivider(),

                      // ─── Total ─────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Pembayaran",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Rp ${_formatNumber(total)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ─── Footer ────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Icon(Icons.store,
                                color: Colors.grey.shade400, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              "Permata Store",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "Terima kasih sudah berbelanja!",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Action Buttons ────────────────
                if (showBackToHome)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false);
                      },
                      icon: const Icon(Icons.home, color: Colors.white),
                      label: const Text(
                        "Kembali ke Home",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatNumber(dynamic number) {
    final n = number is int ? number : (number as double).round();
    final str = n.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}

// ─── Dashed Divider Widget ──────────────────────────────
class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 6.0;
          const dashSpace = 4.0;
          final dashCount =
              (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth + dashSpace,
                child: Center(
                  child: Container(
                    width: dashWidth,
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ─── Info Row Widget ────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
