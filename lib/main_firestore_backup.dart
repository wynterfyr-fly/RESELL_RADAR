import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// PRODUCT MODEL
class Product {
  final String title;
  final String price;
  final String percentage;
  final String imagePath;
  final String marketplaceUrl;

  Product({
    required this.title,
    required this.price,
    required this.percentage,
    required this.imagePath,
    required this.marketplaceUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'percentage': percentage,
      'imagePath': imagePath,
      'marketplaceUrl': marketplaceUrl,
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
      marketplaceUrl:
          map['marketplaceUrl'],
    );
  }
}

// MAIN APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title: 'Resell Radar',

      theme: ThemeData.dark(),

      home: const SplashScreen(),
    );
  }
}

// SPLASH SCREEN
class SplashScreen
    extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen>
      createState() =>
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
                fontSize: 34,
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

// AUTH GATE
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream:
          FirebaseAuth.instance
              .authStateChanges(),

      builder: (context, snapshot) {

        if (snapshot.hasData) {
          return const MyHomePage();
        }

        return const LoginPage();
      },
    );
  }
}

// LOGIN PAGE
class LoginPage
    extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage>
      createState() =>
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
        email:
            emailController.text.trim(),
        password:
            passwordController.text.trim(),
      );

    } on FirebaseAuthException catch (e) {

      showDialog(
        context: context,
        builder: (context) {

          return AlertDialog(
            title: const Text(
              'Login Error',
            ),

            content:
                Text(e.message ?? ''),
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
        child: SingleChildScrollView(
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

              const SizedBox(
                height: 24,
              ),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              TextField(
                controller:
                    emailController,

                decoration:
                    const InputDecoration(
                  hintText: 'Email',
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextField(
                controller:
                    passwordController,

                obscureText: true,

                decoration:
                    const InputDecoration(
                  hintText: 'Password',
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width:
                    double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed: signIn,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.deepPurple,
                  ),

                  child: const Text(
                    'Login',
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

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

                    child: const Text(
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

// SIGNUP PAGE
class SignupPage
    extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage>
      createState() =>
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
        email:
            emailController.text.trim(),
        password:
            passwordController.text.trim(),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      showDialog(
        context: context,
        builder: (context) {

          return AlertDialog(
            title: const Text(
              'Signup Error',
            ),

            content:
                Text(e.message ?? ''),
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
        child: SingleChildScrollView(
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

              const SizedBox(
                height: 24,
              ),

              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              TextField(
                controller:
                    emailController,

                decoration:
                    const InputDecoration(
                  hintText: 'Email',
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              TextField(
                controller:
                    passwordController,

                obscureText: true,

                decoration:
                    const InputDecoration(
                  hintText: 'Password',
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width:
                    double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed: signUp,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.deepPurple,
                  ),

                  child: const Text(
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

// HOME PAGE
class MyHomePage
    extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage>
      createState() =>
          _MyHomePageState();
}

class _MyHomePageState
    extends State<MyHomePage> {

  final TextEditingController
      searchController =
      TextEditingController();

  int selectedIndex = 0;

  List<Product> favoriteProducts =
      [];

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final User? currentUser =
      FirebaseAuth.instance
          .currentUser;

  final List<Product> allProducts = [

    Product(
      title: 'PlayStation 5',
      price: '\$420 Resale Value',
      percentage: '+18%',
      imagePath:
          'assets/images/ps5.png',
      marketplaceUrl:
          'https://www.ebay.com',
    ),

    Product(
      title: 'Nike Dunk Low',
      price: '\$180 Resale Value',
      percentage: '+32%',
      imagePath:
          'assets/images/nike_dunk.png',
      marketplaceUrl:
          'https://stockx.com',
    ),

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
    ),
  ];

  List<Product> filteredProducts =
      [];

  @override
  void initState() {
    super.initState();

    filteredProducts = allProducts;

    loadFavorites();
  }

  // LOAD FAVORITES FROM FIRESTORE
  Future<void> loadFavorites()
      async {

    if (currentUser == null) {
      return;
    }

    final snapshot =
        await firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('favorites')
            .get();

    setState(() {

      favoriteProducts =
          snapshot.docs.map((doc) {

        return Product.fromMap(
          doc.data(),
        );

      }).toList();
    });
  }

  // SAVE FAVORITE
  Future<void> saveFavorite(
      Product product) async {

    if (currentUser == null) {
      return;
    }

    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('favorites')
        .doc(product.title)
        .set(product.toMap());
  }

  // REMOVE FAVORITE
  Future<void> removeFavorite(
      Product product) async {

    if (currentUser == null) {
      return;
    }

    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('favorites')
        .doc(product.title)
        .delete();
  }

  // FILTER PRODUCTS
  void filterProducts(
      String query) {

    setState(() {

      filteredProducts =
          allProducts.where(
              (product) {

        return product.title
            .toLowerCase()
            .contains(
              query.toLowerCase(),
            );

      }).toList();
    });
  }

  // TOGGLE FAVORITE
  void toggleFavorite(
      Product product) {

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

        removeFavorite(product);

      } else {

        favoriteProducts
            .add(product);

        saveFavorite(product);
      }
    });
  }

  // IS FAVORITE
  bool isFavorite(
      Product product) {

    return favoriteProducts.any(
      (item) =>
          item.title ==
          product.title,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),

      // APP BAR
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF1E1E1E),

        title: const Text(
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
                const Icon(Icons.logout),
          ),
        ],
      ),

      // BODY
      body: selectedIndex == 0
          ? buildHomeScreen()
          : buildWatchlistScreen(),

      // CAMERA BUTTON
      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            Colors.deepPurple,

        onPressed: () {},

        child:
            const Icon(Icons.camera_alt),
      ),

      // BOTTOM NAV
      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex:
            selectedIndex,

        onTap: (index) {

          setState(() {
            selectedIndex = index;
          });
        },

        selectedItemColor:
            Colors.deepPurple,

        backgroundColor:
            const Color(0xFF121212),

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon:
                Icon(Icons.favorite),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }

  // HOME SCREEN
  Widget buildHomeScreen() {

    return Padding(
      padding:
          const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [

          // SEARCH BAR
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

  // WATCHLIST SCREEN
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

  // PRODUCT CARD
  Widget buildProductCard(
      Product product) {

    final favorite =
        isFavorite(product);

    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailPage(
              product: product,
              isFavorite:
                  favorite,

              onFavoriteToggle:
                  () {

                toggleFavorite(
                    product);
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

            // IMAGE
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
              ),
            ),

            const SizedBox(
              width: 16,
            ),

            // PRODUCT INFO
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
                          FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),
            ),

            // FAVORITE BUTTON
            IconButton(
              onPressed: () {

                toggleFavorite(
                    product);
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

// DETAIL PAGE
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

  // OPEN MARKETPLACE
  Future<void> openMarketplace(
      String url) async {

    final Uri uri =
        Uri.parse(url);

    if (!await launchUrl(uri)) {

      throw Exception(
        'Could not launch $url',
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF1E1E1E),

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

            // IMAGE
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
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // TITLE
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

            // RESALE VALUE
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

            // ROI
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

            const Spacer(),

            // FAVORITE BUTTON
            SizedBox(
              width:
                  double.infinity,

              height: 60,

              child: ElevatedButton
                  .icon(
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
                      ? 'Remove Favorite'
                      : 'Track Product',
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

            const SizedBox(
              height: 16,
            ),

            // MARKETPLACE BUTTON
            SizedBox(
              width:
                  double.infinity,

              height: 60,

              child:
                  OutlinedButton(
                onPressed: () {

                  openMarketplace(
                    product
                        .marketplaceUrl,
                  );
                },

                child: const Text(
                  'View Marketplace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}