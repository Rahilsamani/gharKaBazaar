import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macstore/controllers/favourite_controller.dart';
import 'package:macstore/provider/favorite_provider.dart';
import 'package:macstore/views/screens/inner_screen/product_detail.dart';

class ProductModel extends ConsumerStatefulWidget {
  final dynamic productData;

  ProductModel({super.key, this.productData});

  @override
  _ProductModelState createState() => _ProductModelState();
}

class _ProductModelState extends ConsumerState<ProductModel> {
  @override
  Widget build(BuildContext context) {
    final _favoriteProvider = ref.read(favoriteProvider.notifier);
    ref.watch(favoriteProvider);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetail(
            productData: widget.productData,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Thumbnail , Wishlist Button , Discount Tag
            Container(
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                border: Border.all(color: Color(0xFFD9D9D9)),
              ),
              child: Stack(
                children: [
                  // Thumbnail
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 20, 5, 5),
                    child: Center(
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.productData['productImages'][0],
                          // width: 108,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Sale Tag
                  if ((widget.productData['price'] -
                          widget.productData['discountPrice']) >
                      0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${((widget.productData['price'] - widget.productData['discountPrice']) / widget.productData['price'] * 100).floor()}% Off',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                  // Out of Stock
                  if (widget.productData['quantity'] <= 0)
                    Positioned(
                        top: 80,
                        child: Container(
                            color: Colors.white.withOpacity(0.4),
                            width: 180,
                            height: 40,
                            child: Center(
                              child: Text(
                                'Out Of Stock',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ))),

                  // Favourite Icon Button
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        if (_favoriteProvider.getFavoriteItem
                            .containsKey(widget.productData['productId'])) {
                          FavouriteController().removeProductFromFavourites(
                              widget.productData['productId']);
                          _favoriteProvider
                              .removeItem(widget.productData['productId']);
                        } else {
                          FavouriteController().addProductToFavourites(
                              productId: widget.productData['productId']);
                          _favoriteProvider.addProductToFavorite(
                              productName: widget.productData['productName'],
                              productId: widget.productData['productId'],
                              imageUrl: widget.productData['productImages'],
                              price: widget.productData['price'],
                              productSize: widget.productData['productSize'],
                              discountPrice:
                                  widget.productData['discountPrice']);
                        }
                      },
                      icon: _favoriteProvider.getFavoriteItem
                              .containsKey(widget.productData['productId'])
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 18,
                            )
                          : Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                              size: 18,
                            ),
                    ),
                  )
                ],
              ),
            ),

            // Details
            Padding(
              padding: EdgeInsets.only(left: 8.0, top: 10),
              child: SizedBox(
                width: 180,
                child: Column(
                  children: [
                    // Title
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.productData['productName'].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF1E3354),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),

                    // Description
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.productData['description'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 5,
                    ),

                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          // Original Price (if not equal to discounted price)
                          if (widget.productData['price'] !=
                              widget.productData['discountPrice'])
                            Row(
                              children: [
                                Text(
                                  '\u{20B9}' +
                                      (widget.productData['price'] % 1 == 0
                                          ? widget.productData['price']
                                              .toInt()
                                              .toString()
                                          : widget.productData['price']
                                              .toString()),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    letterSpacing: 0.3,
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: 'Lato',
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),

                          // Discounted Price
                          Text(
                            '\u{20B9}' +
                                (widget.productData['discountPrice'] % 1 == 0
                                    ? widget.productData['discountPrice']
                                        .toInt()
                                        .toString()
                                    : widget.productData['discountPrice']
                                        .toString()),
                            style: TextStyle(
                              color: Color(0xFF1E3354),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
