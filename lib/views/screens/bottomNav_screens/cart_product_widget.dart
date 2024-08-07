import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:macstore/controllers/cart_controller.dart';
import 'package:macstore/provider/product_provider.dart';
import 'package:macstore/views/screens/inner_screen/checkout_screen.dart';
import 'package:macstore/views/screens/main_screen.dart';

class CartScreenProduct extends ConsumerStatefulWidget {
  const CartScreenProduct({Key? key});

  @override
  _CartScreenProductState createState() => _CartScreenProductState();
}

class _CartScreenProductState extends ConsumerState<CartScreenProduct> {
  late bool isUserBanned = false;

  @override
  void initState() {
    super.initState();
    updateCartProvider();
    checkUserBanStatus();
  }

  Future<void> checkUserBanStatus() async {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('buyers')
            .doc(user.uid)
            .get();

        // Fetch ban status from the user document
        bool banned = userDoc['ban'] ?? false;

        // Set the value of isUserBanned based on the ban status
        setState(() {
          isUserBanned = banned;
        });
      }
    } catch (error) {
      print('Error fetching user ban status: $error');
    }
  }

  void showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('You are banned and cannot proceed with checkout.'),
      backgroundColor: Colors.red.shade400,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final _cartProvider = ref.read(cartProvider.notifier);
    final cartData = ref.watch(cartProvider);
    final totalAmount = ref.read(cartProvider.notifier).calculateTotalAmount();
    List<bool> checkoutList = List<bool>.filled(cartData.length, true);

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
                            cartData.length.toString(),
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
                top: 51,
                child: Text(
                  'My Cart',
                  style: GoogleFonts.getFont(
                    'Lato',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 23,
                top: 51,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
      body: cartData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'your shopping cart is empty\n you can add product to your cart from the button',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      letterSpacing: 1.7,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MainScreen();
                      })));
                    },
                    child: Text('Shop Now'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cartData.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartData.values.toList()[index];
                    if (cartItem.quantity > cartItem.totalQuantity) {
                      checkoutList[index] = false;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Image
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.network(
                                      cartItem.imageUrl[0],
                                      height: 90,
                                      width: 90,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  SizedBox(
                                    width: 10,
                                  ),

                                  // Title, Price, Size
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Product Name
                                        Flexible(
                                          child: Text(
                                            cartItem.productName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        // Description
                                        Flexible(
                                          child: Text(
                                            cartItem.description,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black
                                                    .withOpacity(0.6)),
                                          ),
                                        ),

                                        // Weight
                                        if (cartItem.productSize != '')
                                          Text(
                                            cartItem.productSize,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      cartItem.totalQuantity < cartItem.quantity
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              padding: EdgeInsets.all(5.0),
                                              child: Text(
                                                'Out of Stock',
                                                style: GoogleFonts.getFont(
                                                  'Lato',
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              width: 85,
                                            ),
                                      // Remove Button
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if (cartItem.quantity > 1) {
                                                _cartProvider.decrementItem(
                                                    cartItem.productId);
                                                checkoutList[index] = true;
                                                setState(() {});
                                              }
                                            },
                                            icon: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(15),
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
                                            cartItem.quantity.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16),
                                          ),

                                          // Add Button
                                          IconButton(
                                            onPressed: () {
                                              if (cartItem.totalQuantity >
                                                  cartItem.quantity) {
                                                _cartProvider.incrementItem(
                                                    cartItem.productId);
                                                CartController()
                                                    .addProductToCart(
                                                        productId:
                                                            cartItem.productId,
                                                        quantity:
                                                            cartItem.quantity,
                                                        size: cartItem
                                                            .productSize);
                                                checkoutList[index] = true;
                                                setState(() {});
                                              }
                                            },
                                            icon: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF3C55EF),
                                                borderRadius:
                                                    BorderRadius.circular(15),
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
                                    ],
                                  ),

                                  // Price
                                  Text(
                                    '\u{20B9}' +
                                        cartItem.discount.toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),

                                  // Remove From Cart
                                  IconButton(
                                    onPressed: () {
                                      _cartProvider
                                          .removeItem(cartItem.productId);
                                      CartController().removeItemFromCart(
                                          cartItem.productId);
                                      checkoutList.removeAt(index);
                                    },
                                    icon: Icon(
                                      CupertinoIcons.delete,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(),
              child: totalAmount == 0
                  ? ElevatedButton(
                      onPressed: null, // Disabled button
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey, // Set color to grey for disabled state
                        ),
                      ),
                      child: Text(
                        'Checkout',
                        style: GoogleFonts.getFont(
                          'Roboto',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        // Check if any item is out of stock or if the user is banned
                        if (checkoutList.contains(false) || isUserBanned) {
                          if (isUserBanned) {
                            showSnackbar();
                          }
                          return null;
                        } else {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CheckoutScreen();
                          }));
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFF3C55EF)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Checkout',
                            style: GoogleFonts.getFont(
                              'Roboto',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '\u{20B9} ' + totalAmount.toStringAsFixed(0),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateCartProvider() async {
    try {
      // Fetch cart data including product IDs, size, quantity, and additional details
      List<Map<String, dynamic>> cartData = await getCartData();

      // Iterate over each cart item
      for (Map<String, dynamic> cartItem in cartData) {
        String productId = cartItem['productId'];

        // Add the product details to the CartNotifier
        ref.read(cartProvider.notifier).addProductToCart(
            productName: cartItem['productName'],
            productPrice: cartItem['productPrice'],
            categoryName: cartItem['categoryName'],
            imageUrl: cartItem['imageUrl'],
            quantity: cartItem['quantity'],
            productId: productId,
            productSize: cartItem['size'],
            discount: cartItem['discount'],
            description: cartItem['description'],
            totalQuantity: cartItem['totalQuantity']);
      }
    } catch (error) {
      print('Error fetching and initializing product details: $error');
    }
  }

  // fetch the cart data
  Future<List<Map<String, dynamic>>> getCartData() async {
    List<Map<String, dynamic>> cartData = [];

    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('buyers')
            .doc(user.uid)
            .get();

        List<dynamic>? cartItems = userDoc['cartItems'];

        if (cartItems != null) {
          // Iterate through the 'cartItems' array and extract product details
          for (Map<String, dynamic> cartItem in cartItems) {
            String productId = cartItem['productId'];
            String size = cartItem['size'];
            int quantity = cartItem['quantity'];

            // Fetch additional details for the current product ID
            Map<String, dynamic>? productDetails =
                await getProductDetailsById(productId);

            if (productDetails != null) {
              // Add the combined details to the cartData list
              cartData.add({
                'productId': productId,
                'size': size,
                'quantity': quantity,
                'productName': productDetails['productName'].toString(),
                'productPrice': productDetails['price'] as num,
                'categoryName': productDetails['category'],
                'imageUrl': productDetails['productImages'],
                'discount': productDetails['discountPrice'],
                'description': productDetails['description'],
                'storeId': productDetails['storeId'],
                'totalQuantity': productDetails['quantity']
              });
            }
          }
        }
      }
    } catch (error) {
      print('Error fetching cart data from the database: $error');
    }

    return cartData;
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
}
