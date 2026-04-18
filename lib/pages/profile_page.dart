import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/theme_provider.dart';


class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // 👤 FOTO
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              backgroundImage:
              user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),

            SizedBox(height: 10),

            // 👤 NAMA (DARI FIREBASE)
            Text(
              user?.displayName ?? "User",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // 📧 EMAIL (DARI FIREBASE)
            Text(
              user?.email ?? "-",
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 20),

            Divider(),

            // 🌙 DARK MODE
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  title: Text("Dark Mode"),
                  secondary: Icon(Icons.dark_mode),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                );
              },
            ),

            // 📱 INFO
            ListTile(
              leading: Icon(Icons.phone, color: Colors.blue),
              title: Text("Nomor Telepon"),
              subtitle: Text("081234567890"),
            ),

            ListTile(
              leading: Icon(Icons.location_on, color: Colors.blue),
              title: Text("Alamat"),
              subtitle: Text("Jl. Contoh No.123, Bandung"),
            ),

            Divider(),

            // 🧾 MENU
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text("Pesanan Saya"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Wishlist"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.location_city),
              title: Text("Alamat Pengiriman"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.payment),
              title: Text("Metode Pembayaran"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            Divider(),

            // ⚙️ SETTINGS
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Pengaturan"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.help),
              title: Text("Bantuan"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            SizedBox(height: 10),

            // 🚪 LOGOUT
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();

                  // 🔥 kalau pakai AuthWrapper, ini opsional
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false,
                  );
                },
                child: Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}