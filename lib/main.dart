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

// 🔥 DEEPLINK
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_links/app_links.dart';
import 'features/cart/pages/success_page.dart';
import 'dart:async';

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
      child: const DeepLinkListener(child: MyApp()),
    );
  }
}

class DeepLinkListener extends StatefulWidget {
  final Widget child;
  const DeepLinkListener({super.key, required this.child});

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'permatastore' && uri.host == 'payment-callback') {
      final status = uri.queryParameters['status'];
      final reference = uri.queryParameters['reference'];

      if (status == 'success' && reference != null) {
        try {
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(reference)
              .update({'status': 'Berhasil'});

          if (mounted) {
            Provider.of<CartModel>(context, listen: false).clearCart();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SuccessPage()),
              (route) => route.isFirst,
            );
          }
        } catch (e) {
          debugPrint("Gagal mengupdate order dari callback: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
      stream: FirebaseAuth.instance.idTokenChanges(), // 🔥 GANTI INI
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