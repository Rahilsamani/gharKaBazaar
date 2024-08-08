import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/favorite_provider.dart';
import '../../vendor/authentication/vendor_login_Screen.dart';
import '../../vendor/screens/vendor_main_screen.dart';
import 'authentication_screens/login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late Widget nextScreen = LoginScreen();

  @override
  void initState() {
    super.initState();
    loadNextScreen();
    updateFavProvider();
  }

  @override
  void dispose() {
    // Dispose any resources or cancel any ongoing operations here
    super.dispose();
  }

  Future<void> loadNextScreen() async {
    nextScreen = await whereToGo();
    if (mounted) {
      setState(() {}); // Update the state only if the widget is still mounted
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/app_logo.jpeg'),
        ],
      ),
      splashIconSize: 400,
      duration: 500,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(milliseconds: 1000),
      nextScreen: nextScreen,
    );
  }

  // fetch all the product details from product Id
  Future<Map<String, dynamic>?> getProductDetailsById(String productId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> productDoc =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .get();

      return productDoc.data();
    } catch (error) {
      print('Error fetching product details by ID: $error');
      return null;
    }
  }

  Future<void> updateFavProvider() async {
    try {
      // Fetch cart data including product IDs, size, quantity, and additional details
      List<Map<String, dynamic>> favData = await getFavData();

      // Iterate over each cart item
      for (Map<String, dynamic> favItem in favData) {
        String productId = favItem['productId'];

        // Add the product details to the CartNotifier
        ref.read(favoriteProvider.notifier).addProductToFavorite(
            productName: favItem['productName'],
            productId: productId,
            imageUrl: favItem['imageUrl'],
            price: favItem['price'],
            productSize: favItem['productSize'],
            discountPrice: favItem['discountPrice']);
      }
    } catch (error) {
      print('Error fetching and initializing product details: $error');
    }
  }

  // fetch the cart data
  Future<List<Map<String, dynamic>>> getFavData() async {
    List<Map<String, dynamic>> favData = [];

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('buyers')
            .doc(user.uid)
            .get();

        List<dynamic>? favProductIds = userDoc['favouriteProducts'];

        if (favProductIds != null) {
          // Iterate through the 'favouriteProducts' array
          for (String productId in favProductIds) {
            // Fetch additional details for the current product ID

            Map<String, dynamic>? productDetails =
                await getProductDetailsById(productId);

            if (productDetails != null) {
              // Add the combined details to the favData list

              favData.add({
                'productName': productDetails['productName'].toString(),
                'productId': productId,
                'productSize': productDetails['productSize'],
                'price': productDetails['price'],
                'imageUrl': productDetails['productImages'],
                'discountPrice': productDetails['discountPrice'],
              });
            }
          }
        }
      }
    } catch (error) {
      print('Error fetching Favourite data from the database: $error');
    }

    return favData;
  }
}

Future<Widget> whereToGo() async {
  var sharedPref = await SharedPreferences.getInstance();
  var loginValue = sharedPref.getBool('login');
  var isVendor = sharedPref.getBool(VendorLoginScreenState.IsVendor);

  if (loginValue == null) {
    return LoginScreen();
  }

  if (isVendor == true) {
    return vendorMainScreen();
  } else if (loginValue) {
    // Check if the user is banned
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(user.uid)
          .get();
      bool isBanned = userDoc['ban'] ?? false;
      if (isBanned) {
        // If user is banned, set loginValue to false and return LoginScreen
        sharedPref.setBool('login', false);
        return LoginScreen();
      }
    }
    return MainScreen();
  }
  return LoginScreen();
}
