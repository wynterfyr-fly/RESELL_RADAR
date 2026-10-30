import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';
import 'models/product_monitor.dart';
import 'services/product_monitor_service.dart';
import 'models/deal_intelligence.dart';
import 'models/price_snapshot.dart';
import 'widgets/price_history_sparkline.dart';
import 'services/monitoring_engine_service.dart';
import 'services/notification_service.dart';
import 'services/monitor_queue_service.dart';
import 'services/monitor_scheduler_service.dart';
import 'services/deal_intelligence_service.dart';
import 'services/price_history_service.dart';
import 'services/historical_intelligence_service.dart';
import 'services/resell_radar_verdict_service.dart';
import 'services/ebay_marketplace_service.dart';
import 'services/etsy_marketplace_service.dart';
import 'services/alibaba_marketplace_service.dart';
import 'services/facebook_marketplace_service.dart';
import 'services/offerup_marketplace_service.dart';
import 'services/depop_marketplace_service.dart';
import 'services/grailed_marketplace_service.dart';
import 'services/whatnot_marketplace_service.dart';
import 'services/discogs_marketplace_service.dart';
import 'services/reverb_marketplace_service.dart';
import 'services/tcgplayer_marketplace_service.dart';
import 'services/chrono24_marketplace_service.dart';
import 'services/the_realreal_marketplace_service.dart';
import 'services/poshmark_marketplace_service.dart';
import 'services/goat_marketplace_service.dart';
import 'services/stockx_marketplace_service.dart';
import 'services/mercari_marketplace_service.dart';
import 'services/marketplace_manager.dart';
import 'services/comparable_intelligence_service.dart';
import 'utils/marketplace_query_cleaner.dart';

// ======================================================
// BACKEND URL
// ======================================================

const String backendBaseUrl =
    'http://127.0.0.1:5001/resell-radar-ffec0/us-central1/api';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform,
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
  final String marketplaceItemId;
  final String amazonUrl;

  final String amazonTitle;
  final String amazonDisplayPrice;
  final String amazonAvailability;
  final String description;
  final String barcode;
  final String scannedAt;

  final double lowestPrice;
  final double averagePrice;
  final double medianPrice;
  final double highestPrice;
  final double priceSpread;
  final int resultCount;
  final List<dynamic> rawItems;

  Product({
    required this.title,
    required this.price,
    required this.percentage,
    required this.imagePath,
    required this.marketplaceUrl,
    this.marketplaceItemId = '',
    this.amazonUrl = '',
    this.amazonTitle = '',
    this.amazonDisplayPrice = '',
    this.amazonAvailability = '',
    required this.description,
    required this.barcode,
    required this.scannedAt,
    this.lowestPrice = 0,
    this.averagePrice = 0,
    this.medianPrice = 0,
    this.highestPrice = 0,
    this.priceSpread = 0,
    this.resultCount = 0,
    this.rawItems = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'percentage': percentage,
      'imagePath': imagePath,
      'marketplaceUrl': marketplaceUrl,
      'marketplaceItemId': marketplaceItemId,
      'amazonUrl': amazonUrl,
      'amazonTitle': amazonTitle,
      'amazonDisplayPrice': amazonDisplayPrice,
      'amazonAvailability': amazonAvailability,
      'description': description,
      'barcode': barcode,
      'scannedAt': scannedAt,
      'lowestPrice': lowestPrice,
      'averagePrice': averagePrice,
      'medianPrice': medianPrice,
      'highestPrice': highestPrice,
      'priceSpread': priceSpread,
      'resultCount': resultCount,
      'rawItems': rawItems,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      title: map['title'] ?? '',
      price: map['price'] ?? '',
      percentage: map['percentage'] ?? '',
      imagePath: map['imagePath'] ?? '',
      marketplaceUrl: map['marketplaceUrl'] ?? '',
      marketplaceItemId:
      map['marketplaceItemId']
        ?.toString() ??
      '',  
      amazonUrl: map['amazonUrl'] ?? '',
      amazonTitle: map['amazonTitle'] ?? '',
      amazonDisplayPrice: map['amazonDisplayPrice'] ?? '',
      amazonAvailability: map['amazonAvailability'] ?? '',
      description: map['description'] ?? '',
      barcode: map['barcode'] ?? '',
      scannedAt: map['scannedAt'] ?? '',
      lowestPrice: (map['lowestPrice'] as num?)?.toDouble() ?? 0,
      averagePrice: (map['averagePrice'] as num?)?.toDouble() ?? 0,
      medianPrice: (map['medianPrice'] as num?)?.toDouble() ?? 0,
      highestPrice: (map['highestPrice'] as num?)?.toDouble() ?? 0,
      priceSpread: (map['priceSpread'] as num?)?.toDouble() ?? 0, 
      resultCount: (map['resultCount'] as num?)?.toInt() ?? 0,
      rawItems: map['rawItems'] ?? const [],
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

  final PriceHistoryService 
    priceHistoryService =
    PriceHistoryService();

final ProductMonitorService
    productMonitorService =
    ProductMonitorService();

late final MonitoringEngineService
    monitoringEngineService =
    MonitoringEngineService(
  backendBaseUrl:
      backendBaseUrl,
);

final NotificationService
    notificationService =
    NotificationService();

final MonitorSchedulerService
    monitorSchedulerService =
    MonitorSchedulerService();

final MonitorQueueService
    monitorQueueService =
    MonitorQueueService();

DateTime? ebayCooldownUntil;

bool get isEbayCoolingDown {
  final cooldownUntil =
      ebayCooldownUntil;

  if (cooldownUntil == null) {
    return false;
  }

  return DateTime.now().isBefore(
    cooldownUntil,
  );
}

final User? currentUser =
    FirebaseAuth.instance
        .currentUser;

late final EbayMarketplaceService
    ebayMarketplaceService =
    EbayMarketplaceService(
  baseUrl: backendBaseUrl,
);

late final MercariMarketplaceService
    mercariMarketplaceService =
    MercariMarketplaceService();

late final GoatMarketplaceService
    goatMarketplaceService =
    GoatMarketplaceService();

late final StockxMarketplaceService
    stockxMarketplaceService =
    StockxMarketplaceService();

late final EtsyMarketplaceService
    etsyMarketplaceService =
    EtsyMarketplaceService();

late final AlibabaMarketplaceService
    alibabaMarketplaceService =
    AlibabaMarketplaceService();

late final FacebookMarketplaceService
    facebookMarketplaceService =
    FacebookMarketplaceService();

late final OfferUpMarketplaceService
    offerUpMarketplaceService =
    OfferUpMarketplaceService();

late final DepopMarketplaceService
    depopMarketplaceService =
    DepopMarketplaceService();

late final GrailedMarketplaceService
    grailedMarketplaceService =
    GrailedMarketplaceService();

late final WhatnotMarketplaceService
    whatnotMarketplaceService =
    WhatnotMarketplaceService();

late final DiscogsMarketplaceService
    discogsMarketplaceService =
    DiscogsMarketplaceService();

late final ReverbMarketplaceService
    reverbMarketplaceService =
    ReverbMarketplaceService();

late final TCGplayerMarketplaceService
    tcgplayerMarketplaceService =
    TCGplayerMarketplaceService();

late final Chrono24MarketplaceService
    chrono24MarketplaceService =
    Chrono24MarketplaceService();

late final TheRealRealMarketplaceService
    theRealRealMarketplaceService =
    TheRealRealMarketplaceService();

late final PoshmarkMarketplaceService
    poshmarkMarketplaceService =
    PoshmarkMarketplaceService();

late final MarketplaceManager
    marketplaceManager =
    MarketplaceManager(
services: [
  ebayMarketplaceService,
  mercariMarketplaceService,
  goatMarketplaceService,
  stockxMarketplaceService,
  etsyMarketplaceService,
  poshmarkMarketplaceService,
  alibabaMarketplaceService,
  facebookMarketplaceService,
  offerUpMarketplaceService,
  depopMarketplaceService,
  grailedMarketplaceService,
  whatnotMarketplaceService,
  discogsMarketplaceService,
  reverbMarketplaceService,
  tcgplayerMarketplaceService,
  chrono24MarketplaceService,
  theRealRealMarketplaceService,
],
);

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
    barcode: '',
    scannedAt: '',
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
        barcode: '',
    scannedAt: '',
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
        barcode: '',
    scannedAt: '',
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
        barcode: '',
    scannedAt: '',
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

bool isSearching = false;
String searchMessage = '';

Timer? searchDebounce;
List<Product> searchSuggestions = [];
int selectedSuggestionIndex = -1;

List<String> recentSearches = [];
bool showRecentSearches = false;

 @override
void initState() {
  super.initState();

  NotificationService()
      .requestPermission();

  monitorSchedulerService.start(
    interval: const Duration(
      minutes: 1,
    ),
    onCheck: runAutomaticMonitorCycle,
  );

  assert(() {
    debugPrint(
      'Registered marketplaces: '
      '${marketplaceManager.services.map(
        (service) =>
            service.marketplaceName,
      ).join(', ')}',
    );

    return true;
  }());

  filteredProducts =
      allProducts;

  loadFavorites();
  loadRecentSearches();
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

Future<void> loadRecentSearches() async {
  if (currentUser == null) {
    return;
  }

  final snapshot = await firestore
      .collection('users')
      .doc(currentUser!.uid)
      .collection('recentSearches')
      .orderBy(
        'searchedAt',
        descending: true,
      )
      .limit(10)
      .get();

  if (!mounted) {
    return;
  }

  setState(() {
    recentSearches = snapshot.docs
        .map(
          (doc) =>
              doc.data()['query']
                  ?.toString() ??
              '',
        )
        .where(
          (query) =>
              query.isNotEmpty,
        )
        .toList();
  });
}

Future<void> saveRecentSearch(
  String query,
) async {
  final trimmedQuery =
      query.trim();

  if (currentUser == null ||
      trimmedQuery.isEmpty) {
    return;
  }

  try {
    final documentId =
    trimmedQuery
        .toLowerCase()
        .replaceAll(
          '/',
          '∕',
        );

    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection(
          'recentSearches',
        )
        .doc(documentId)
        .set({
      'query': trimmedQuery,
      'searchedAt':
          FieldValue.serverTimestamp(),
    });

    await loadRecentSearches();
  } catch (e) {
    print(
      'RECENT SEARCH SAVE ERROR: $e',
    );
  }
}

Future<void> clearRecentSearches() async {
  if (currentUser == null) {
    return;
  }

  try {
    final snapshot = await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('recentSearches')
        .get();

    final batch =
        firestore.batch();

    for (final document
        in snapshot.docs) {
      batch.delete(
        document.reference,
      );
    }

    await batch.commit();

    if (!mounted) {
      return;
    }

    setState(() {
      recentSearches = [];
      showRecentSearches = false;
    });
  } catch (e) {
    print(
      'RECENT SEARCH CLEAR ERROR: $e',
    );
  }
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
.doc(
  product.title.replaceAll(
    '/',
    '∕',
  ),
)
.set(product.toMap());
  }

Future<void> saveScanHistory(
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
        'scanHistory',
      )
      .add(
        product.toMap(),
      );
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
.doc(
  product.title.replaceAll(
    '/',
    '∕',
  ),
)
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

 void filterProducts(String query) {
  setState(() {
    filteredProducts =
        allProducts.where((product) {
      return product.title
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();
  });
}

void openSearchSuggestion(
  Product product,
) {
  final queryToSave =
      searchController.text.trim();

  searchController.text =
      product.title;

  setState(() {
    filteredProducts = [
      product,
    ];

    searchSuggestions = [];
    selectedSuggestionIndex = -1;
    searchMessage =
        'Selected result';
  });

  FocusScope.of(context)
    .unfocus();

if (queryToSave.isNotEmpty) {
  unawaited(
    saveRecentSearch(
      queryToSave,
    ),
  );
}

final currentUser =
    FirebaseAuth.instance.currentUser;

final parsedMarketValue =
    double.tryParse(
      product.price
          .replaceAll('\$', '')
          .replaceAll(',', '')
          .trim(),
    ) ??
    0;

if (currentUser != null &&
    parsedMarketValue > 0) {
  final snapshot =
      priceHistoryService.createSnapshot(
    marketValue: parsedMarketValue,
    lowestPrice: product.lowestPrice,
    averagePrice: product.averagePrice,
    medianPrice: product.medianPrice,
    highestPrice: product.highestPrice,
    listingsChecked: product.resultCount,
    confidence: product.resultCount >= 10
        ? 'High'
        : product.resultCount >= 5
            ? 'Medium'
            : product.resultCount >= 2
                ? 'Low'
                : product.resultCount == 1
                    ? 'Very Low'
                    : 'Unknown',
  );

  final productKey =
      priceHistoryService.createProductKey(
    product.title,
  );

  unawaited(
    priceHistoryService.saveSnapshot(
      userId: currentUser.uid,
      productKey: productKey,
      snapshot: snapshot,
    ),
  );
}

Navigator.push(
  context,
  MaterialPageRoute(
      builder: (_) =>
          ProductDetailPage(
        product: product,
        isFavorite:
            isFavorite(product),
        onFavoriteToggle: () {
          toggleFavorite(
            product,
          );
        },
      ),
    ),
  );
}

Future<void> searchEbay(String query) async {
  final trimmedQuery = query.trim();

  if (trimmedQuery.length < 2) {
  setState(() {
    filteredProducts = allProducts;
    searchSuggestions = [];
    isSearching = false;
    searchMessage = '';
  });
  return;
}

  setState(() {
    isSearching = true;
    searchMessage = 'Searching eBay...';
  });

  try {
    final response = await http.get(
      Uri.parse(
        '$backendBaseUrl/ebay-search/${Uri.encodeComponent(trimmedQuery)}',
      ),
    );

    final data = jsonDecode(response.body);

   if (data['success'] != true) {
  setState(() {
    filteredProducts = [];
    searchSuggestions = [];
    isSearching = false;
    searchMessage = 'No products found.';
  });
  return;
}

    final productsData = data['products'] as List<dynamic>;

    final results = productsData.map((productData) {
      return Product(
        title: productData['name'] ?? 'Unknown Product',
        price: productData['marketPrice'].toString(),
        percentage: productData['profitPotential'] ?? '+0%',
        imagePath: productData['image'] ?? '',
        marketplaceUrl:
        productData['marketplaceUrl'] ?? 'https://www.ebay.com/',
        marketplaceItemId:
         productData['itemId']
        ?.toString() ??
        '',
        amazonUrl: productData['amazonUrl'] ?? '',
        amazonTitle: '',
        amazonDisplayPrice: '',
        amazonAvailability: '',
        description: 'Live eBay search result.',
        barcode: '',
        scannedAt: DateTime.now().toIso8601String(),
        lowestPrice:
            (productData['lowestPrice'] as num?)?.toDouble() ?? 0,
        averagePrice:
            (productData['averagePrice'] as num?)?.toDouble() ?? 0,
        medianPrice:
            (productData['medianPrice'] as num?)?.toDouble() ?? 0,
        highestPrice:
            (productData['highestPrice'] as num?)?.toDouble() ?? 0,
        priceSpread:
            (productData['priceSpread'] as num?)?.toDouble() ?? 0,
        resultCount:
            (productData['resultCount'] as num?)?.toInt() ?? 0,
        rawItems: productData['rawItems'] ?? const [],
      );
    }).toList();

   setState(() {
  searchSuggestions =
      results.take(5).toList();

  selectedSuggestionIndex =
      -1;

  isSearching = false;

  searchMessage =
      results.isEmpty
          ? 'No products found.'
          : '${results.length} suggestions found';
});
  } catch (e) {
    print('SEARCH ERROR: $e');

   setState(() {
  filteredProducts = [];
  searchSuggestions = [];
  isSearching = false;
  searchMessage = 'Search failed. Try again.';
});
  }
}

@override
void dispose() {
  searchDebounce?.cancel();
  searchController.dispose();
  monitorSchedulerService.dispose();
  super.dispose();
}

Widget buildAlertsNavigationIcon() {
  return StreamBuilder<List<ProductMonitor>>(
    stream:
        productMonitorService
            .watchMonitors(),
    builder: (
      context,
      snapshot,
    ) {
      final monitors =
          snapshot.data ??
          const <ProductMonitor>[];

      final triggeredCount =
    monitors
        .where(
          (monitor) =>
              monitor.alertConditionMet &&
              !monitor.isAcknowledged,
        )
        .length;

      return Stack(
        clipBehavior:
            Clip.none,
        children: [
          const Icon(
            Icons.notifications,
          ),

          if (triggeredCount > 0)
            Positioned(
              right: -8,
              top: -6,
              child: Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.redAccent,
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                constraints:
                    const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  triggeredCount > 99
                      ? '99+'
                      : triggeredCount
                          .toString(),
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

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
    : selectedIndex == 1
        ? buildWatchlistScreen()
        : selectedIndex == 2
            ? buildHistoryScreen()
            : buildAlertsScreen(),

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

                saveScanHistory:
                    saveScanHistory,
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
      type: BottomNavigationBarType.fixed,

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

      items: [

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

  BottomNavigationBarItem(
  icon: Icon(
    Icons.history,
  ),
  label:
      'History',
),

BottomNavigationBarItem(
  icon:
      buildAlertsNavigationIcon(),
  label:
      'Alerts',
),
],
      ),
    );
  }

// ======================================================
// HOME SCREEN
// ======================================================

 Widget buildHomeScreen() {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
   onTap: () {
  FocusScope.of(context)
      .unfocus();

  if (searchSuggestions.isNotEmpty ||
      showRecentSearches) {
    setState(() {
      searchSuggestions = [];
      selectedSuggestionIndex =
          -1;
      showRecentSearches = false;
      searchMessage = '';
    });
  }
},
    child: Padding(
      padding: const EdgeInsets.all(
        16,
      ),

      child: SingleChildScrollView(
  child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Focus(
  onFocusChange: (hasFocus) {
  if (hasFocus &&
      searchController.text
          .trim()
          .isEmpty) {
    setState(() {
      showRecentSearches = true;
    });
  }
},

  onKeyEvent: (
    node,
    event,
  ) {
    if (event
            is! KeyDownEvent ||
        searchSuggestions
            .isEmpty) {
      return KeyEventResult
          .ignored;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey
            .arrowDown) {
      setState(() {
        if (selectedSuggestionIndex >=
            searchSuggestions
                    .length -
                1) {
          selectedSuggestionIndex =
              0;
        } else {
          selectedSuggestionIndex++;
        }
      });

      return KeyEventResult
          .handled;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey
            .arrowUp) {
      setState(() {
        if (selectedSuggestionIndex <=
            0) {
          selectedSuggestionIndex =
              searchSuggestions
                      .length -
                  1;
        } else {
          selectedSuggestionIndex--;
        }
      });

      return KeyEventResult
          .handled;
    }

    if (event.logicalKey ==
            LogicalKeyboardKey
                .enter &&
        selectedSuggestionIndex >=
            0 &&
        selectedSuggestionIndex <
            searchSuggestions
                .length) {
      final selectedProduct =
          searchSuggestions[
              selectedSuggestionIndex];

      openSearchSuggestion(
        selectedProduct,
      );

      return KeyEventResult
          .handled;
    }

    return KeyEventResult
        .ignored;
  },

  child: TextField(
    controller:
        searchController,

    onChanged: (value) {
  setState(() {
    selectedSuggestionIndex =
        -1;

    showRecentSearches =
        value.trim().isEmpty;
  });

  searchDebounce
      ?.cancel();

      searchDebounce =
          Timer(
        const Duration(
          milliseconds: 450,
        ),
        () {
          searchEbay(
            value,
          );
        },
      );
    },

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
),

         const SizedBox(
  height: 24,
),

if (showRecentSearches &&
    recentSearches.isNotEmpty)
  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(
      bottom: 20,
    ),
    decoration: BoxDecoration(
      color: const Color(
        0xFF1E1E1E,
      ),
      borderRadius:
          BorderRadius.circular(
        12,
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
       Padding(
  padding: const EdgeInsets.fromLTRB(
    16,
    8,
    8,
    4,
  ),
  child: Row(
    children: [
      const Expanded(
        child: Text(
          'Recent Searches',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ),

      TextButton(
        onPressed:
            clearRecentSearches,
        child: const Text(
          'Clear All',
        ),
      ),
    ],
  ),
),

        for (final query
            in recentSearches)
          ListTile(
            leading: const Icon(
              Icons.history,
              color: Colors.white54,
            ),
            title: Text(
              query,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
            ),
            trailing: const Icon(
              Icons.north_west,
              size: 18,
              color: Colors.white38,
            ),
            onTap: () {
              searchController.text =
                  query;

              setState(() {
                showRecentSearches =
                    false;
                selectedSuggestionIndex =
                    -1;
              });

              searchEbay(
                query,
              );
            },
          ),
      ],
    ),
  ),

if (!isSearching &&
    searchSuggestions.isEmpty &&
    searchMessage == 'No products found.')
  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.search_off,
          color: Colors.white54,
        ),
        SizedBox(width: 12),
        Text(
          'No products found.',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),

if (searchSuggestions.isNotEmpty)
  Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchSuggestions.length,
      itemBuilder: (context, index) {

        final product = searchSuggestions[index];

        return ListTile(
  selected:
      index ==
          selectedSuggestionIndex,

  selectedTileColor:
    Colors.deepPurple
        .withValues(alpha: 0.22),

  leading:
      product.imagePath.isNotEmpty
          ? Image.network(
              product.imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            )
          : const Icon(Icons.inventory),

         title: Builder(
  builder: (context) {
    final query = searchController.text.trim();
    final title = product.title;

    if (query.isEmpty) {
      return Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerTitle.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final beforeMatch = title.substring(
      0,
      matchIndex,
    );

    final matchedText = title.substring(
      matchIndex,
      matchIndex + query.length,
    );

    final afterMatch = title.substring(
      matchIndex + query.length,
    );

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: beforeMatch,
          ),
          TextSpan(
            text: matchedText,
            style: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: afterMatch,
          ),
        ],
      ),
    );
  },
),

          subtitle: Text(
            '\$${product.price}',
          ),

          onTap: () {
  openSearchSuggestion(
    product,
  );
},
        );

      },
    ),
  ),

          if (searchSuggestions.isEmpty) ...[
  const Text(
    'Trending Products',
    style: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(
    height: 20,
  ),

  if (isSearching)
    const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Searching eBay...',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ),

  if (!isSearching && searchMessage.isNotEmpty)
    Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        searchMessage,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
if (filteredProducts.isNotEmpty)
 ListView(
  shrinkWrap: true,
  physics:
      const NeverScrollableScrollPhysics(),
  children: [
    for (var product in filteredProducts)
      buildProductCard(
        product,
      ),
  ],
),
] else
  const SizedBox.shrink(),
        ],
      ),
    ),
    )
  );
  }

