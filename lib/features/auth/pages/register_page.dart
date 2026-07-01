import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 WARNA
const primaryColor = Color(0xFF0F9D58);
const secondaryColor = Color(0xFF34A853);
const accentColor = Color(0xFF0B8043);
const goldColor = Color(0xFFFFC107);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;

  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi")),
      );
      return;
    }

    // 🔥 VALIDASI EMAIL
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format email tidak valid")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user == null) throw Exception("User null");

      // 🔥 KIRIM EMAIL VERIFIKASI
      await user.sendEmailVerification();

      // 🔥 SIMPAN FIRESTORE
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'created_at': DateTime.now(),
      });

      // 🔥 LOGOUT
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akun berhasil dibuat, cek email untuk verifikasi"),
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor, accentColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 30),

              // 🔥 LOGO + ANIMASI
              ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [goldColor, Colors.white],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withOpacity(0.6),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/image/logo.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Permata Store",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Perabotan Rumah Tangga Store",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🔥 FORM
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [

                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 25),

                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Nama",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            hintText: "No HP",
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: passwordController,
                          obscureText: isObscure,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: isLoading ? null : register,
                            child: isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text("Daftar"),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah punya akun? "),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}