import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:macstore/controllers/cart_controller.dart';
import 'package:macstore/controllers/favourite_controller.dart';
import 'package:macstore/provider/favorite_provider.dart';
import 'package:macstore/provider/product_provider.dart';
import 'package:macstore/views/screens/widgets/curved_edges.dart';
import 'package:macstore/views/screens/widgets/product_models.dart';

class ProductDetail extends ConsumerStatefulWidget {
  final dynamic productData;

  const ProductDetail({Key? key, this.productData}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<ProductDetail> {
  late ValueNotifier<String> descriptionNotifier;
  bool showFullDescription = false;
  int imageIndex = 0;
  int qty = 1;

  @override
  void initState() {
    super.initState();
    descriptionNotifier =
        ValueNotifier<String>(widget.productData['description']);
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where(
          'category',
          isEqualTo: widget.productData['category'],
        )
        .snapshots();
    final _favoriteProvider = ref.read(favoriteProvider.notifier);
    ref.watch(favoriteProvider);
    final _cartProvider = ref.read(cartProvider.notifier);
    final cartItem = ref.watch(cartProvider);
    final isInCart = cartItem.containsKey(widget.productData['productId']);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product Image Slider
            ClipPath(
              clipper: CustomCurvedEdges(),
              child: Container(
                color: Colors.grey.withOpacity(0.4),
                child: Stack(
                  children: [
                    // Main Large Image
                    SizedBox(
                        height: 400,
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Image.network(
                              widget.productData['productImages'][imageIndex],
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),

                    // Image Slider
                    if (widget.productData['productImages'].length > 1)
                      Positioned(
                        bottom: 30,
                        right: 0,
                        left: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: SizedBox(
                              height: 80,
                              child: ListView.separated(
                                  itemCount: widget
                                      .productData['productImages'].length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  separatorBuilder: (_, __) => const SizedBox(
                                        width: 10,
                                      ),
                                  itemBuilder: (_, index) => GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            imageIndex = index;
                                          });
                                        },
                                        child: Container(
                                          width: 80,
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: index == imageIndex
                                                      ? Colors.blueAccent
                                                      : Colors.grey),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Image.network(
                                              widget.productData[
                                                  'productImages'][index],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      )),
                            ),
                          ),
                        ),
                      ),

                    // App Bar Icons
                    AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_outlined,
                          color: Colors.black,
                        ),
                      ),
                      actions: [
                        IconButton(
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
                                  productName:
                                      widget.productData['productName'],
                                  productId: widget.productData['productId'],
                                  imageUrl: widget.productData['productImages'],
                                  price: widget.productData['price'],
                                  productSize:
                                      widget.productData['productSize'],
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
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: EdgeInsets.only(right: 24, left: 24, bottom: 24),
              child: Column(
                children: [
                  // Price, Title, Stock and Brand
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Text(
                        widget.productData['productName'],
                        style: GoogleFonts.getFont(
                          'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),

                      SizedBox(
                        height: 5,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.productData['category'],
                          style: GoogleFonts.getFont(
                            'Lato',
                            color: const Color(0xFF9A9998),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      SizedBox(height: 5),

                      // price and sale tag
                      Row(
                        children: [
                          // Sale Tag
                          if ((widget.productData['price'] -
                                  widget.productData['discountPrice']) >
                              0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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

                          SizedBox(
                            width: 10,
                          ),

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
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Quantity
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Quantity :',
                          style: GoogleFonts.getFont(
                            'Lato',
                            color: const Color(0xFF343434),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (qty > 1) {
                              _cartProvider.decrementItem(
                                  widget.productData['productId']);
                              setState(() {
                                qty--;
                              });
                            }
                          },
                          icon: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        // Quantity Text
                        Text(
                          qty.toString(),
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),

                        // Add Button
                        IconButton(
                          onPressed: () {
                            if (qty < widget.productData['quantity']) {
                              _cartProvider.incrementItem(
                                  widget.productData['productId']);
                              setState(() {
                                qty++;
                              });
                            }
                          },
                          icon: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Color(0xFF3C55EF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  // Stock
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: GoogleFonts.getFont(
                          'Lato',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: qty <= widget.productData['quantity'] &&
                                    widget.productData['quantity'] > 0
                                ? Colors.green
                                : Colors.red.withOpacity(0.8)),
                        child: Text(
                          widget.productData['quantity'] > 0 &&
                                  qty <= widget.productData['quantity']
                              ? 'In Stock'
                              : 'Out Of Stock',
                          style: GoogleFonts.getFont(
                            'Lato',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    ],
                  ),

                  // Weight
                  widget.productData['productSize'].isEmpty
                      ? SizedBox()
                      : Column(
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  child: Text(
                                    widget.productData['productSize'][0],
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                  SizedBox(
                    height: 20,
                  ),

                  // Descriptions
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'About',
                      style: GoogleFonts.getFont(
                        'Lato',
                        color: const Color(0xFF363330),
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 389,
                    child: ValueListenableBuilder<String>(
                      valueListenable: descriptionNotifier,
                      builder: (context, description, child) {
                        return RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: GoogleFonts.getFont(
                              'Lato',
                              color: const Color(0xFF797979),
                              fontSize: 12,
                              letterSpacing: 1,
                              height: 1.7,
                            ),
                            children: [
                              TextSpan(
                                text: showFullDescription
                                    ? description
                                    : description.substring(
                                        0, description.length ~/ 2),
                              ),
                              if (!showFullDescription)
                                TextSpan(
                                  text: '... ',
                                  style: TextStyle(
                                    color: Color(0xFF3C54EE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (!showFullDescription)
                                TextSpan(
                                  text: 'See More',
                                  style: TextStyle(
                                    color: Color(0xFF3C54EE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      setState(() {
                                        showFullDescription = true;
                                      });
                                    },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.only(bottom: 70),
              child: Column(
                children: [
                  Text(
                    'Related Products',
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _productsStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }

                      return Container(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final productData = snapshot.data!.docs[index];
                            return ProductModel(
                              productData: productData,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: !(widget.productData['quantity'] > 0 &&
                  qty <= widget.productData['quantity'])
              ? null // Disable the button when quantity is less than or equal to 0
              : isInCart
                  ? () {
                      _cartProvider.removeItem(widget.productData['productId']);
                      CartController()
                          .removeItemFromCart(widget.productData['productId']);
                    }
                  : () {
                      CartController().addProductToCart(
                        productId: widget.productData['productId'],
                        quantity: qty,
                        size: (widget.productData['productSize'].isEmpty)
                            ? ''
                            : widget.productData['productSize'][0],
                      );

                      _cartProvider.addProductToCart(
                        productName: widget.productData['productName'],
                        productPrice: widget.productData['price'],
                        categoryName: widget.productData['category'],
                        imageUrl: widget.productData['productImages'],
                        quantity: qty,
                        productId: widget.productData['productId'],
                        productSize: (widget.productData['productSize'].isEmpty)
                            ? ''
                            : widget.productData['productSize'][0],
                        discount: widget.productData['discountPrice'],
                        description: widget.productData['description'],
                        totalQuantity: widget.productData['quantity'],
                      );
                    },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 48,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: !(widget.productData['quantity'] > 0 &&
                      qty <= widget.productData['quantity'])
                  ? Colors.grey
                  : (isInCart ? Colors.grey : const Color(0xFF3B54EE)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  isInCart ? 'Remove From CART' : 'ADD TO CART',
                  style: GoogleFonts.getFont(
                    'Lato',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