// ======================================================
// WATCHLIST SCREEN
// ======================================================

  Widget buildWatchlistScreen() {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Center(
      child: Text('Not signed in'),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .collection('favorites')
    .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text('Watchlist failed to load:\n${snapshot.error}'),
        );
      }

      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final docs = snapshot.data!.docs;

      if (docs.isEmpty) {
        return const Center(
          child: Text('No watchlist items yet.'),
        );
      }

      final products = docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var product in products)
            buildProductCard(product),
        ],
      );
    },
  );
}
Widget buildHistoryScreen() {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Center(
      child: Text('Not signed in'),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('scanHistory')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'History failed to load:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final docs = snapshot.data?.docs ?? [];

      if (docs.isEmpty) {
        return const Center(
          child: Text('No scan history yet.'),
        );
      }

      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        final aTime = aData['scannedAt'];
        final bTime = bData['scannedAt'];

        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }

        return 0;
      });

      return ListView.builder(
  padding: const EdgeInsets.all(12),
  itemCount: docs.length,
  itemBuilder: (context, index) {

    final data =
        docs[index].data() as Map<String, dynamic>;

    final title =
        data['title']?.toString() ?? 'Unknown Product';

    final barcode =
        data['barcode']?.toString() ?? '';

    final image =
        data['imageUrl']?.toString() ?? '';

    final marketValue =
        data['price']?.toString() ?? '';

    print('History marketValue = $marketValue');

    final scanned =
        data['scannedAt'];

    String scannedText = '';

    if (scanned is Timestamp) {
      scannedText =
          scanned.toDate().toString().substring(0, 16);
    }

    return Card(
      color: const Color(0xFF242424),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
  final product = Product.fromMap(data);
  final favorite = isFavorite(product);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailPage(
        product: product,
        isFavorite: favorite,
        onFavoriteToggle: () {
          toggleFavorite(product);
        },
      ),
    ),
  );
},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.inventory,
                          color: Colors.white54,
                        ),
                      ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),
                                     
                    if (marketValue.isNotEmpty)
                     Text(
  '\$${(double.tryParse(
    marketValue
        .replaceAll('\$', '')
        .replaceAll('Market Value', '')
        .trim(),
  ) ?? 0).toStringAsFixed(2)} Market Value',
  style: const TextStyle(
    color: Colors.greenAccent,
    fontWeight: FontWeight.w600,
  ),
),

                    if (barcode.isNotEmpty)
                      Text(
                        barcode,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                      ),

                    if (scannedText.isNotEmpty)
                      Text(
                        scannedText,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
    },
  );
}

// ======================================================
// ALERTS SCREEN
// ======================================================

