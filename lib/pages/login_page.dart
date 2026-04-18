import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_page.dart';

// 🔥 WARNA
const primaryColor = Color(0xFF0F9D58);
const secondaryColor = Color(0xFF34A853);
const accentColor = Color(0xFF0B8043);
const goldColor = Color(0xFFFFC107);

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final emailController = TextEditingController();
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
      duration: Duration(milliseconds: 800),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email dan password wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login gagal")),
      );
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> loginWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'name': user.displayName,
        'email': user.email,
        'photo': user.photoURL,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {}

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor, accentColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              SizedBox(height: 30),

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
                        gradient: LinearGradient(
                          colors: [goldColor, Colors.white],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withOpacity(0.7),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/image/logo.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    Text(
                      "Permata Store",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Perabotan Rumah Tangga Store",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // 🔥 CARD LOGIN
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [

                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 25),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      TextField(
                        controller: passwordController,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(Icons.lock),
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

                      SizedBox(height: 25),

                      // 🔥 BUTTON LOGIN
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
                          onPressed: isLoading ? null : login,
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text("Login"),
                        ),
                      ),

                      SizedBox(height: 15),

                      OutlinedButton.icon(
                        onPressed: loginWithGoogle,
                        icon: Icon(Icons.g_mobiledata),
                        label: Text("Login dengan Google"),
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Belum punya akun? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RegisterPage()),
                              );
                            },
                            child: Text(
                              "Daftar sekarang",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
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