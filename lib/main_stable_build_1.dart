import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// ======================================================
// PRODUCT MODEL
// ======================================================

class Product {
  final String title;
  final String price;
  final String percentage;
  final String imagePath;
  final String marketplaceUrl;
  final String description;

  Product({
    required this.title,
    required this.price,
    required this.percentage,
    required this.imagePath,
    required this.marketplaceUrl,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'percentage': percentage,
      'imagePath': imagePath,
      'marketplaceUrl': marketplaceUrl,
      'description': description,
    };
  }

  factory Product.fromMap(
    Map<String, dynamic> map,
  ) {
    return Product(
      title: map['title'],
      price: map['price'],
      percentage: map['percentage'],
      imagePath: map['imagePath'],
      marketplaceUrl: map['marketplaceUrl'],
      description: map['description'],
    );
  }
}

// ======================================================
// APP ROOT
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resell Radar',
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

// ======================================================
// SPLASH SCREEN
// ======================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const AuthGate(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.show_chart,
              size: 90,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 24),
            Text(
              'Resell Radar',
              style: TextStyle(
                fontSize: 38,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// AUTH GATE
// ======================================================

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(),
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.hasData) {
          return const MyHomePage();
        }

        return const LoginPage();
      },
    );
  }
}

// ======================================================
// LOGIN PAGE
// ======================================================

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  Future signIn() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text
            .trim(),
        password:
            passwordController.text
                .trim(),
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:
                const Text(
              'Login Error',
            ),
            content: Text(
              e.message ?? '',
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),
      body: Center(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            children: [
              const Icon(
                Icons.show_chart,
                size: 90,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller:
                    emailController,
                decoration:
                    const InputDecoration(
                  hintText: 'Email',
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Password',
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width:
                    double.infinity,
                height: 55,
                child:
                    ElevatedButton(
                  onPressed:
                      signIn,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors
                            .deepPurple,
                  ),
                  child:
                      const Text(
                    'Login',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  const Text(
                    'No account?',
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const SignupPage(),
                        ),
                      );
                    },
                    child:
                        const Text(
                      'Create One',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// SIGNUP PAGE
// ======================================================

class SignupPage extends StatefulWidget {
  const SignupPage({
    super.key,
  });

  @override
  State<SignupPage> createState() =>
      _SignupPageState();
}

class _SignupPageState
    extends State<SignupPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  Future signUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text
            .trim(),
        password:
            passwordController.text
                .trim(),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:
                const Text(
              'Signup Error',
            ),
            content: Text(
              e.message ?? '',
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),
      body: Center(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: Column(
            children: [
              const Icon(
                Icons.person_add,
                size: 90,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller:
                    emailController,
                decoration:
                    const InputDecoration(
                  hintText: 'Email',
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    passwordController,
                obscureText: true,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Password',
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width:
                    double.infinity,
                height: 55,
                child:
                    ElevatedButton(
                  onPressed:
                      signUp,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors
                            .deepPurple,
                  ),
                  child:
                      const Text(
                    'Sign Up',
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

// ======================================================
// HOME PAGE
// ======================================================

class MyHomePage
    extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState();
}

class _MyHomePageState
    extends State<MyHomePage> {

  final TextEditingController
      searchController =
      TextEditingController();

  int selectedIndex = 0;

  List<Product>
      favoriteProducts = [];

  final FirebaseFirestore
      firestore =
      FirebaseFirestore.instance;

  final User? currentUser =
      FirebaseAuth.instance
          .currentUser;

  // ======================================================
  // PRODUCTS
  // ======================================================

  late final Product ps5Product =
      Product(
    title: 'PlayStation 5',
    price:
        '\$420 Resale Value',
    percentage: '+18%',
    imagePath:
        'assets/images/ps5.png',
    marketplaceUrl:
        'https://www.ebay.com',
    description:
        'High demand console with excellent resale market.',
  );

  late final Product nikeProduct =
      Product(
    title: 'Nike Dunk Low',
    price:
        '\$180 Resale Value',
    percentage: '+32%',
    imagePath:
        'assets/images/nike_dunk.png',
    marketplaceUrl:
        'https://stockx.com',
    description:
        'Popular sneaker with strong resale momentum.',
  );

  late final Product pokemonProduct =
      Product(
    title:
        'Pokemon Booster Box',
    price:
        '\$240 Resale Value',
    percentage: '+41%',
    imagePath:
        'assets/images/pokemon.png',
    marketplaceUrl:
        'https://www.tcgplayer.com',
    description:
        'Collectible TCG item with strong appreciation potential.',
  );

  late final Product groguProduct =
      Product(
    title:
        'Star Wars Ultimate Grogu',
    price:
        '\$550 Resale Value',
    percentage: '+22%',
    imagePath:
        'assets/images/grogu.png',
    marketplaceUrl:
        'https://www.ebay.com',
    description:
        'Limited edition Grogu collectible with growing demand.',
  );

  late final List<Product>
      allProducts = [
    ps5Product,
    nikeProduct,
    pokemonProduct,
    groguProduct,
  ];

  // ======================================================
  // BARCODE DATABASE
  // ======================================================

  late final Map<String,
      Product> barcodeDatabase = {

    // GROGU
    '70371153261785':
        groguProduct,

    '03044551542173':
        groguProduct,

    '3044551542173':
        groguProduct,

    // PS5
    '111111111111':
        ps5Product,

    // NIKE
    '222222222222':
        nikeProduct,

    // POKEMON
    '333333333333':
        pokemonProduct,
  };

  List<Product>
      filteredProducts = [];

  @override
  void initState() {
    super.initState();

    filteredProducts =
        allProducts;

    loadFavorites();
  }

  Future<void>
      loadFavorites() async {

    if (currentUser == null) {
      return;
    }

    final snapshot =
        await firestore
            .collection('users')
            .doc(
              currentUser!.uid,
            )
            .collection(
                'favorites')
            .get();

    setState(() {
      favoriteProducts =
          snapshot.docs.map(
        (doc) {
          return Product.fromMap(
            doc.data(),
          );
        },
      ).toList();
    });
  }

  Future<void> saveFavorite(
    Product product,
  ) async {

    if (currentUser == null) {
      return;
    }

    await firestore
        .collection('users')
        .doc(
          currentUser!.uid,
        )
        .collection(
            'favorites')
        .doc(product.title)
        .set(product.toMap());
  }

  Future<void>
      removeFavorite(
    Product product,
  ) async {

    if (currentUser == null) {
      return;
    }

    await firestore
        .collection('users')
        .doc(
          currentUser!.uid,
        )
        .collection(
            'favorites')
        .doc(product.title)
        .delete();
  }

  void toggleFavorite(
    Product product,
  ) {

    setState(() {

      final alreadyExists =
          favoriteProducts.any(
        (item) =>
            item.title ==
            product.title,
      );

      if (alreadyExists) {

        favoriteProducts
            .removeWhere(
          (item) =>
              item.title ==
              product.title,
        );

        removeFavorite(
          product,
        );

      } else {

        favoriteProducts
            .add(product);

        saveFavorite(
          product,
        );
      }
    });
  }

  bool isFavorite(
    Product product,
  ) {

    return favoriteProducts.any(
      (item) =>
          item.title ==
          product.title,
    );
  }

  void filterProducts(
    String query,
  ) {

    setState(() {

      filteredProducts =
          allProducts.where(
        (product) {

          return product.title
              .toLowerCase()
              .contains(
                query.toLowerCase(),
              );
        },
      ).toList();
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFF1E1E1E,
        ),

        title:
            const Text(
          'Resell Radar',
        ),

        actions: [

          IconButton(
            onPressed: () async {

              await FirebaseAuth
                  .instance
                  .signOut();
            },

            icon:
                const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: selectedIndex == 0
          ? buildHomeScreen()
          : buildWatchlistScreen(),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            Colors.deepPurple,

        onPressed: () {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder:
                  (context) =>
                      ScannerPage(
                barcodeDatabase:
                    barcodeDatabase,

                isFavorite:
                    isFavorite,

                toggleFavorite:
                    toggleFavorite,
              ),
            ),
          );
        },

        child:
            const Icon(
          Icons.camera_alt,
        ),
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex:
            selectedIndex,

        selectedItemColor:
            Colors.deepPurple,

        backgroundColor:
            const Color(
          0xFF121212,
        ),

        onTap: (index) {

          setState(() {
            selectedIndex =
                index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon:
                Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
            ),
            label:
                'Watchlist',
          ),
        ],
      ),
    );
  }

// ======================================================
// HOME SCREEN
// ======================================================

  Widget buildHomeScreen() {
    return Padding(
      padding:
          const EdgeInsets.all(
        16,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          TextField(
            controller:
                searchController,

            onChanged:
                filterProducts,

            decoration:
                InputDecoration(
              hintText:
                  'Search products...',

              prefixIcon:
                  const Icon(
                Icons.search,
              ),

              filled: true,

              fillColor:
                  const Color(
                0xFF1E1E1E,
              ),

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
                borderSide:
                    BorderSide.none,
              ),
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          const Text(
            'Trending Products',
            style: TextStyle(
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Expanded(
            child: ListView(
              children: [

                for (var product
                    in filteredProducts)
                  buildProductCard(
                    product,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ======================================================
// WATCHLIST SCREEN
// ======================================================

  Widget buildWatchlistScreen() {

    return favoriteProducts
            .isEmpty

        ? const Center(
            child: Text(
              'No watchlist items yet.',
            ),
          )

        : ListView(
            padding:
                const EdgeInsets
                    .all(16),

            children: [

              for (var product
                  in favoriteProducts)
                buildProductCard(
                  product,
                ),
            ],
          );
  }

// ======================================================
// PRODUCT CARD
// ======================================================

  Widget buildProductCard(
    Product product,
  ) {

    final favorite =
        isFavorite(product);

    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,

          MaterialPageRoute(
            builder:
                (context) =>
                    ProductDetailPage(
              product:
                  product,

              isFavorite:
                  favorite,

              onFavoriteToggle:
                  () {

                toggleFavorite(
                  product,
                );
              },
            ),
          ),
        );
      },

      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 16,
        ),

        padding:
            const EdgeInsets.all(
          16,
        ),

        decoration: BoxDecoration(
          color:
              const Color(
            0xFF1E1E1E,
          ),

          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),

        child: Row(
          children: [

            ClipRRect(
              borderRadius:
                  BorderRadius
                      .circular(
                12,
              ),

              child: Image.asset(
                product.imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,

                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {

                  return Container(
                    width: 70,
                    height: 70,
                    color:
                        Colors.grey
                            .shade800,

                    child:
                        const Icon(
                      Icons.image,
                      color:
                          Colors.grey,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              width: 16,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(
                    product.title,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    product.price,
                    style:
                        const TextStyle(
                      color: Colors
                          .greenAccent,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    product.percentage,
                    style:
                        const TextStyle(
                      color:
                          Colors.orange,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {

                toggleFavorite(
                  product,
                );
              },

              icon: Icon(
                favorite
                    ? Icons.favorite
                    : Icons
                        .favorite_border,

                color: favorite
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// PRODUCT DETAIL PAGE
// ======================================================

class ProductDetailPage
    extends StatelessWidget {

  final Product product;

  final bool isFavorite;

  final VoidCallback
      onFavoriteToggle;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  Future<void>
      openMarketplace(
    String url,
  ) async {

    final Uri uri =
        Uri.parse(url);

    if (!await launchUrl(uri)) {

      throw Exception(
        'Could not launch $url',
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFF1E1E1E,
        ),

        title:
            Text(product.title),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            ClipRRect(
              borderRadius:
                  BorderRadius
                      .circular(
                20,
              ),

              child: Image.asset(
                product.imagePath,
                width:
                    double.infinity,
                height: 260,
                fit: BoxFit.cover,

                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {

                  return Container(
                    width:
                        double.infinity,
                    height: 260,
                    color:
                        Colors.grey
                            .shade800,

                    child:
                        const Icon(
                      Icons.image,
                      size: 80,
                      color:
                          Colors.grey,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              product.title,
              style:
                  const TextStyle(
                fontSize: 32,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              product.price,
              style:
                  const TextStyle(
                color:
                    Colors.greenAccent,
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Projected Profit: ${product.percentage}',
              style:
                  const TextStyle(
                color:
                    Colors.orange,
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              product.description,
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const Spacer(),

            Row(
              children: [

                Expanded(
                  child: SizedBox(
                    height: 55,

                    child:
                        ElevatedButton.icon(
                      onPressed: () {

                        openMarketplace(
                          product.marketplaceUrl,
                        );
                      },

                      icon:
                          const Icon(
                        Icons
                            .shopping_cart,
                      ),

                      label:
                          const Text(
                        'Marketplace',
                      ),

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.green,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: SizedBox(
                    height: 55,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          onFavoriteToggle,

                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons
                                .favorite_border,
                      ),

                      label: Text(
                        isFavorite
                            ? 'Remove'
                            : 'Track',
                      ),

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors
                                .deepPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// SCANNER PAGE
// ======================================================

// ======================================================
// SCANNER PAGE
// FULL STABLE VERSION
// ======================================================

class ScannerPage extends StatefulWidget {

  final Map<String, Product>
      barcodeDatabase;

  final bool Function(Product)
      isFavorite;

  final void Function(Product)
      toggleFavorite;

  const ScannerPage({
    super.key,
    required this.barcodeDatabase,
    required this.isFavorite,
    required this.toggleFavorite,
  });

  @override
  State<ScannerPage>
      createState() =>
          _ScannerPageState();
}

class _ScannerPageState
    extends State<ScannerPage> {

  bool scanned = false;

  void resetScanner() {

    Future.delayed(
      const Duration(
        milliseconds: 1200,
      ),
      () {

        if (mounted) {

          setState(() {
            scanned = false;
          });
        }
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(
      backgroundColor:
          Colors.black,

      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFF121212,
        ),

        title:
            const Text(
          'Scan Product',
        ),
      ),

      body: Stack(
        children: [

          // ======================================================
          // CAMERA SCANNER
          // ======================================================

          MobileScanner(
            onDetect: (capture) {

              if (scanned) {
                return;
              }

              final List<Barcode>
                  barcodes =
                  capture.barcodes;

              for (final barcode
                  in barcodes) {

                String code =
                    barcode.rawValue ??
                        '';

                // ======================================================
                // CLEAN BARCODE
                // ======================================================

                code = code
                    .replaceAll(
                        ' ', '')
                    .replaceAll(
                        '\n', '')
                    .trim();

                if (code.isEmpty) {
                  return;
                }

                print(
                  'SCANNED CODE: $code',
                );

                setState(() {
                  scanned = true;
                });

                Product?
                    matchedProduct;

                // ======================================================
                // BARCODE MATCHING
                // ======================================================

                for (final entry
                    in widget
                        .barcodeDatabase
                        .entries) {

                  if (code.contains(
                          entry.key) ||
                      entry.key
                          .contains(
                              code)) {

                    matchedProduct =
                        entry.value;

                    break;
                  }
                }

                // ======================================================
                // PRODUCT FOUND
                // ======================================================

                if (matchedProduct !=
                    null) {

                  final product =
                      matchedProduct;

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProductDetailPage(
                        product:
                            product,

                        isFavorite:
                            widget
                                .isFavorite(
                          product,
                        ),

                        onFavoriteToggle:
                            () {

                          widget
                              .toggleFavorite(
                            product,
                          );
                        },
                      ),
                    ),
                  ).then((_) {

                    resetScanner();
                  });

                }

                // ======================================================
                // UNKNOWN PRODUCT
                // ======================================================

                else {

                  showDialog(
                    context:
                        context,

                    builder:
                        (context) {

                      return AlertDialog(
                        backgroundColor:
                            const Color(
                          0xFF1E1E1E,
                        ),

                        title:
                            const Text(
                          'Unknown Product',
                        ),

                        content: Text(
                          'Barcode:\n$code',
                        ),

                        actions: [

                          TextButton(
                            onPressed:
                                () {

                              Navigator.pop(
                                  context);

                              resetScanner();
                            },

                            child:
                                const Text(
                              'Scan Again',
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                break;
              }
            },
          ),

          // ======================================================
          // SCANNER FRAME
          // ======================================================

          Center(
            child: Container(
              width: 260,
              height: 260,

              decoration:
                  BoxDecoration(

                border: Border.all(
                  color:
                      Colors.deepPurple,
                  width: 4,
                ),

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
            ),
          ),

          // ======================================================
          // INSTRUCTIONS
          // ======================================================

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,

            child: const Center(
              child: Text(
                'Align barcode inside frame',

                style: TextStyle(
                  color:
                      Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}