String formatMonitorDateTime(
  DateTime? dateTime,
) {
  if (dateTime == null) {
    return 'Never';
  }

  final localDateTime =
      dateTime.toLocal();

  final month =
      localDateTime.month
          .toString()
          .padLeft(
            2,
            '0',
          );

  final day =
      localDateTime.day
          .toString()
          .padLeft(
            2,
            '0',
          );

  final year =
      localDateTime.year;

  final hour =
      localDateTime.hour;

  final minute =
      localDateTime.minute
          .toString()
          .padLeft(
            2,
            '0',
          );

  final displayHour =
      hour == 0
          ? 12
          : hour > 12
              ? hour - 12
              : hour;

  final period =
      hour >= 12
          ? 'PM'
          : 'AM';

  return '$month/$day/$year '
      '$displayHour:$minute $period';
}

Map<String, dynamic> getPriceProximityInfo(
  ProductMonitor monitor,
) {
  final difference =
      monitor.lastMarketValue -
      monitor.targetPrice;

  if (difference <= 0) {
    return {
      'message': 'Target reached!',
      'color': Colors.greenAccent,
    };
  }

  final percentAbove =
      (difference / monitor.targetPrice) * 100;

  if (percentAbove <= 10) {
    return {
      'message':
          '\$${difference.toStringAsFixed(2)} above target',
      'color': Colors.yellowAccent,
    };
  }

  if (percentAbove <= 25) {
    return {
      'message':
          '${percentAbove.toStringAsFixed(0)}% above target',
      'color': Colors.orangeAccent,
    };
  }

  return {
    'message': 'Far from target',
    'color': Colors.redAccent,
  };
}

Future<void> openMonitorMarketplace(
  ProductMonitor monitor,
) async {
  if (monitor.marketplace == 'eBay') {
    final searchUrl =
        'https://www.ebay.com/sch/i.html?_nkw='
        '${Uri.encodeComponent(monitor.productTitle)}';

    final uri =
        Uri.parse(
      searchUrl,
    );

    final opened =
        await launchUrl(
      uri,
      mode:
          LaunchMode.externalApplication,
    );

    if (!opened &&
        mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open eBay.',
          ),
        ),
      );
    }

    return;
  }

  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      content: Text(
        '${monitor.marketplace} opening is not configured yet.',
      ),
    ),
 );
  }

  Future<void> runAutomaticMonitorCycle() async {
  try {
    final monitors =
        await productMonitorService
            .watchMonitors()
            .first;

    final activeMonitors =
    monitors
        .where(
          (monitor) =>
              monitor.isActive &&
              !(
                monitor.marketplace ==
                    'eBay' &&
                isEbayCoolingDown
              ),
        )
        .toList();

if (isEbayCoolingDown) {
  debugPrint(
    'MARKETPLACE COOLDOWN ACTIVE | '
    'eBay | '
    'skipping automatic checks until '
    '$ebayCooldownUntil',
  );
}

    debugPrint(
      'AUTOMATIC MONITOR CYCLE | '
      'active=${activeMonitors.length}',
    );

    await monitorQueueService
    .process<ProductMonitor>(
  items: activeMonitors,
  delayBetweenItems:
      const Duration(
    seconds: 2,
  ),
  onProcess:
      (monitor) async {
    try {
      
      final result =
    await monitoringEngineService
        .checkMonitor(
      monitor,
    );

if (!result.isAvailable) {
  debugPrint(
    'MONITOR LISTING UNAVAILABLE | '
    'product=${monitor.productTitle} | '
    'itemId=${monitor.marketplaceItemId}',
  );
  
await productMonitorService
    .recordListingUnavailable(
  monitorId: monitor.id,
  checkedAt: result.checkedAt,
);

  return;
}

if (monitor.marketplaceItemId.isNotEmpty &&
    monitor.listingUnavailable) {
  await productMonitorService
      .recordListingAvailableAgain(
    monitorId: monitor.id,
    checkedAt: result.checkedAt,
  );
}

await productMonitorService
    .recordSuccessfulCheck(
        monitorId:
            monitor.id,
        marketValue:
            result.currentMarketValue,
        checkedAt:
            result.checkedAt,
      );

      final alertConditionMet =
          monitor.shouldTriggerAlert(
        result.currentMarketValue,
      );

      final newlyTriggered =
          alertConditionMet &&
          !monitor.alertConditionMet;

      await productMonitorService
          .recordAlertEvaluation(
        monitorId:
            monitor.id,
        alertConditionMet:
            alertConditionMet,
        newlyTriggered:
            newlyTriggered,
      );

      if (newlyTriggered) {
        await notificationService
            .notifyTargetReached(
          productTitle:
              monitor.productTitle,
          marketplace:
              monitor.marketplace,
          targetPrice:
              monitor.targetPrice,
          currentMarketValue:
              result.currentMarketValue,
        );
      }

      debugPrint(
        'AUTO CHECK COMPLETE | '
        '${monitor.productTitle} | '
        '\$${result.currentMarketValue.toStringAsFixed(2)}',
      );
    } catch (e) {
      debugPrint(
        'AUTO CHECK FAILED | '
        '${monitor.productTitle} | '
        '$e',
      );

      rethrow;
    }
  },
  onFinalFailure:
    (monitor, error) async {
      
  ebayCooldownUntil =
      DateTime.now().add(
    const Duration(
      minutes: 5,
    ),
  );

  debugPrint(
    'MARKETPLACE COOLDOWN | '
    'eBay | '
    'until=$ebayCooldownUntil | '
    'product=${monitor.productTitle} | '
    'error=$error',
  );
},
);
      
  } catch (e) {
    debugPrint(
      'AUTOMATIC MONITOR CYCLE FAILED | $e',
    );
  }
}

Future<void> checkMonitorNow(
  ProductMonitor monitor,
) async {
  if (!monitor.isActive) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Resume this price alert before checking it.',
        ),
      ),
    );

    return;
  }

  try {
    final result =
        await monitoringEngineService
            .checkMonitor(
      monitor,
    );

if (!result.isAvailable) {
  debugPrint(
    'MONITOR LISTING UNAVAILABLE | '
    'product=${monitor.productTitle} | '
    'itemId=${monitor.marketplaceItemId}',
  );

  return;
}

    await productMonitorService
        .recordSuccessfulCheck(
      monitorId:
          monitor.id,
      marketValue:
          result.currentMarketValue,
      checkedAt:
          result.checkedAt,
    );

final alertConditionMet =
    monitor.shouldTriggerAlert(
  result.currentMarketValue,
);

final newlyTriggered =
    alertConditionMet &&
    !monitor.alertConditionMet;

await productMonitorService
    .recordAlertEvaluation(
  monitorId:
      monitor.id,
  alertConditionMet:
      alertConditionMet,
  newlyTriggered:
      newlyTriggered,
);

if (newlyTriggered) {
  await notificationService
      .notifyTargetReached(
    productTitle:
        monitor.productTitle,
    marketplace:
        monitor.marketplace,
    targetPrice:
        monitor.targetPrice,
    currentMarketValue:
        result.currentMarketValue,
  );
}

if (!mounted) {
  return;
}

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
  newlyTriggered
      ? 'Target reached! Current market: '
          '\$${result.currentMarketValue.toStringAsFixed(2)}'
      : 'Price check complete: '
          '\$${result.currentMarketValue.toStringAsFixed(2)}',
),
      ),
    );
  } catch (e) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Price check failed: $e',
        ),
      ),
    );
  }
}

Future<void> showEditTargetPriceDialog(
  ProductMonitor monitor,
) async {
  final targetPriceController =
      TextEditingController(
    text: monitor.targetPrice
        .toStringAsFixed(2),
  );

  final updatedTargetPrice =
      await showDialog<double>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor:
            const Color(
          0xFF1E1E1E,
        ),
        title: const Text(
          'Edit Target Price',
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              monitor.productTitle,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  targetPriceController,
              autofocus: true,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter
                    .allow(
                  RegExp(
                    r'^\d*\.?\d{0,2}',
                  ),
                ),
              ],
              decoration:
                  const InputDecoration(
                labelText:
                    'New Target Price',
                prefixText: '\$',
                helperText:
                    'Alert me when the eBay market value reaches this price or lower.',
                border:
                    OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
              );
            },
            child: const Text(
              'Cancel',
            ),
          ),

          ElevatedButton(
            onPressed: () {
              final targetPrice =
                  double.tryParse(
                targetPriceController
                    .text
                    .trim(),
              );

              if (targetPrice ==
                      null ||
                  targetPrice <= 0) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter a valid target price.',
                    ),
                  ),
                );

                return;
              }

              Navigator.pop(
                dialogContext,
                targetPrice,
              );
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.deepPurple,
              foregroundColor:
                  Colors.white,
            ),
            child: const Text(
              'Save',
            ),
          ),
        ],
      );
    },
  );

  targetPriceController.dispose();

  if (updatedTargetPrice ==
      null) {
    return;
  }

  try {
    await productMonitorService
        .updateTargetPrice(
      monitorId: monitor.id,
      targetPrice:
          updatedTargetPrice,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Target price updated to '
          '\$${updatedTargetPrice.toStringAsFixed(2)}.',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Could not update target price: $e',
        ),
      ),
    );
  }
}

Widget buildAlertsScreen() {
  return StreamBuilder<
      List<ProductMonitor>>(
    stream:
        productMonitorService
            .watchMonitors(),
    builder: (
      context,
      snapshot,
    ) {
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding:
                const EdgeInsets.all(
              24,
            ),
            child: Text(
              'Price alerts failed to load:\n'
              '${snapshot.error}',
              textAlign:
                  TextAlign.center,
            ),
          ),
        );
      }

      if (snapshot.connectionState ==
          ConnectionState.waiting) {
        return const Center(
          child:
              CircularProgressIndicator(),
        );
      }

      final monitors =
          snapshot.data ??
          const <ProductMonitor>[];

