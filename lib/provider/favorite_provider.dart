import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macstore/models/favorite_models.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, Map<String, FavoriteModel>>(
  (ref) {
    return FavoriteNotifier();
  },
);

class FavoriteNotifier extends StateNotifier<Map<String, FavoriteModel>> {
  FavoriteNotifier() : super({});

  void addProductToFavorite({
    required String productName,
    required String productId,
    required List imageUrl,
    required num price,
    required List productSize,
    required num discountPrice,
  }) {
    state[productId] = FavoriteModel(
      productName: productName,
      productId: productId,
      imageUrl: imageUrl,
      price: price,
      productSize: productSize,
      discountPrice: discountPrice,
    );

    // notify listeners that the state has changed
    state = {...state};
  }

  void removeItem(String productId) {
    state.remove(productId);

    // notify listeners that the state has changed
    state = {...state};
  }

  Map<String, FavoriteModel> get getFavoriteItem => state;
}
