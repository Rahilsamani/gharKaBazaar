import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:macstore/controllers/favourite_controller.dart';
import 'package:macstore/provider/favorite_provider.dart';
import 'package:macstore/views/screens/main_screen.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final _favoriteProvider = ref.read(favoriteProvider.notifier);
    final _wishItem = ref.watch(favoriteProvider);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 118,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/icons/cartb.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                    left: 322,
                    top: 52,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/icons/not.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: badges.Badge(
                            badgeStyle: badges.BadgeStyle(
                              badgeColor: Colors.yellow.shade800,
                            ),
                            badgeContent: Text(
                              _wishItem.length.toString(),
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Positioned(
                  left: 61,
                  top: 55,
                  child: Text(
                    'My Favourite',
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: _wishItem.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'your wishlist is empty\n you can add product to your wishlist from the button',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 17,
                        letterSpacing: 1.7,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MainScreen();
                        }));
                      },
                      child: Text('Add Item'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _wishItem.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final wishData = _wishItem.values.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 310,
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white),
                      child: Row(
                        children: [
                          // Thumbnail
                          Stack(
                            children: [
                              // Image
                              Container(
                                height: 120,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black.withOpacity(0.25)),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Center(
                                    child: ClipRRect(
                                      clipBehavior: Clip.antiAlias,
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: wishData.imageUrl[0],
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Favourite Icon Button
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  onPressed: () {
                                    if (_favoriteProvider.getFavoriteItem
                                        .containsKey(wishData.productId)) {
                                      FavouriteController()
                                          .removeProductFromFavourites(
                                              wishData.productId);
                                      _favoriteProvider
                                          .removeItem(wishData.productId);
                                    } else {
                                      FavouriteController()
                                          .addProductToFavourites(
                                              productId: wishData.productId);
                                      _favoriteProvider.addProductToFavorite(
                                          productName: wishData.productName,
                                          productId: wishData.productId,
                                          imageUrl: wishData.imageUrl,
                                          price: wishData.price,
                                          productSize: wishData.productSize,
                                          discountPrice:
                                              wishData.discountPrice);
                                    }
                                  },
                                  icon: _favoriteProvider.getFavoriteItem
                                          .containsKey(wishData.productId)
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

                          // Details
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.62,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Name
                                  SizedBox(
                                    child: Text(
                                      wishData.productName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.getFont(
                                        'Lato',
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height: 2,
                                  ),

                                  // Prices
                                  Row(
                                    children: [
                                      // Original Price (if not equal to discounted price)
                                      if (wishData.price !=
                                          wishData.discountPrice)
                                        Row(
                                          children: [
                                            Text(
                                              '\u{20B9}' +
                                                  (wishData.price % 1 == 0
                                                      ? wishData.price
                                                          .toInt()
                                                          .toString()
                                                      : wishData.price
                                                          .toString()),
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                                letterSpacing: 0.3,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily: 'Lato',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),

                                      // Discounted Price
                                      Text(
                                        '\u{20B9}' +
                                            (wishData.discountPrice % 1 == 0
                                                ? wishData.discountPrice
                                                    .toInt()
                                                    .toString()
                                                : wishData.discountPrice
                                                    .toString()),
                                        style: TextStyle(
                                          color: Color(0xFF1E3354),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4,
                                          fontFamily: 'Lato',
                                        ),
                                      ),

                                      SizedBox(
                                        width: 5,
                                      ),

                                      if ((wishData.price -
                                              wishData.discountPrice) >
                                          0)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.yellow.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${((wishData.price - wishData.discountPrice) / wishData.price * 100).floor()}% Off',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Product Size
                                  if (wishData.productSize.isNotEmpty)
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          '${wishData.productSize[0]}',
                                          style: GoogleFonts.getFont(
                                            'Lato',
                                            color: const Color(0xFF7F808C),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }));
  }
}