final unreadTriggeredCount =
    monitors
        .where(
          (monitor) =>
              monitor.alertConditionMet &&
              !monitor.isAcknowledged,
        )
        .length;

      if (monitors.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons
                    .notifications_active,
                size: 64,
                color:
                    Colors.deepPurple,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                'Price Alerts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'No monitored products yet.',
                style: TextStyle(
                  color:
                      Colors.white70,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
  children: [
    Padding(
  padding: const EdgeInsets.fromLTRB(
    16,
    12,
    16,
    0,
  ),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(
      14,
    ),
    decoration: BoxDecoration(
      color: const Color(
        0xFF1E1E1E,
      ),
      borderRadius:
          BorderRadius.circular(
        14,
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              monitorSchedulerService
                      .isRunning
                  ? Icons
                      .autorenew
                  : Icons
                      .pause_circle_outline,
              color:
                  monitorSchedulerService
                          .isRunning
                      ? Colors
                          .greenAccent
                      : Colors
                          .orange,
            ),
            const SizedBox(
              width: 8,
            ),
            const Text(
              'Automatic Monitoring',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          monitorSchedulerService
                  .isRunning
              ? 'Status: Running'
              : 'Status: Stopped',
          style: TextStyle(
            color:
                monitorSchedulerService
                        .isRunning
                    ? Colors
                        .greenAccent
                    : Colors
                        .orange,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          'Last Automatic Scan: '
          '${formatMonitorDateTime(
            monitorSchedulerService
                .lastRun,
          )}',
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),

        Text(
          'Next Automatic Scan: '
          '${formatMonitorDateTime(
            monitorSchedulerService
                .nextRun,
          )}',
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
if (isEbayCoolingDown)
  
  Text(
    'eBay Cooldown Until: '
    '${formatMonitorDateTime(
      ebayCooldownUntil,
    )}',
    style: const TextStyle(
      color: Colors.orangeAccent,
      fontWeight:
          FontWeight.w600,
    ),
  ),

        Text(
          'Interval: '
          '${monitorSchedulerService.interval?.inMinutes ?? 0} '
          'minute(s)',
          style: const TextStyle(
            color: Colors.white54,
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(
  height: 4,
),

    if (unreadTriggeredCount > 0)
      Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          0,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () async {
              try {
                await productMonitorService
                    .acknowledgeAllTriggeredAlerts();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'All alerts dismissed.',
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Could not dismiss all alerts: $e',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.done_all),
            label: Text(
              'Dismiss All ($unreadTriggeredCount)',
            ),
          ),
        ),
      ),

    Expanded(
      child: ListView.builder(
        padding:
            const EdgeInsets.all(
          16,
        ),
        itemCount:
            monitors.length,
        itemBuilder: (
          context,
          index,
        ) {
          final monitor =
              monitors[index];

          return Card(
            color:
                const Color(
              0xFF1E1E1E,
            ),
            margin:
                const EdgeInsets.only(
              bottom: 14,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: InkWell(
  onTap: () {
    openMonitorMarketplace(
      monitor,
    );
  },
  borderRadius:
      BorderRadius.circular(
    14,
  ),
  child: Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                    child: monitor
                            .imagePath
                            .startsWith(
                          'http',
                        )
                        ? Image.network(
                            monitor
                                .imagePath,
                            width: 72,
                            height: 72,
                            fit: BoxFit
                                .contain,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                width: 72,
                                height: 72,
                                color: Colors
                                    .grey
                                    .shade800,
                                child:
                                    const Icon(
                                  Icons
                                      .inventory,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 72,
                            height: 72,
                            color: Colors
                                .grey
                                .shade800,
                            child:
                                const Icon(
                              Icons
                                  .inventory,
                            ),
                          ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          monitor
                              .productTitle,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          'Target: '
                          '\$${monitor.targetPrice.toStringAsFixed(2)} '
                          'or below',
                          style:
                              const TextStyle(
                            color: Colors
                                .deepPurpleAccent,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                       Text(
  'Current Market: '
  '\$${monitor.lastMarketValue.toStringAsFixed(2)}',
  style: const TextStyle(
    color: Colors.white70,
  ),
),

const SizedBox(
  height: 4,
),

Builder(
  builder: (context) {
    final proximity =
        getPriceProximityInfo(
      monitor,
    );

    return Row(
      children: [
        Icon(
          Icons.track_changes,
          size: 16,
          color:
              proximity['color']
                  as Color,
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          proximity['message']
              as String,
          style: TextStyle(
            color:
                proximity['color']
                    as Color,
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  },
),

const SizedBox(
  height: 8,
),

if (monitor.listingUnavailable) ...[
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.orange.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.orangeAccent,
      ),
    ),
    child: const Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Colors.orangeAccent,
          size: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Listing Unavailable',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ),
  
  if (!monitor.listingUnavailableAcknowledged)
  Align(
    alignment: Alignment.centerRight,
    child: TextButton.icon(
      onPressed: () async {
        try {
          await productMonitorService
              .acknowledgeListingUnavailable(
            monitor.id,
          );

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Listing unavailable alert dismissed.',
              ),
            ),
          );
        } catch (e) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not dismiss listing alert: $e',
              ),
            ),
          );
        }
      },
      icon: const Icon(
        Icons.done,
        size: 18,
      ),
      label: const Text('Dismiss'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.orangeAccent,
      ),
    ),
  ),
  const SizedBox(height: 8),
],

Text(
  'Created: '
  '${formatMonitorDateTime(monitor.createdAt)}',
  style: const TextStyle(
    color: Colors.white54,
    fontSize: 12,
  ),
),

Text(
  'Last Checked: '
  '${formatMonitorDateTime(monitor.lastCheckedAt)}',
  style: const TextStyle(
    color: Colors.white54,
    fontSize: 12,
  ),
),

Text(
  'Last Alerted: '
  '${formatMonitorDateTime(monitor.lastAlertedAt)}',
  style: const TextStyle(
    color: Colors.white54,
    fontSize: 12,
  ),
),

                        const SizedBox(
                          height: 6,
                        ),

                        Row(
  children: [
    Icon(
      monitor.isActive
          ? Icons.check_circle
          : Icons.pause_circle,
      size: 18,
      color: monitor.isActive
          ? Colors.greenAccent
          : Colors.orange,
    ),

    const SizedBox(
      width: 6,
    ),

    Text(
      monitor.isActive
          ? 'Active'
          : 'Paused',
      style: TextStyle(
        color: monitor.isActive
            ? Colors.greenAccent
            : Colors.orange,
        fontWeight:
            FontWeight.bold,
      ),
    ),

    const Spacer(),

    TextButton.icon(
      onPressed: () async {
        try {
          await productMonitorService
              .updateActiveState(
            monitorId:
                monitor.id,
            isActive:
                !monitor.isActive,
          );

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                monitor.isActive
                    ? 'Price alert paused.'
                    : 'Price alert resumed.',
              ),
            ),
          );
        } catch (e) {
          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                'Could not update alert: $e',
              ),
            ),
          );
        }
      },
      icon: Icon(
        monitor.isActive
            ? Icons.pause
            : Icons.play_arrow,
        size: 18,
      ),
      label: Text(
        monitor.isActive
            ? 'Pause'
            : 'Resume',
      ),
      style: TextButton.styleFrom(
        foregroundColor:
            monitor.isActive
                ? Colors.orange
                : Colors.greenAccent,
      ),
   ), // TextButton.icon

IconButton(
  tooltip: 'Check Now',
  icon: const Icon(
    Icons.refresh,
    color: Colors.lightBlueAccent,
  ),
  onPressed: () {
    checkMonitorNow(
      monitor,
    );
  },
),

if (monitor.alertConditionMet &&
    !monitor.isAcknowledged)
  TextButton.icon(
    onPressed: () async {
      try {
        await productMonitorService
            .acknowledgeAlert(
          monitor.id,
        );

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Alert dismissed.',
            ),
          ),
        );
      } catch (e) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Could not dismiss alert: $e',
            ),
          ),
        );
      }
    },
    icon: const Icon(
      Icons.done,
      size: 18,
    ),
    label: const Text(
      'Dismiss',
    ),
    style: TextButton.styleFrom(
      foregroundColor:
          Colors.greenAccent,
    ),
  ),

IconButton(
  tooltip: 'Edit Target Price',
  icon: const Icon(
    Icons.edit_outlined,
    color: Colors.deepPurpleAccent,
  ),
  onPressed: () {
    showEditTargetPriceDialog(
      monitor,
    );
  },
),

IconButton(
  tooltip: 'Delete Alert',
  icon: const Icon(
    Icons.delete_outline,
    color: Colors.redAccent,
  ),
  onPressed: () async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(
            0xFF1E1E1E,
          ),
          title: const Text(
            'Delete Price Alert?',
          ),
          content: Text(
            'Delete the alert for\n\n'
            '${monitor.productTitle}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color:
                      Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await productMonitorService
          .deleteMonitor(
        monitor.id,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Price alert deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed: $e',
          ),
        ),
      );
    }
  },
),

    const SizedBox(
      width: 8,
    ),

    Text(
      monitor.marketplace,
      style: const TextStyle(
        color: Colors.white54,
      ),
    ),
  ],
),
                      ],
                    ),
                  ),
                ],
              ),
            ),
         ), // InkWell
       ); // Card
        },
      ), // ListView.builder
), // Expanded
], // Column children
); // Column
    },
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

              child: product.imagePath.startsWith('http')
    ? Image.network(
        product.imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: 70,
            height: 70,
            color: Colors.grey.shade800,
            child: const Icon(
              Icons.image,
              color: Colors.grey,
            ),
          );
        },
      )
    : Image.asset(
        product.imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: 70,
            height: 70,
            color: Colors.grey.shade800,
            child: const Icon(
              Icons.image,
              color: Colors.grey,
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
    extends StatefulWidget {
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

  @override
  State<ProductDetailPage>
      createState() =>
          _ProductDetailPageState();
}

class _ProductDetailPageState
    extends State<ProductDetailPage> {
  late bool productIsFavorite;

  final TextEditingController
    buyPriceController =
        TextEditingController();

        final TextEditingController
    buyerShippingController =
        TextEditingController();

final TextEditingController
    buyerFeesController =
        TextEditingController();

final TextEditingController
    salesTaxController =
        TextEditingController();

final ProductMonitorService
    productMonitorService =
    ProductMonitorService();

ProductMonitor? pendingProductMonitor;

final MercariMarketplaceService
    mercariMarketplaceService =
    MercariMarketplaceService();

final GoatMarketplaceService
    goatMarketplaceService =
    GoatMarketplaceService();

final StockxMarketplaceService
    stockxMarketplaceService =
    StockxMarketplaceService();

final EtsyMarketplaceService
    etsyMarketplaceService =
    EtsyMarketplaceService();

final AlibabaMarketplaceService
    alibabaMarketplaceService =
    AlibabaMarketplaceService();

final FacebookMarketplaceService
    facebookMarketplaceService =
    FacebookMarketplaceService();

final OfferUpMarketplaceService
    offerUpMarketplaceService =
    OfferUpMarketplaceService();

final DepopMarketplaceService
    depopMarketplaceService =
    DepopMarketplaceService();

final GrailedMarketplaceService
    grailedMarketplaceService =
    GrailedMarketplaceService();

final WhatnotMarketplaceService
    whatnotMarketplaceService =
    WhatnotMarketplaceService();

final DiscogsMarketplaceService
    discogsMarketplaceService =
    DiscogsMarketplaceService();

final ReverbMarketplaceService
    reverbMarketplaceService =
    ReverbMarketplaceService();

final TCGplayerMarketplaceService
    tcgplayerMarketplaceService =
    TCGplayerMarketplaceService();

final Chrono24MarketplaceService
    chrono24MarketplaceService =
    Chrono24MarketplaceService();

final TheRealRealMarketplaceService
    theRealRealMarketplaceService =
    TheRealRealMarketplaceService();

final PoshmarkMarketplaceService
    poshmarkMarketplaceService =
    PoshmarkMarketplaceService();

@override
void dispose() {
  buyPriceController.dispose();
  buyerShippingController.dispose();
  buyerFeesController.dispose();
  salesTaxController.dispose();
  super.dispose();
}

  double get marketValue {
    final cleaned =
        widget.product.price
            .replaceAll(RegExp(r'[^0-9.]'), '');

    return double.tryParse(cleaned) ?? 0;
  }

  double get buyPrice {
    return double.tryParse(
          buyPriceController.text,
        ) ??
        0;
  }

double get buyerShipping {
  return double.tryParse(
        buyerShippingController.text,
      ) ??
      0;
}

double get buyerFees {
  return double.tryParse(
        buyerFeesController.text,
      ) ??
      0;
}

double get salesTax {
  return double.tryParse(
        salesTaxController.text,
      ) ??
      0;
}

  final DealIntelligenceService 
    dealIntelligenceService =
    DealIntelligenceService();

  final PriceHistoryService 
    priceHistoryService =
    PriceHistoryService();

  final HistoricalIntelligenceService
    historicalIntelligenceService =
    HistoricalIntelligenceService();

  final ResellRadarVerdictService
    resellRadarVerdictService =
    ResellRadarVerdictService();

late Future<List<PriceSnapshot>> priceHistoryFuture;

@override
void initState() {
  super.initState();

  productIsFavorite =
      widget.isFavorite;

  final currentUser =
      FirebaseAuth.instance.currentUser;

  final productKey =
      priceHistoryService.createProductKey(
    widget.product.title,
  );

  priceHistoryFuture =
      currentUser != null
          ? priceHistoryService.loadSnapshots(
              userId: currentUser.uid,
              productKey: productKey,
            )
          : Future.value(
              <PriceSnapshot>[],
            );
}

    DealIntelligence get dealIntelligence {
      return dealIntelligenceService.evaluate(
        marketValue: marketValue,
        purchasePrice: buyPrice,
        buyerShipping: buyerShipping,
        buyerFees: buyerFees,
        salesTax: salesTax,
        estimatedFees: estimatedFees,
        estimatedShipping:
        estimatedShipping,
    confidence: confidence,
  );
}

double get dealScore {
  if (buyPrice <= 0) {
    return 0;
  }

  return dealIntelligence.dealScore;
}

String get dealRecommendation {
  if (buyPrice <= 0) {
    return 'Enter Buy Price';
  }

  return dealIntelligence.recommendation;
}

String get opportunityTier {
  if (buyPrice <= 0) {
    return 'Unranked';
  }

  return dealIntelligence.opportunityTier;
}

double get suggestedBuyPrice {
  return dealIntelligenceService
      .calculateSuggestedBuyPrice(
    marketValue: marketValue,
    estimatedFees: estimatedFees,
    estimatedShipping:
        estimatedShipping,
  );
}

double get suggestedResalePrice {
  if (buyPrice <= 0) {
    return 0;
  }

  return dealIntelligenceService
      .calculateSuggestedResalePrice(
    purchasePrice: buyPrice,
    estimatedShipping:
        estimatedShipping,
  );
}

double get estimatedFees {
    return marketValue * 0.13;
  }

  double get estimatedShipping {
    return buyPrice > 0 ? 5.00 : 0;
  }

  double get netProfit {
  if (buyPrice <= 0) {
    return 0;
  }

  return dealIntelligence.estimatedProfit;
}

  double get roi {
  if (buyPrice <= 0) {
    return 0;
  }

  return dealIntelligence.roiPercent;
}

String get confidence {
  if (widget.product.resultCount >= 10) {
    return 'High';
  }

  if (widget.product.resultCount >= 5) {
    return 'Medium';
  }

  if (widget.product.resultCount >= 2) {
    return 'Low';
  }

  if (widget.product.resultCount == 1) {
    return 'Very Low';
  }

  return 'Unknown';
}

Future<void>
    showSetPriceAlertDialog() async {
  final targetPriceController =
      TextEditingController();

  final selectedTargetPrice =
      await showDialog<double>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor:
            const Color(
          0xFF1E1E1E,
        ),
        title: const Text(
          'Set Price Alert',
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.title,
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller:
                  targetPriceController,
              autofocus: true,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter
                    .allow(
                  RegExp(
                    r'^\d*\.?\d{0,2}',
                  ),
                ),
              ],
              decoration:
                  const InputDecoration(
                labelText:
                    'Target Price',
                prefixText: '\$',
                helperText:
                    'Alert me when the eBay market value reaches this price or lower.',
                border:
                    OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
              );
            },
            child: const Text(
              'Cancel',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final targetPrice =
                  double.tryParse(
                targetPriceController
                    .text
                    .trim(),
              );

              if (targetPrice ==
                      null ||
                  targetPrice <= 0) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter a valid target price.',
                    ),
                  ),
                );

                return;
              }

              Navigator.pop(
                dialogContext,
                targetPrice,
              );
            },
            style:
                ElevatedButton
                    .styleFrom(
              backgroundColor:
                  Colors.deepPurple,
              foregroundColor:
                  Colors.white,
            ),
            child: const Text(
              'Continue',
            ),
          ),
        ],
      );
    },
  );

  targetPriceController.dispose();

  if (selectedTargetPrice ==
      null) {
    return;
  }

  final monitor =
    ProductMonitor(
      productTitle:
          widget.product.title,
      barcode:
          widget.product.barcode,
      imagePath:
          widget.product.imagePath,
      marketplace: 'eBay',
      marketplaceItemId:
          widget.product.marketplaceItemId,
      targetPrice:
          selectedTargetPrice,
      comparisonType:
          'atOrBelow',
      lastMarketValue:
          marketValue,
    );

