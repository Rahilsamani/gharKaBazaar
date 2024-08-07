class CartModel {
  final String productName;
  final num productPrice;
  final String categoryName;
  final List imageUrl;

  int quantity;
  final String productId;
  final String productSize;
  final num discount;
  final String description;
  final num totalQuantity;

  CartModel(
      {required this.productName,
      required this.productPrice,
      required this.categoryName,
      required this.imageUrl,
      required this.quantity,
      required this.productId,
      required this.productSize,
      required this.discount,
      required this.description,
      required this.totalQuantity});
}
