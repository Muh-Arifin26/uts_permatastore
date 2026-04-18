import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_page.dart';

// 🔥 WARNA PERMATA
const primaryColor = Color(0xFF0F9D58);
const secondaryColor = Color(0xFF34A853);
const accentColor = Color(0xFF0B8043);
const goldColor = Color(0xFFFFC107);

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isObscure = true;

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor, accentColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 40),

                        // 🔥 LOGO
                        Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Image.asset(
                                    "assets/image/logo.jpg"),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Permata Store",
                              style: TextStyle(
                                color: goldColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        // 🔥 CARD
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // 🔥 hitam
                                  ),
                                ),

                                SizedBox(height: 25),

                                // 🔥 EMAIL
                                TextField(
                                  controller: emailController,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    labelStyle:
                                    TextStyle(color: Colors.black),
                                    prefixIcon: Icon(Icons.email,
                                        color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(15),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 15),

                                // 🔥 PASSWORD
                                TextField(
                                  controller: passwordController,
                                  obscureText: isObscure,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle:
                                    TextStyle(color: Colors.black),
                                    prefixIcon: Icon(Icons.lock,
                                        color: primaryColor),
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
                                      borderRadius:
                                      BorderRadius.circular(15),
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
                                        borderRadius:
                                        BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed:
                                    isLoading ? null : login,
                                    child: isLoading
                                        ? CircularProgressIndicator(
                                        color: Colors.white)
                                        : Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 15),

                                // 🔥 GOOGLE
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : loginWithGoogle,
                                    icon: Icon(Icons.g_mobiledata,
                                        color: primaryColor),
                                    label: Text(
                                      "Login dengan Google",
                                      style:
                                      TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Belum punya akun? ",
                                      style:
                                      TextStyle(color: Colors.black),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  RegisterPage()),
                                        );
                                      },
                                      child: Text(
                                        "Daftar",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}