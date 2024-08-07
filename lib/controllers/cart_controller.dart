import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize cartItems when the controller is initialized
    updateCart();
  }

  void addProductToCart({
    required String productId,
    required int quantity,
    required String size,
  }) {
    // Check if the product is already in the cart
    int existingIndex =
        cartItems.indexWhere((item) => item['productId'] == productId);

    if (existingIndex != -1) {
      // If already in cart, update the quantity
      cartItems[existingIndex]['quantity'] += quantity;
    } else {
      // If not in cart, add the product to cartItems
      cartItems.add({
        'productId': productId,
        'quantity': quantity,
        'size': size,
      });
    }

    // Update the user's document in Firestore
    updateUserCart(productId, quantity, size);
  }

  Future<void> updateUserCart(
      String productId, int quantity, String size) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Get the user's document in Firestore
        DocumentReference userDocRef =
            _firestore.collection('buyers').doc(user.uid);

        // Get the current cart items from Firestore
        DocumentSnapshot userDoc = await userDocRef.get();
        List<dynamic> userCart = userDoc['cartItems'] ?? [];

        // Update the cartItems array based on the changes
        int existingIndex =
            userCart.indexWhere((item) => item['productId'] == productId);

        if (existingIndex != -1) {
          // If the product is already in cart, update the quantity or remove if quantity is 0
          if (quantity > 0) {
            userCart[existingIndex]['quantity'] = quantity;
            userCart[existingIndex]['size'] = size;
          } else {
            userCart.removeAt(existingIndex);
          }
        } else {
          // If not in cart, add the product to cartItems
          userCart.add({
            'productId': productId,
            'quantity': quantity,
            'size': size,
          });
        }

        // Update the cartItems array in Firestore
        await userDocRef.update({
          'cartItems': userCart,
        });
      }
    } catch (e) {
      print('Error updating user cart: $e');
    }
  }

  void removeItemFromCart(String productId) {
    // Remove the item from cartItems
    cartItems.removeWhere((item) => item['productId'] == productId);

    // Update the user's document in Firestore
    updateUserCart(productId, 0, '0'); // Set quantity to 0 for removal
  }

  void updateCart() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Get the user's document in Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('buyers').doc(user.uid).get();

        if (userDoc.exists) {
          // Fetch cartItems from the user's document in Firestore
          List<dynamic> userCart = userDoc['cartItems'] ?? [];
          cartItems.value = List<Map<String, dynamic>>.from(userCart);
        }
      }
    } catch (e) {
      print('Error updating cart: $e');
    }
  }
}