setState(() {
  pendingProductMonitor =
      monitor;
});

try {
  await productMonitorService
      .saveMonitor(
    monitor,
  );

  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      content: Text(
        'Price alert set for \$${selectedTargetPrice.toStringAsFixed(2)} or below.',
      ),
    ),
  );
} catch (e) {
  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      content: Text(
        'Could not save price alert: $e',
      ),
    ),
  );
}
}

  Future<void> openMarketplace(
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
  final comparableIntelligence =
      ComparableIntelligenceService.analyze(
    rawItems: widget.product.rawItems,
    targetTitle: widget.product.title,
    marketValue: double.tryParse(
          widget.product.price
              .replaceAll('\$', '')
              .replaceAll(',', '')
              .trim(),
        ) ??
        0,
  );

  return Scaffold(
      backgroundColor:
          const Color(0xFF121212),

      appBar: AppBar(
  backgroundColor:
      const Color(0xFF1E1E1E),
  title: Text(
    widget.product.title,
  ),
  actions: [
    IconButton(
      tooltip: productIsFavorite
          ? 'Remove from Watchlist'
          : 'Add to Watchlist',
      onPressed: () {
        widget.onFavoriteToggle();

        setState(() {
          productIsFavorite =
              !productIsFavorite;
        });
      },
      icon: Icon(
        productIsFavorite
            ? Icons.favorite
            : Icons.favorite_border,
        color: productIsFavorite
            ? Colors.red
            : Colors.white70,
      ),
    ),
  ],
),

      body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(20),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),

              child: widget.product.imagePath
                      .startsWith('http')
                  ? Image.network(
                      widget.product.imagePath,
                      width:
                          double.infinity,
                      height: 260,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          width:
                              double.infinity,
                          height: 260,
                          color: Colors
                              .grey.shade800,
                          child:
                              const Icon(
                            Icons.image,
                            size: 80,
                            color:
                                Colors.grey,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      widget.product.imagePath,
                      width:
                          double.infinity,
                      height: 260,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          width:
                              double.infinity,
                          height: 260,
                          color: Colors
                              .grey.shade800,
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
              widget.product.title,
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
  '\$${marketValue.toStringAsFixed(2)} Market Value',
  style: const TextStyle(
    color: Colors.greenAccent,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 8,
),

            Text(
              'Projected Profit: ${widget.product.percentage}',
              style:
                  const TextStyle(
                color: Colors.orange,
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              widget.product.description,
              style:
                  const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 20,
            ),
if (widget.product.resultCount > 0)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valuation Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        Text(
          'Lowest Price: \$${widget.product.lowestPrice.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white70),
        ),

        Text(
          'Average Price: \$${widget.product.averagePrice.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white70),
        ),

        Text(
          'Median Price: \$${widget.product.medianPrice.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white70),
        ),
        Text(
          'Highest Price: \$${widget.product.highestPrice.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white70),
        ),

        Text(
          'Price Spread: \$${widget.product.priceSpread.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white70),
        ),
        Text(
          'Listings Checked: ${widget.product.resultCount}',
          style: const TextStyle(color: Colors.white70),
        ),
        Text(
  'Confidence: $confidence',
  style: TextStyle(
    color: confidence == 'High'
    ? Colors.greenAccent
    : confidence == 'Medium'
        ? Colors.orange
        : confidence == 'Low'
            ? Colors.deepOrangeAccent
            : Colors.redAccent,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton.icon(
    onPressed:
        showSetPriceAlertDialog,
    icon: const Icon(
      Icons.notifications_active,
    ),
    label: const Text(
      'Set Price Alert',
    ),
    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          Colors.deepPurple,
      foregroundColor:
          Colors.white,
    ),
  ),
),

const SizedBox(
  height: 20,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.only(top: 20),
  decoration: BoxDecoration(
    color: const Color(0xFF1E1E1E),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/amazon.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    const Expanded(
      child: Text(
        'Amazon Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

      const SizedBox(height: 10),

      Text(
  'Amazon Mode: Search Link\n'
  'Live Amazon Price: Not connected yet\n'
  'Availability: ${widget.product.amazonAvailability.isNotEmpty ? widget.product.amazonAvailability : "Open Amazon to view current offers"}\n'
  'Barcode: ${widget.product.barcode}',
  style: const TextStyle(
    color: Colors.white70,
    height: 1.5,
  ),
),

      const SizedBox(height: 16),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      final cleanedQuery =
          MarketplaceQueryCleaner.clean(
        widget.product.title,
      );

      final amazonSearchTerm =
          cleanedQuery.isNotEmpty
              ? cleanedQuery
              : widget.product.barcode;

      final fallbackAmazonUrl =
          'https://www.amazon.com/s?k='
          '${Uri.encodeQueryComponent(amazonSearchTerm)}'
          '&tag=resellradar-20';

      final amazonUrl =
          widget.product.amazonUrl.isNotEmpty
              ? widget.product.amazonUrl
              : fallbackAmazonUrl;

      openMarketplace(
        amazonUrl,
      );
    },
    icon: const Icon(
      Icons.shopping_cart,
    ),
    label: const Text(
      'Open on Amazon',
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor:
          Colors.orange,
    ),
  ),
),
],
),
),

const SizedBox(height: 20),
      ],
    ),
  ),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.only(
    bottom: 20,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
     Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/mercari.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    const Expanded(
      child: Text(
        'Mercari Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

      const SizedBox(
        height: 10,
      ),

      const Text(
        'Mercari Mode: Search Link\n'
        'Live Mercari Price: Not connected\n'
        'Open Mercari to view current listings.',
        style: TextStyle(
          color: Colors.white70,
          height: 1.5,
        ),
      ),

      const SizedBox(
        height: 16,
      ),

      SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      final result =
          await mercariMarketplaceService
              .searchByQuery(
        widget.product.title,
      );

      if (!mounted) {
        return;
      }

      if (result.canOpenMarketplace) {
        await openMarketplace(
          result.url,
        );
      }
    },
    icon: const Icon(
      Icons.storefront,
    ),
    label: const Text(
      'Open on Mercari',
    ),
    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          Colors.redAccent,
    ),
  ),
),
    ],
  ),
),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  margin: const EdgeInsets.only(
    bottom: 20,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/goat_head.svg',
      width: 24,
      height: 24,
      colorFilter:
          const ColorFilter.mode(
        Colors.white,
        BlendMode.srcIn,
      ),
    ),
    const SizedBox(
      width: 8,
    ),
    const Expanded(
      child: Text(
        'GOAT Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    ),
  ],
),

      const SizedBox(
        height: 10,
      ),

      const Text(
        'GOAT Mode: Search Link\n'
        'Live GOAT Price: Not connected\n'
        'Open GOAT to view current listings.',
        style: TextStyle(
          color: Colors.white70,
          height: 1.5,
        ),
      ),

      const SizedBox(
        height: 16,
      ),

      SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      final result =
          await goatMarketplaceService
              .searchByQuery(
        widget.product.title,
      );

      if (!mounted) {
        return;
      }

      if (result.canOpenMarketplace) {
        await openMarketplace(
          result.url,
        );
      }
    },
    icon: const Icon(
      Icons.local_mall,
    ),
    label: const Text(
      'Open on GOAT',
    ),
    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          Colors.grey.shade700,
    ),
  ),
),
    ],
  ),
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  margin: const EdgeInsets.only(
    bottom: 20,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
     Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/stockx.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    const Expanded(
      child: Text(
        'StockX Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

      const SizedBox(
        height: 10,
      ),

      const Text(
        'StockX Mode: Search Link\n'
        'Live StockX Price: Not connected\n'
        'Open StockX to view current products and pricing.',
        style: TextStyle(
          color: Colors.white70,
          height: 1.5,
        ),
      ),

      const SizedBox(
        height: 16,
      ),

      SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      final result =
          await stockxMarketplaceService
              .searchByQuery(
        widget.product.title,
      );

      if (!mounted) {
        return;
      }

      if (result.canOpenMarketplace) {
        await openMarketplace(
          result.url,
        );
      }
    },
    icon: const Icon(
      Icons.trending_up,
    ),
    label: const Text(
      'Open on StockX',
    ),
    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          Colors.green.shade700,
    ),
 ), // ElevatedButton.icon
), // SizedBox
], // Column children
), // Column
), // Container

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  margin: const EdgeInsets.only(
    bottom: 20,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/etsy.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    const Expanded(
      child: Text(
        'Etsy Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

      const SizedBox(
        height: 10,
      ),

      const Text(
        'Etsy Mode: Search Link\n'
        'Live Etsy Price: Not connected\n'
        'Open Etsy to view current listings and pricing.',
        style: TextStyle(
          color: Colors.white70,
          height: 1.5,
        ),
      ),

      const SizedBox(
        height: 16,
      ),

      SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      final result =
          await etsyMarketplaceService
              .searchByQuery(
        widget.product.title,
      );

      if (!mounted) {
        return;
      }

      if (result.canOpenMarketplace) {
        await openMarketplace(
          result.url,
        );
      }
    },
    icon: const Icon(
      Icons.storefront,
    ),
    label: const Text(
      'Open on Etsy',
    ),
    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          Colors.deepOrange,
    ),
  ),
),
    ],
  ),
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  margin: const EdgeInsets.only(
    bottom: 20,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/poshmark.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    const Expanded(
      child: Text(
        'Poshmark Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

      const SizedBox(
        height: 10,
      ),

      const Text(
        'Poshmark Mode: Search Link\n'
        'Live Poshmark Price: Not connected\n'
        'Open Poshmark to view current listings and pricing.',
        style: TextStyle(
          color: Colors.white70,
          height: 1.5,
        ),
      ),

      const SizedBox(
        height: 16,
      ),

      SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      final result =
          await poshmarkMarketplaceService
              .searchByQuery(
        widget.product.title,
      );

      if (!mounted) {
        return;
      }

      if (result.canOpenMarketplace) {
        await openMarketplace(
          result.url,
        );
      }
    },
    icon: const Icon(
      Icons.sell,
    ),
    label: const Text(
      'Open on Poshmark',
    ),
    style:
        ElevatedButton.styleFrom(
      backgroundColor:
          const Color(
        0xFF7A1832,
      ),
    ),
  ),
),
    ],
  ),
),

Card(
  margin: const EdgeInsets.only(
    top: 16,
  ),
  child: Padding(
    padding: const EdgeInsets.all(
      16,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/alibaba.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    const Expanded(
      child: Text(
        'Alibaba Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
        const SizedBox(
          height: 8,
        ),
        const Text(
          'Alibaba Mode: Search Link',
        ),
        const Text(
          'Live Alibaba Price: Not connected',
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          'Open Alibaba to view current supplier listings and pricing.',
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result =
                  await alibabaMarketplaceService
                      .searchByQuery(
                widget.product.title,
              );

              await openMarketplace(
                result.url,
              );
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFFFF6A00,
              ),
              foregroundColor:
                  Colors.white,
            ),
            icon: const Icon(
              Icons.factory,
            ),
            label: const Text(
              'Open on Alibaba',
            ),
          ),
        ),
      ],
    ),
  ),
),

