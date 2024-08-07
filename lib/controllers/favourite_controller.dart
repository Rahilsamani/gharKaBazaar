import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FavouriteController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<String> favouriteProductIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    updateFavourites();
  }

  void addProductToFavourites({
    required String productId,
  }) {
    // Check if the product is already in favourites
    if (!favouriteProductIds.contains(productId)) {
      // If not in favourites, add the productId to favouriteProductIds
      favouriteProductIds.add(productId);

      // Update the user's document in Firestore
      updateUserFavourites(true, productId);
    }
  }

  void removeProductFromFavourites(String productId) {
    // Remove the productId from favouriteProductIds locally
    favouriteProductIds.remove(productId);

    // Update the user's document in Firestore
    updateUserFavourites(false, productId);
  }

  Future<void> updateUserFavourites(bool add, String productId) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        if (add) {
          await _firestore.collection('buyers').doc(user.uid).update({
            'favouriteProducts': FieldValue.arrayUnion([productId]),
          });
        } else {
          await _firestore.collection('buyers').doc(user.uid).update({
            'favouriteProducts': FieldValue.arrayRemove([productId])
          });
        }
      }
    } catch (e) {
      print('Error updating user favourites: $e');
    }
  }

  void updateFavourites() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('buyers').doc(user.uid).get();

        if (userDoc.exists) {
          // Fetch favouriteProductIds from the user's document in Firestore
          List<dynamic> userFavourites = userDoc['favouriteProducts'] ?? [];
          favouriteProductIds.value = List<String>.from(userFavourites);
        }
      }
    } catch (e) {
      print('Error updating favourites: $e');
    }
  }
}
