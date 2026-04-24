import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔥 CORE
import 'core/theme/theme_provider.dart';

// 🔥 FEATURES
import 'features/cart/models/cart_model.dart';
import 'features/catalog/providers/favorite_model.dart';
import 'features/catalog/pages/home_page.dart';
import 'features/cart/pages/cart_page.dart';
import 'features/auth/pages/login_page.dart';

// 🔥 FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyAppWrapper());
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => FavoriteModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          themeMode: themeProvider.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),

          home: const AuthWrapper(),

          routes: {
            '/home': (context) => HomePage(),
            '/cart': (context) => CartPage(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return HomePage();
        }

        return LoginPage();
      },
    );
  }
}