Card(
  margin: const EdgeInsets.only(
    top: 16,
  ),
  child: Padding(
    padding: const EdgeInsets.all(
      16,
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/facebook_marketplace.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    const Expanded(
      child: Text(
        'Facebook Marketplace',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
        const SizedBox(
          height: 8,
        ),
        const Text(
          'Facebook Mode: Search Link',
        ),
        const Text(
          'Live Facebook Price: Not connected',
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          'Open Facebook Marketplace to view local listings. Facebook may require you to log in before browsing.',
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result =
                  await facebookMarketplaceService
                      .searchByQuery(
                widget.product.title,
              );

              await openMarketplace(
                result.url,
              );
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF1877F2,
              ),
              foregroundColor:
                  Colors.white,
            ),
            icon: const Icon(
              Icons.facebook,
            ),
            label: const Text(
              'Open on Facebook Marketplace',
            ),
          ),
        ),
      ],
    ),
  ),
),
const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
 decoration: BoxDecoration(
  color: const Color(0xFF1E1E1E),
  borderRadius:
      BorderRadius.circular(
    16,
  ),
),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          SvgPicture.asset(
  'assets/icons/marketplaces/offerup.svg',
  width: 24,
  height: 24,
),
const SizedBox(
  width: 8,
),
          Expanded(
            child: Text(
  'OfferUp Marketplace',
  style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
  'Search OfferUp for local listings matching this product.',
  style: TextStyle(
    color: Colors.white70,
  ),
),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await offerUpMarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result.canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on OfferUp',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFF00A87E,
            ),
            foregroundColor:
                Colors.white,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/depop.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    Expanded(
      child: Text(
        'Depop Marketplace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
        'Search Depop for fashion, sneakers, vintage items, and accessories.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await depopMarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result.canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on Depop',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFFFF3E5B,
            ),
            foregroundColor:
                Colors.white,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/grailed.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    Expanded(
      child: Text(
        'Grailed Marketplace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
        'Search Grailed for sneakers, streetwear, designer fashion, and accessories.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await grailedMarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result.canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on Grailed',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                Colors.black,
            foregroundColor:
                Colors.white,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/whatnot.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    Expanded(
      child: Text(
        'Whatnot Marketplace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
        'Search Whatnot for collectibles, sneakers, cards, and live marketplace listings. Login may be required.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await whatnotMarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result.canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on Whatnot',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFFFF5A36,
            ),
            foregroundColor:
                Colors.white,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/discogs.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    Expanded(
      child: Text(
        'Discogs Marketplace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
        'Search Discogs for vinyl records, CDs, cassettes, and other music collectibles.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await discogsMarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result.canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on Discogs',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                Colors.black,
            foregroundColor:
                Colors.white,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/reverb.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    Expanded(
      child: Text(
        'Reverb Marketplace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
        'Search Reverb for guitars, pedals, keyboards, drums, microphones, and other music gear.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await reverbMarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result.canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on Reverb',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFFFF5500,
            ),
            foregroundColor:
                Colors.white,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/tcgplayer.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    Expanded(
      child: Text(
        'TCGplayer Marketplace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
        'Search TCGplayer for Pokémon, Magic: The Gathering, Yu-Gi-Oh!, sports cards, and other collectibles.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await tcgplayerMarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result.canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on TCGplayer',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFF0B5FAA,
            ),
            foregroundColor:
                Colors.white,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
  children: [
    SvgPicture.asset(
      'assets/icons/marketplaces/chrono24.svg',
      width: 24,
      height: 24,
    ),
    const SizedBox(
      width: 8,
    ),
    Expanded(
      child: Text(
        'Chrono24 Marketplace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
        'Search Chrono24 for Rolex, Omega, Patek Philippe, Tudor, TAG Heuer, and other luxury watches.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await chrono24MarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result.canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on Chrono24',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFFC9A227,
            ),
            foregroundColor:
                Colors.black,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(
      0xFF1E1E1E,
    ),
    borderRadius:
        BorderRadius.circular(
      16,
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Row(
       children: [
  SvgPicture.asset(
    'assets/icons/marketplaces/therealreal.svg',
    width: 24,
    height: 24,
  ),
  const SizedBox(
    width: 8,
  ),
  Expanded(
    child: Text(
      'The RealReal Marketplace',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 8,
      ),
      const Text(
        'Search The RealReal for authenticated designer fashion, handbags, jewelry, watches, art, and luxury accessories.',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(
        height: 12,
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final result =
                await theRealRealMarketplaceService
                    .searchByQuery(
              widget.product.title,
            );

            if (!mounted) {
              return;
            }

            if (result
                .canOpenMarketplace) {
              await openMarketplace(
                result.url,
              );
            }
          },
          icon: const Icon(
            Icons.open_in_new,
          ),
          label: const Text(
            'Open on The RealReal',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFFFC9A27,
            ),
            foregroundColor:
                Colors.black,
          ),
        ),
      ),
    ],
  ),
),

if (comparableIntelligence != null &&
    comparableIntelligence.relevantItems.isNotEmpty)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.lightBlueAccent.withValues(
          alpha: 0.35,
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comparable Intelligence',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Comps Analyzed: ${comparableIntelligence.comparableCount}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          'Range: \$${comparableIntelligence.lowPrice.toStringAsFixed(2)}'
          ' – \$${comparableIntelligence.highPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          'Average: \$${comparableIntelligence.averagePrice.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          'Median: \$${comparableIntelligence.medianPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          'Price Spread: \$${comparableIntelligence.priceSpread.toStringAsFixed(2)}'
          ' (${comparableIntelligence.spreadPercent.toStringAsFixed(1)}%)',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          'Comp Consistency: ${comparableIntelligence.consistency}',
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
  'Relevant Comps: ${comparableIntelligence.relevantComparableCount}',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

Text(
  'Excluded Comps: ${comparableIntelligence.excludedComparableCount}',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

Text(
  'Relevance Quality: ${comparableIntelligence.relevanceQuality}',
  style: TextStyle(
    color: comparableIntelligence.relevanceQuality == 'Strong'
        ? Colors.greenAccent
        : comparableIntelligence.relevanceQuality == 'Moderate'
            ? Colors.orangeAccent
            : Colors.redAccent,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(
  height: 6,
),

Text(
  'Valuation Basis: ${comparableIntelligence.valuationBasis}',
  style: const TextStyle(
    color: Colors.cyanAccent,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 12),

const Text(
  'Market Value Evidence',
  style: TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 4),

Text(
  comparableIntelligence.consistency == 'Wide'
      ? '\$${marketValue.toStringAsFixed(2)} is closely compared against '
          'the \$${comparableIntelligence.medianPrice.toStringAsFixed(2)} comparable median. '
          'Because comparable prices are widely dispersed, the median is used '
          'as the stronger valuation reference.'
      : '\$${marketValue.toStringAsFixed(2)} is closely compared against '
          'the \$${comparableIntelligence.averagePrice.toStringAsFixed(2)} comparable average. '
          'Because comparable prices are reasonably consistent, the average is '
          'used as the primary valuation reference.',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 13,
    height: 1.35,
  ),
),
      ],
    ),
  ),
  
if (comparableIntelligence?.relevantItems.isNotEmpty ?? false)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comparable Listings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        ...(comparableIntelligence?.relevantItems ?? const <dynamic>[])
    .take(5)
    .map((item) {
          final title = item['title'] ?? 'eBay Listing';
          final price = item['price']?['value'] ?? 'N/A';

         final url = item['itemWebUrl'] ?? '';

return Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: InkWell(
    onTap: url.isNotEmpty
        ? () {
            openMarketplace(url);
          }
        : null,
    child: Text(
      '\$$price — $title',
      style: const TextStyle(
        color: Colors.lightBlueAccent,
        decoration: TextDecoration.underline,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  ),
);
        }),
      ],
    ),
  ),
            TextField(
              controller:
                  buyPriceController,
              keyboardType:
                  TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration:
                  InputDecoration(
                labelText:
                    'Enter Buy Price',
                labelStyle:
                    const TextStyle(
                  color: Colors.white70,
                ),
                prefixText: '\$',
                prefixStyle:
                    const TextStyle(
                  color: Colors.white,
                ),
                filled: true,
                fillColor:
                    const Color(0xFF1E1E1E),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(
  height: 10,
),

Row(
  children: [
    Expanded(
      child: TextField(
        controller:
            buyerShippingController,
        keyboardType:
            TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration:
            InputDecoration(
          labelText:
              'Buyer Shipping',
          labelStyle:
              const TextStyle(
            color: Colors.white70,
          ),
          prefixText: '\$',
          prefixStyle:
              const TextStyle(
            color: Colors.white,
          ),
          filled: true,
          fillColor:
              const Color(
            0xFF1E1E1E,
          ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    ),
    const SizedBox(
      width: 10,
    ),
    Expanded(
      child: TextField(
        controller:
            buyerFeesController,
        keyboardType:
            TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration:
            InputDecoration(
          labelText:
              'Buyer Fees',
          labelStyle:
              const TextStyle(
            color: Colors.white70,
          ),
          prefixText: '\$',
          prefixStyle:
              const TextStyle(
            color: Colors.white,
          ),
          filled: true,
          fillColor:
              const Color(
            0xFF1E1E1E,
          ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    ),
    const SizedBox(
      width: 10,
    ),
    Expanded(
      child: TextField(
        controller:
            salesTaxController,
        keyboardType:
            TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration:
            InputDecoration(
          labelText:
              'Sales Tax',
          labelStyle:
              const TextStyle(
            color: Colors.white70,
          ),
          prefixText: '\$',
          prefixStyle:
              const TextStyle(
            color: Colors.white,
          ),
          filled: true,
          fillColor:
              const Color(
            0xFF1E1E1E,
          ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    ),
  ],
),

const SizedBox(
  height: 16,
),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF1E1E1E),
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Estimated Selling Fees: \$${estimatedFees.toStringAsFixed(2)}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                  Text(
                    'Estimated Seller Shipping: \$${estimatedShipping.toStringAsFixed(2)}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                  const SizedBox(
  height: 8,
),

const Text(
  'Deal Economics Breakdown',
  style: TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  buyPrice > 0
      ? 'True Acquisition Cost: '
          '\$${dealIntelligence.trueAcquisitionCost.toStringAsFixed(2)}'
      : 'True Acquisition Cost: —',
  style: const TextStyle(
    color: Colors.lightBlueAccent,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  ),
),

const SizedBox(
  height: 2,
),

Text(
  buyPrice > 0
      ? 'Buy \$${buyPrice.toStringAsFixed(2)}'
          '  +  Buyer Shipping \$${buyerShipping.toStringAsFixed(2)}'
          '  +  Buyer Fees \$${buyerFees.toStringAsFixed(2)}'
          '  +  Tax \$${salesTax.toStringAsFixed(2)}'
      : 'Enter a buy price to calculate acquisition costs.',
  style: const TextStyle(
    color: Colors.white60,
    fontSize: 12,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  'Expected Sale: \$${marketValue.toStringAsFixed(2)}',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

Text(
  'Net Sale Proceeds: '
  '\$${(marketValue - estimatedFees - estimatedShipping).toStringAsFixed(2)}',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

const SizedBox(
  height: 8,
),
                  Text(
                    buyPrice > 0
    ? 'Net Profit: \$${netProfit.toStringAsFixed(2)}'
    : 'Net Profit: —',
                    style:
                        TextStyle(
                      color: netProfit >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Text(
                    buyPrice > 0
    ? 'ROI: ${roi.toStringAsFixed(1)}%'
    : 'ROI: —',
                    style:
                        const TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
  height: 8,
),

Text(
  buyPrice > 0
    ? 'Deal Score: ${dealScore.toStringAsFixed(0)} / 100'
    : 'Deal Score: —',
  style: TextStyle(
    color: dealScore >= 75
        ? Colors.greenAccent
        : dealScore >= 50
            ? Colors.orangeAccent
            : Colors.redAccent,
    fontSize: 18,
    fontWeight:
        FontWeight.bold,
  ),
),
const SizedBox(
  height: 6,
),

Text(
  'Deal Economics Assessment',
  style: TextStyle(
    color: Colors.white70,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  ),
),
const SizedBox(
  height: 4,
),

Text(
  'Recommendation: $dealRecommendation',
  style: TextStyle(
    color: dealRecommendation == 'BUY NOW'
        ? Colors.greenAccent
        : dealRecommendation == 'GOOD DEAL'
            ? Colors.lightGreenAccent
            : dealRecommendation == 'WAIT'
                ? Colors.orangeAccent
                : dealRecommendation == 'HIGH RISK'
                    ? Colors.deepOrangeAccent
                    : Colors.redAccent,
    fontSize: 18,
    fontWeight:
        FontWeight.bold,
  ),
),

const SizedBox(
  height: 6,
),

Text(
  'Opportunity Tier: $opportunityTier',
  style: TextStyle(
    color: opportunityTier == 'S'
        ? Colors.greenAccent
        : opportunityTier == 'A'
            ? Colors.lightGreenAccent
            : opportunityTier == 'B'
                ? Colors.cyanAccent
                : opportunityTier == 'C'
                    ? Colors.orangeAccent
                    : opportunityTier == 'D'
                        ? Colors.deepOrangeAccent
                        : Colors.redAccent,
    fontSize: 18,
    fontWeight:
        FontWeight.bold,
  ),
),

const SizedBox(
  height: 6,
),

FutureBuilder<List<PriceSnapshot>>(
  future: priceHistoryFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState ==
        ConnectionState.waiting) {
      return const Text(
        'Market Trend: Loading...',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (snapshot.hasError) {
      return const Text(
        'Market Trend: Unavailable',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final snapshots =
        snapshot.data ??
        <PriceSnapshot>[];

    final trend =
        priceHistoryService
            .calculateMarketTrend(
      snapshots,
    );

    final changePercent =
        priceHistoryService
            .calculateMarketChangePercent(
      snapshots,
    );

    final trendColor =
        trend == 'Rising'
            ? Colors.greenAccent
            : trend == 'Falling'
                ? Colors.redAccent
                : trend == 'Stable'
                    ? Colors.orangeAccent
                    : Colors.white70;

    final trendSymbol =
        trend == 'Rising'
            ? '↑'
            : trend == 'Falling'
                ? '↓'
                : trend == 'Stable'
                    ? '→'
                    : '';

    final trendText =
        trend == 'Not Enough Data'
            ? 'Market Trend: Not Enough Data'
            : 'Market Trend: '
                '$trend $trendSymbol '
                '${changePercent >= 0 ? '+' : ''}'
                '${changePercent.toStringAsFixed(1)}%';

    return Text(
      trendText,
      style: TextStyle(
        color: trendColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  },
),

const SizedBox(
  height: 6,
),

FutureBuilder<List<PriceSnapshot>>(
  future: priceHistoryFuture,
  builder: (context, snapshot) {
    final snapshots =
        snapshot.data ?? <PriceSnapshot>[];

    if (snapshots.isEmpty) {
  return const Text(
    'Price History: No saved observations yet',
    style: TextStyle(
      color: Colors.white70,
      fontSize: 16,
    ),
  );
}

final historicalPosition =
    historicalIntelligenceService
        .calculatePricePosition(
  snapshots,
);

final resellRadarVerdict =
    historicalPosition != null
        ? ResellRadarVerdictService().evaluate(
            deal: dealIntelligence,
            historical: historicalPosition,
            comparable: comparableIntelligence,
          )
        : null;

final latestRecordedAt =
    snapshots[0].recordedAt.toLocal();

final latestMonth =
    latestRecordedAt.month
        .toString()
        .padLeft(2, '0');

final latestDay =
    latestRecordedAt.day
        .toString()
        .padLeft(2, '0');

final latestHour =
    latestRecordedAt.hour > 12
        ? latestRecordedAt.hour - 12
        : latestRecordedAt.hour == 0
            ? 12
            : latestRecordedAt.hour;

final latestMinute =
    latestRecordedAt.minute
        .toString()
        .padLeft(2, '0');

final latestAmPm =
    latestRecordedAt.hour >= 12
        ? 'PM'
        : 'AM';

final latestRecordedText =
    '$latestMonth/$latestDay/${latestRecordedAt.year} '
    '$latestHour:$latestMinute $latestAmPm';

final latest =
    snapshots[0].marketValue;

    if (snapshots.length == 1) {
      return Text(
  'Price History: Latest \$${latest.toStringAsFixed(2)} '
  '(1 observation)\n'
  'Last Recorded: $latestRecordedText',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
      );
    }

    final previous = snapshots[1].marketValue;

    return Column(
  crossAxisAlignment:
      CrossAxisAlignment.start,
  children: [
    Text(
      'Price History: '
      'Latest \$${latest.toStringAsFixed(2)} | '
      'Previous \$${previous.toStringAsFixed(2)} '
      '(${snapshots.length} observations)\n'
      'Last Recorded: $latestRecordedText',
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),
    const SizedBox(
      height: 8,
    ),
    const Text(
  'Historical Intelligence',
  style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 8,
),
    PriceHistorySparkline(
  snapshots: snapshots,
),

const SizedBox(
  height: 10,
),
if (resellRadarVerdict != null) ...[
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(
      16,
    ),
    decoration: BoxDecoration(
      color: Colors.blueGrey
          .withValues(
        alpha: 0.16,
      ),
      borderRadius:
          BorderRadius.circular(
        12,
      ),
      border: Border.all(
        color: Colors.lightBlueAccent
            .withValues(
          alpha: 0.55,
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Resell Radar Verdict',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          resellRadarVerdict
              .verdictLabel,
          style: TextStyle(
            color:
                resellRadarVerdict
                            .verdictLabel ==
                        'STRONG BUY'
                    ? Colors.greenAccent
                    : resellRadarVerdict
                                .verdictLabel ==
                            'BUY'
                        ? Colors.greenAccent
                        : resellRadarVerdict
                                    .verdictLabel ==
                                'PROCEED WITH CAUTION'
                            ? Colors.orangeAccent
                            : resellRadarVerdict
                                        .verdictLabel ==
                                    'PASS'
                                ? Colors.redAccent
                                : resellRadarVerdict
                                            .verdictLabel ==
                                        'MARGINS TOO THIN'
                                    ? Colors.orangeAccent
                                    : Colors.lightBlueAccent,
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          resellRadarVerdict
              .verdictMessage,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
  'Deal Strength: '
  '${resellRadarVerdict.dealStrengthLabel}'
  '  •  Historical Support: '
  '${resellRadarVerdict.historicalSupportLabel}'
  '  •  Comparable Support: '
'${comparableIntelligence?.evidenceStrength.toUpperCase() ?? 'UNKNOWN'}'
' ${comparableIntelligence?.relevantComparableCount ?? 0} comps'
' • ${comparableIntelligence?.consistency.toUpperCase() ?? 'UNKNOWN'} spread)',
  style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          'Deal Score: '
          '${resellRadarVerdict.dealScore.toStringAsFixed(0)}'
          ' / 100'
          '  •  Historical Confidence: '
          '${resellRadarVerdict.historicalConfidence}',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    ),
  ),
  const SizedBox(
    height: 10,
  ),
],

if (historicalPosition != null) ...[
  Container(
  width: double.infinity,
  padding: const EdgeInsets.all(
    14,
  ),
  decoration: BoxDecoration(
    color: Colors.deepPurple
        .withValues(
      alpha: 0.16,
    ),
    borderRadius:
        BorderRadius.circular(
      12,
    ),
    border: Border.all(
      color: Colors.deepPurpleAccent
          .withValues(
        alpha: 0.45,
      ),
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      const Text(
        'Historical Decision Summary',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight:
              FontWeight.bold,
        ),
      ),

      const SizedBox(
        height: 8,
      ),

      Text(
        historicalPosition
            .entryTimingLabel,
        style: TextStyle(
          color:
              historicalPosition
                          .entryTimingLabel ==
                      'FAVORABLE'
                  ? Colors.greenAccent
                  : historicalPosition
                              .entryTimingLabel ==
                          'WAIT FOR PULLBACK'
                      ? Colors.redAccent
                      : historicalPosition
                                      .entryTimingLabel ==
                                  'WAIT' ||
                              historicalPosition
                                      .entryTimingLabel ==
                                  'EARLY DATA'
                          ? Colors.orangeAccent
                          : Colors
                              .lightBlueAccent,
          fontSize: 22,
          fontWeight:
              FontWeight.bold,
        ),
      ),

      const SizedBox(
        height: 6,
      ),

      Text(
        historicalPosition
            .entryTimingMessage,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.4,
        ),
      ),

      const SizedBox(
        height: 8,
      ),

      Text(
        'Confidence: '
        '${historicalPosition.confidenceLabel}'
        '  •  Risk: '
        '${historicalPosition.riskLabel}'
        '  •  Phase: '
        '${historicalPosition.pricePhaseLabel}',
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 13,
          fontWeight:
              FontWeight.w600,
        ),
      ),
      const SizedBox(
  height: 6,
),

Text(
  'Key Drivers: '
  '${historicalPosition.buyZoneLabel}'
  '  •  Momentum: '
  '${historicalPosition.momentumLabel}',
  style: const TextStyle(
    color: Colors.white54,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  ),
),
    ],
  ),
),

const SizedBox(
  height: 10,
),

Theme(
  data: Theme.of(context).copyWith(
    dividerColor: Colors.transparent,
  ),
  child: ExpansionTile(
  tilePadding: EdgeInsets.zero,
 childrenPadding: const EdgeInsets.only(
  left: 16,
  right: 8,
  bottom: 6,
),
  expandedCrossAxisAlignment:
      CrossAxisAlignment.start,
    initiallyExpanded: false,
    iconColor: Colors.lightBlueAccent,
    collapsedIconColor: Colors.lightBlueAccent,
    title: const Text(
      'View Historical Details',
      style: TextStyle(
        color: Colors.lightBlueAccent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: const Text(
  'Supporting price-history metrics',
  style: TextStyle(
    color: Colors.white54,
    fontSize: 12,
  ),
),
shape: const Border(
  top: BorderSide(
    color: Colors.white12,
  ),
  bottom: BorderSide(
    color: Colors.white12,
  ),
),

collapsedShape: const Border(
  top: BorderSide(
    color: Colors.white12,
  ),
  bottom: BorderSide(
    color: Colors.white12,
  ),
),
    children: [

  Text(
    'Historical Position: '
    '${historicalPosition.label}',
    style: const TextStyle(
      color: Colors.lightBlueAccent,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(
    height: 4,
  ),

  Text(
    '${historicalPosition.positionPercent.toStringAsFixed(0)}% '
    'through observed range '
    '(\$${historicalPosition.historicalLow.toStringAsFixed(2)}'
    ' – '
    '\$${historicalPosition.historicalHigh.toStringAsFixed(2)})',
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 14,
    ),
  ),
  const SizedBox(
  height: 8,
),

Text(
  'Historical Signal: '
  '${historicalPosition.actionLabel}',
  style: TextStyle(
    color:
        historicalPosition.actionLabel ==
                'BUYING WINDOW'
            ? Colors.greenAccent
            : historicalPosition.actionLabel ==
                    'CAUTION'
                ? Colors.redAccent
                : historicalPosition.actionLabel ==
                        'WATCH'
                    ? Colors.orangeAccent
                    : Colors.white70,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

const SizedBox(
  height: 4,
),

Text(
  historicalPosition.actionMessage,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

const SizedBox(
  height: 8,
),

Text(
  'Historical Confidence: '
  '${historicalPosition.confidenceLabel}',
  style: TextStyle(
    color:
        historicalPosition.confidenceLabel ==
                'HIGH'
            ? Colors.greenAccent
            : historicalPosition.confidenceLabel ==
                    'MODERATE'
                ? Colors.orangeAccent
                : Colors.redAccent,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  historicalPosition.confidenceMessage,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),
const SizedBox(
  height: 8,
),

Text(
  'Historical Average: '
  '\$${historicalPosition.historicalAverage.toStringAsFixed(2)}',
  style: const TextStyle(
    color: Colors.lightBlueAccent,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  'Current vs. Average: '
  '${historicalPosition.differenceFromAverage >= 0 ? '+' : '-'}'
  '\$${historicalPosition.differenceFromAverage.abs().toStringAsFixed(2)} '
  '('
  '${historicalPosition.percentFromAverage >= 0 ? '+' : ''}'
  '${historicalPosition.percentFromAverage.toStringAsFixed(1)}%'
  ')',
  style: TextStyle(
    color:
        historicalPosition.differenceFromAverage < 0
            ? Colors.greenAccent
            : historicalPosition.differenceFromAverage > 0
                ? Colors.redAccent
                : Colors.white70,
    fontSize: 14,
  ),
),
const SizedBox(
  height: 8,
),

Text(
  'Historical Volatility: '
  '${historicalPosition.volatilityLabel}',
  style: TextStyle(
    color:
        historicalPosition.volatilityLabel ==
                'LOW'
            ? Colors.greenAccent
            : historicalPosition.volatilityLabel ==
                    'MODERATE'
                ? Colors.orangeAccent
                : Colors.redAccent,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  'Volatility: '
  '${historicalPosition.volatilityPercent.toStringAsFixed(1)}%',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),
const SizedBox(
  height: 8,
),

Text(
  'Historical Risk: '
  '${historicalPosition.riskLabel}',
  style: TextStyle(
    color:
        historicalPosition.riskLabel == 'LOW'
            ? Colors.greenAccent
            : historicalPosition.riskLabel == 'MODERATE'
                ? Colors.orangeAccent
                : Colors.redAccent,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  historicalPosition.riskMessage,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),
const SizedBox(
  height: 10,
),

Text(
  'Historical Price Cushion: '
  '${historicalPosition.priceCushionLabel}',
  style: TextStyle(
    color:
        historicalPosition.priceCushionLabel == 'STRONG'
            ? Colors.greenAccent
            : historicalPosition.priceCushionLabel == 'MODERATE'
                ? Colors.lightGreenAccent
                : historicalPosition.priceCushionLabel == 'LIMITED'
                    ? Colors.orangeAccent
                    : Colors.white70,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  '${historicalPosition.priceCushionPercent.toStringAsFixed(1)}% below observed historical high',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),
const SizedBox(
  height: 10,
),

Text(
  'Historical Buy Zone: '
  '${historicalPosition.buyZoneLabel}',
  style: TextStyle(
    color:
        historicalPosition.buyZoneLabel == 'BUY ZONE'
            ? Colors.greenAccent
            : historicalPosition.buyZoneLabel == 'EXPENSIVE ZONE'
                ? Colors.redAccent
                : historicalPosition.buyZoneLabel == 'EARLY DATA'
                    ? Colors.orangeAccent
                    : Colors.lightBlueAccent,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  historicalPosition.buyZoneMessage,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),
const SizedBox(
  height: 10,
),

Text(
  'Historical Momentum: '
  '${historicalPosition.momentumLabel}',
  style: TextStyle(
    color:
        historicalPosition.momentumLabel ==
                    'STRONG UPWARD' ||
                historicalPosition.momentumLabel ==
                    'UPWARD'
            ? Colors.greenAccent
            : historicalPosition.momentumLabel ==
                        'STRONG DOWNWARD' ||
                    historicalPosition.momentumLabel ==
                        'DOWNWARD'
                ? Colors.redAccent
                : historicalPosition.momentumLabel ==
                        'EARLY DATA'
                    ? Colors.orangeAccent
                    : Colors.white70,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  'Recent Momentum: '
  '${historicalPosition.momentumPercent >= 0 ? '+' : ''}'
  '${historicalPosition.momentumPercent.toStringAsFixed(1)}%',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  historicalPosition.momentumMessage,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),
const SizedBox(
  height: 10,
),

Text(
  'Historical Trajectory: '
  '${historicalPosition.trajectoryLabel}',
  style: TextStyle(
    color:
        historicalPosition.trajectoryLabel ==
                    'STRONG UPWARD' ||
                historicalPosition.trajectoryLabel ==
                    'UPWARD'
            ? Colors.greenAccent
            : historicalPosition.trajectoryLabel ==
                        'STRONG DOWNWARD' ||
                    historicalPosition.trajectoryLabel ==
                        'DOWNWARD'
                ? Colors.redAccent
                : historicalPosition.trajectoryLabel ==
                        'EARLY DATA'
                    ? Colors.orangeAccent
                    : Colors.white70,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  'Overall Change: '
  '${historicalPosition.trajectoryPercent >= 0 ? '+' : ''}'
  '${historicalPosition.trajectoryPercent.toStringAsFixed(1)}%',
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  historicalPosition.trajectoryMessage,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),
const SizedBox(
  height: 10,
),

Text(
  'Historical Price Phase: '
  '${historicalPosition.pricePhaseLabel}',
  style: TextStyle(
    color:
        historicalPosition.pricePhaseLabel == 'ADVANCING' ||
                historicalPosition.pricePhaseLabel == 'RECOVERING'
            ? Colors.greenAccent
            : historicalPosition.pricePhaseLabel == 'DECLINING' ||
                    historicalPosition.pricePhaseLabel == 'REVERSING'
                ? Colors.redAccent
                : historicalPosition.pricePhaseLabel == 'PLATEAUING' ||
                        historicalPosition.pricePhaseLabel == 'STABILIZING'
                    ? Colors.orangeAccent
                    : historicalPosition.pricePhaseLabel == 'EARLY DATA'
                        ? Colors.orangeAccent
                        : Colors.white70,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(
  height: 4,
),

Text(
  historicalPosition.pricePhaseMessage,
  style: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
),

const SizedBox(
  height: 14,
),
],
  ),
),
 ],
  ]
    );
   }, // Column
), // FutureBuilder

Text(
  'Max Buy Price for 30% ROI: '
  '\$${suggestedBuyPrice.toStringAsFixed(2)}',
  style: const TextStyle(
    color: Colors.lightBlueAccent,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(
  height: 6,
),

Text(
  'Target Resale Price for 30% ROI: '
  '\$${suggestedResalePrice.toStringAsFixed(2)}',
  style: const TextStyle(
    color: Colors.cyanAccent,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
                ],
              ),
            ),

           const SizedBox(height: 20),

Row(
  children: [
    Expanded(
      child: SizedBox(
        height: 55,
        child: ElevatedButton.icon(
  onPressed: () {
    openMarketplace(widget.product.marketplaceUrl);
  },
  icon: const Icon(Icons.shopping_cart),
  label: const Text('Open On Ebay'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
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
      
  final Future<void> Function(Product)
      saveScanHistory;

  const ScannerPage({
    super.key,
    required this.barcodeDatabase,
    required this.isFavorite,
    required this.toggleFavorite,
    required this.saveScanHistory,
  });

  @override
  State<ScannerPage>
      createState() =>
          _ScannerPageState();
}

class _ScannerPageState
    extends State<ScannerPage> {
String? pendingBarcode;
int pendingBarcodeCount = 0;
  bool scanned = false;

final PriceHistoryService
    priceHistoryService =
    PriceHistoryService();

  void resetScanner() {

    Future.delayed(
      const Duration(
        milliseconds: 1200,
      ),
      () {

        if (mounted) {

         setState(() {
  scanned = false;
  pendingBarcode = null;
  pendingBarcodeCount = 0;
});
        }
      },
    );
  }
  Future<void> savePriceHistorySnapshot(
  Product product,
) async {
  final currentUser =
      FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return;
  }

  final parsedMarketValue =
      double.tryParse(
        product.price
            .replaceAll(
              RegExp(r'[^0-9.]'),
              '',
            ),
      ) ??
      0;

  if (parsedMarketValue <= 0) {
    return;
  }

  final snapshot =
      priceHistoryService.createSnapshot(
    marketValue: parsedMarketValue,
    lowestPrice: product.lowestPrice,
    averagePrice: product.averagePrice,
    medianPrice: product.medianPrice,
    highestPrice: product.highestPrice,
    listingsChecked:
        product.resultCount,
    confidence:
        product.resultCount >= 10
            ? 'High'
            : product.resultCount >= 5
                ? 'Medium'
                : product.resultCount >= 2
                    ? 'Low'
                    : product.resultCount == 1
                        ? 'Very Low'
                        : 'Unknown',
  );

  final productKey =
      priceHistoryService
          .createProductKey(
    product.title,
  );

  await priceHistoryService
      .saveSnapshot(
    userId: currentUser.uid,
    productKey: productKey,
    snapshot: snapshot,
  );
}

  Future<void> lookupManualBarcode(String code) async {
  Product? matchedProduct;

  try {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/ebay-lookup/$code'),
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      final productData = data['product'];
   
      matchedProduct = Product(
  title: productData['name'] ?? 'Unknown Product',
  price: productData['marketPrice'].toString(),
  percentage: productData['profitPotential'] ?? '+0%',
  imagePath: productData['image'] ?? '',

  marketplaceUrl:
      productData['marketplaceUrl'] ?? 'https://www.ebay.com/',

  amazonUrl:
      productData['amazonUrl'] ?? '',

  amazonTitle:
      productData['amazonTitle'] ?? '',

  amazonDisplayPrice:
      productData['amazonDisplayPrice'] ?? '',

  amazonAvailability:
      productData['amazonAvailability'] ?? '',

  description:
    'Live marketplace data retrieved from backend.',

barcode: code,
marketplaceItemId:
    productData['itemId']?.toString() ?? '',
scannedAt: DateTime.now().toIso8601String(),

lowestPrice: (productData['lowestPrice'] as num?)?.toDouble() ?? 0,
  averagePrice: (productData['averagePrice'] as num?)?.toDouble() ?? 0,
  medianPrice: (productData['medianPrice'] as num?)?.toDouble() ?? 0,
  highestPrice: (productData['highestPrice'] as num?)?.toDouble() ?? 0,
  priceSpread: (productData['priceSpread'] as num?)?.toDouble() ?? 0,
  resultCount: (productData['resultCount'] as num?)?.toInt() ?? 0,
  rawItems: data['rawItems'] ?? productData['rawItems'] ?? const [],
);

      await widget.saveScanHistory(matchedProduct);

      await savePriceHistorySnapshot(
  matchedProduct,
);

    }
  } catch (e) {
    print('MANUAL LOOKUP ERROR: $e');
  }

  if (!mounted) return;

  if (matchedProduct != null) {
    final product = matchedProduct;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
          isFavorite: widget.isFavorite(product),
          onFavoriteToggle: () {
            widget.toggleFavorite(product);
          },
        ),
      ),
    ).then((_) {
      resetScanner();
    });
  } else {
    resetScanner();
  }
}
void showManualBarcodeDialog() {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        'Enter Barcode',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'ISBN / UPC',
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);

            final code = controller.text.trim();

            if (code.isNotEmpty) {
              setState(() {
                scanned = true;
              });

              lookupManualBarcode(code);
            }
          },
          child: const Text('Search'),
        ),
      ],
    ),
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
            onDetect: (capture) async {

              if (scanned) {
                return;
              }

              final List<Barcode>
                  barcodes =
                  capture.barcodes;

              for (final barcode
    in barcodes) {

  String code =
    barcode.rawValue ?? '';

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

if (code.length != 12 &&
    code.length != 13 &&
    code.length != 14) {
  return;
}

if (pendingBarcode != code) {
  pendingBarcode = code;
  pendingBarcodeCount = 1;
  return;
}

pendingBarcodeCount++;

if (pendingBarcodeCount < 2) {
  return;
}

setState(() {
  scanned = true;
});

pendingBarcode = null;
pendingBarcodeCount = 0;

if (!mounted) return;

Product? matchedProduct;

// =====================================================
// LIVE BACKEND LOOKUP
// =====================================================

try {

  final response =
      await http.get(

    Uri.parse(
      '$backendBaseUrl/ebay-lookup/$code',
    ),
  );

  final data =
      jsonDecode(
        response.body,
      );

  if (data['success'] ==
      true) {

    final productData =
        data['product'];
    final amazonResponse = await http.get(
  Uri.parse('$backendBaseUrl/amazon-lookup/$code'),
);

final amazonData = jsonDecode(amazonResponse.body);

final amazonProductData = amazonData['success'] == true
    ? amazonData['product']
    : null;
    matchedProduct =
    Product(
  title:
    productData['name'] ??
    'Unknown Product',

price:
    '\$${productData['marketPrice']} Market Value',

percentage:
    productData['profitPotential'] ??
    '+0%',

imagePath:
    productData['image'] ?? '',

marketplaceUrl:
    productData['marketplaceUrl'] ??
    'https://www.ebay.com/',

amazonUrl:
    amazonProductData?['amazonUrl'] ??
    productData['amazonUrl'] ??
    '',

amazonTitle:
    amazonProductData?['title'] ?? '',

amazonDisplayPrice:
    amazonProductData?['displayPrice'] ?? '',

amazonAvailability:
    amazonProductData?['availability'] ?? '',

description:
    'Live marketplace data retrieved from backend.',

barcode:
    code,

scannedAt:
    DateTime.now().toIso8601String(),

lowestPrice:
    (productData['lowestPrice']
            as num?)
        ?.toDouble() ??
    0,

averagePrice:
    (productData['averagePrice']
            as num?)
        ?.toDouble() ??
    0,

medianPrice:
    (productData['medianPrice']
            as num?)
        ?.toDouble() ??
    0,
  
highestPrice:
    (productData['highestPrice'] as num?)
        ?.toDouble() ??
    0,

priceSpread:
    (productData['priceSpread'] as num?)
        ?.toDouble() ??
    0,

resultCount:
    (productData['resultCount']
        as num?)
        ?.toInt() ??
    0,

rawItems:
    data['rawItems'] ??
    productData['rawItems'] ??
    const [],
);

await widget.saveScanHistory(
  matchedProduct,
);

await savePriceHistorySnapshot(
  matchedProduct,
);
  }

} catch (e) {

  print(
    'BACKEND ERROR: $e',
  );
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
    onPressed: () {
      Navigator.pop(context);
      resetScanner();
    },
    child: const Text(
      'Scan Again',
    ),
  ),

  TextButton(
    onPressed: () {
      Navigator.pop(context);
      showManualBarcodeDialog();
    },
    child: const Text(
      'Enter Manually',
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