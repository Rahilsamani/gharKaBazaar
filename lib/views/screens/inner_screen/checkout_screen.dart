import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:macstore/views/screens/inner_screen/order_placed_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:macstore/provider/product_provider.dart';
import 'package:macstore/views/screens/inner_screen/shipping_address_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:macstore/utilities/send_mail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Razorpay _razorpay = new Razorpay();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedPaymentOption = "";
  String orderId = '';

  bool isAddressFilled() {
    return pinCode.isNotEmpty &&
        locality.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty;
  }

  // Variables to store user data
  String pinCode = '';
  String locality = '';
  String city = '';
  String state = '';
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    // Call the method to set up the stream
    _setupUserDataStream();
    _razorpay = new Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _setupUserDataStream() {
    // Create a stream of the user data
    Stream<DocumentSnapshot> userDataStream =
        _firestore.collection('buyers').doc(_auth.currentUser!.uid).snapshots();

    // Listen to the stream and update the UI when there's a change
    userDataStream.listen((DocumentSnapshot userData) {
      if (userData.exists) {
        setState(() {
          pinCode = userData.get('pinCode') ?? '';
          locality = userData.get('locality') ?? '';
          city = userData.get('city') ?? '';
          state = userData.get('state') ?? '';
          phoneNumber = userData.get('phoneNumber') ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartData = ref.watch(cartProvider);

    final totalAmount = ref.read(cartProvider.notifier).calculateTotalAmount();
    double total = totalAmount + 10;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Checkout',
          style: GoogleFonts.getFont(
            'Lato',
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ShippingAddressScreen();
                  }));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 74,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFEFF0F2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Row(
                            children: [
                              // Location Logo
                              Container(
                                width: 23,
                                height: 23,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBF7F5),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Image.network(
                                  'https://storage.googleapis.com/codeless-dev.appspot.com/uploads%2Fimages%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F2ee3a5ce3b02828d0e2806584a6baa88.png',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(
                                width: 20,
                              ),

                              // Address
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                        return ShippingAddressScreen();
                                      }));
                                      if (result != null &&
                                          result['addressFilled']) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Proceed for payment.'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Please fill in all address details to proceed.'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 114,
                                        child: Text(
                                          state == "" ? "Add address" : state,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: GoogleFonts.getFont(
                                            'Lato',
                                            color: const Color(0xFF0B0C1E),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      city == ""
                                          ? "Enter City"
                                          : locality + " " + city,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.getFont(
                                        'Lato',
                                        color: const Color(0xFF7F808C),
                                        fontSize: 12,
                                        height: 1.6,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F6ce18a0efc6e889de2f2878027c689c9caa53feeedit%201.png?alt=media&token=a3a8a999-80d5-4a2e-a9b7-a43a7fa8789a',
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Your Order',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              ListView.builder(
                  physics: ScrollPhysics(),
                  itemCount: cartData.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final cartItem = cartData.values.toList()[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Container(
                        width: 336,
                        height: 100,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFEFF0F2),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 6,
                              top: 6,
                              child: SizedBox(
                                width: 311,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 85,
                                      height: 85,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          cartItem.imageUrl[0].toString(),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Container(
                                        height: 78,
                                        alignment: const Alignment(0, -0.51),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  cartItem.productName,
                                                  maxLines: 2,
                                                  style: GoogleFonts.getFont(
                                                    'Lato',
                                                    color:
                                                        const Color(0xFF0B0C1E),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  cartItem.categoryName,
                                                  style: GoogleFonts.getFont(
                                                    'Lato',
                                                    color:
                                                        const Color(0xFF7F808C),
                                                    fontSize: 12,
                                                    height: 1.6,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      height: 78,
                                      alignment: const Alignment(0, -0.03),
                                      child: Text(
                                        '\u{20B9}' +
                                            cartItem.discount
                                                .toStringAsFixed(0),
                                        style: GoogleFonts.getFont(
                                          'Lato',
                                          color: const Color(0xFF0B0C1E),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          height: 1.3,
                                        ),
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
                  }),
              SizedBox(
                height: 25,
              ),
              Text(
                'Payment Method',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: 10,
              ),

              // Cash on Delivery Section
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 67,
                      child: SizedBox.square(
                        dimension: 32,
                        child: Radio<String>(
                          value: 'CashOnDelivery',
                          groupValue: selectedPaymentOption,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentOption = value;
                            });
                          },
                          activeColor: const Color(0xFF5C69E5),
                          fillColor: MaterialStateProperty.resolveWith(
                              (states) =>
                                  states.contains(MaterialState.selected)
                                      ? const Color(0xFF5C69E5)
                                      : Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: 70,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFEFF0F2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF7F5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(
                              Icons.delivery_dining,
                            ),
                          ),
                          Text(
                            'Cash On Delivery',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),

              // Online Payment section
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 67,
                      child: SizedBox.square(
                        dimension: 32,
                        child: Radio<String>(
                          value: 'Online',
                          groupValue: selectedPaymentOption,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentOption = value;
                            });
                          },
                          activeColor: const Color(0xFF5C69E5),
                          fillColor: MaterialStateProperty.resolveWith(
                              (states) =>
                                  states.contains(MaterialState.selected)
                                      ? const Color(0xFF5C69E5)
                                      : Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: 70,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFEFF0F2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 46,
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 43,
                              height: 43,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBF7F5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Icon(Icons.monetization_on_outlined),
                            ),
                          ),
                          Text(
                            'Online Payment',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // Summary
              SizedBox(
                height: 20,
              ),
              Container(
                width: 336,
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: GoogleFonts.roboto(
                        color: Color(0xFF0B0C1E),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    _row(
                        'Payment Method',
                        selectedPaymentOption == 'CashOnDelivery'
                            ? "CashOnDelivery"
                            : 'Online'),
                    _row('sub-total(${cartData.length} items) ',
                        '\u{20B9}' + totalAmount.toStringAsFixed(0)),
                    _row('Delivery Fee', '${'\u{20B9}' + "10"}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\u{20B9}' + total.toStringAsFixed(0),
                          style: GoogleFonts.getFont(
                            'Lato',
                            color: const Color(0xFF3B54EE),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.6,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () async {
            if (!isAddressFilled()) {
              // If address details are not filled, show a reminder
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Please fill in all address details to proceed.'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            try {
              // Generate a single order ID for the entire order
              setState(() {
                _isLoading = true;
              });
              orderId = Uuid().v4();

              if (selectedPaymentOption == 'CashOnDelivery') {
                // Additional logic for Cash on Delivery
                // Save order details with the common order ID
                bool result = await saveOrderDetails();
                if (result) {
                  // Send order notification with orderId
                  updateQuantity();

                  sendOrderNotification(
                      "shaikhwasiullah500@gmail.com", orderId, false);

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderPlacedScreen()),
                  );
                }
              } else {
                // Additional logic for Online Payment
                // Make the online payment
                makePayment(totalAmount);
              }
            } catch (error) {
              print('Error saving orders: $error');
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: Container(
            width: 338,
            height: 58,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF3B54EE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      'Pay Now',
                      style: GoogleFonts.getFont(
                        'Lato',
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> saveOrderDetails() async {
    DateTime now = DateTime.now();

    final _cartProvider = ref.read(cartProvider.notifier);

    final totalAmount = ref.read(cartProvider.notifier).calculateTotalAmount();
    double total = totalAmount + 10;
    DocumentSnapshot userDoc =
        await _firestore.collection('buyers').doc(_auth.currentUser!.uid).get();

    List<Map<String, dynamic>> orderItems = [];

    // Build the list of order items
    for (var entry in _cartProvider.getCartItems.entries) {
      var item = entry.value;

      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(item.productId).get();

      if (productSnapshot['quantity'] < item.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(item.productName + 'is out of stock'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }

      orderItems.add({
        'productName': item.productName,
        'productId': item.productId,
        'size': item.productSize,
        'quantity': item.quantity,
        'productCategory': item.categoryName,
        'productImage': item.imageUrl[0],
        'price': item.discount
      });
    }

    try {
      // Save order details with the list of items
      await _firestore.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'items': orderItems,
        'price': total,
        'state': state,
        'locality': locality,
        'pinCode': pinCode,
        'city': city,
        'fullName': (userDoc.data() as Map<String, dynamic>)['fullName'],
        'email': (userDoc.data() as Map<String, dynamic>)['email'],
        'phoneNumber': (userDoc.data() as Map<String, dynamic>)['phoneNumber'],
        'buyerId': _auth.currentUser!.uid,
        "deliveredCount": 0,
        "delivered": false,
        "processing": true,
        "mode": selectedPaymentOption,
        'timestamp': now,
      });
      return true;
    } catch (error) {
      print('Error saving order details: $error');
    }
    return false;
  }

  Future<bool> checkAvailability() async {
    final _cartProvider = ref.read(cartProvider.notifier);

    // Build the list of order items
    for (var entry in _cartProvider.getCartItems.entries) {
      var item = entry.value;

      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(item.productId).get();

      if (productSnapshot['quantity'] < item.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(item.productName + 'is out of stock'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> updateQuantity() async {
    final _cartProvider = ref.read(cartProvider.notifier);

    // Build the list of order items
    for (var entry in _cartProvider.getCartItems.entries) {
      var item = entry.value;

      DocumentReference productDocRef =
          _firestore.collection('products').doc(item.productId);

      // Get the document snapshot
      DocumentSnapshot productSnapshot = await productDocRef.get();

      // Check if the document exists
      if (productSnapshot.exists) {
        // Get the current quantity
        Map<String, dynamic>? productData =
            productSnapshot.data() as Map<String, dynamic>?;

        if (productData != null) {
          int currentQuantity = productData['quantity'] ?? 0;

          // Check if there's enough quantity to fulfill the order
          if (currentQuantity >= item.quantity) {
            // Update the quantity in Firestore
            await productDocRef.update({
              'quantity': currentQuantity - item.quantity,
            });
          } else {
            // Handle insufficient quantity (optional)
            print('Insufficient quantity for ${item.productName}');
          }
        } else {
          // Handle case where product data is null
          print('Product data is null for ${item.productName}');
        }
      } else {
        // Handle case where the product document doesn't exist
        print('Product document not found for ${item.productName}');
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Save order details with the common order ID
      bool result = await saveOrderDetails();

      if (result) {
        updateQuantity();
        sendOrderNotification('shaikhwasiullah500@gmail.com', orderId, false);
        Get.snackbar('Success', 'Payment Successfully Done',
            colorText: Colors.green);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderPlacedScreen()),
        );
        // Additional logic for successful payment
        sendOrderNotification('shaikhwasiullah500@gmail.com', orderId, false);
        Get.snackbar('Success', 'Payment Successfully Done',
            colorText: Colors.green);
      }
    } catch (error) {
      print('Error saving orders after payment success: $error');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    Get.snackbar('Failure', '${response.error}', colorText: Colors.green);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }

  makePayment(double totalAmount) async {
    var options = {
      'key': dotenv.env['RAZORPAY_KEY'],
      'amount': (totalAmount * 100).toInt(),
      'name': 'Ghar Ka Bazar',
      'order_id': "",
      'prefill': {
        'contact': dotenv.env['PREFILL_CONTACT'],
        'email': dotenv.env['PREFILL_EMAIL']
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    bool result = await checkAvailability();
    if (result) {
      _razorpay.open(options);
    }
  }
}

Widget _row(title, subtitle) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.getFont(
            'Lato',
            color: const Color(0xFF7F808C),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.getFont(
            'Lato',
            color: const Color(0xFF0B0C1E),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
        ),
      ],
    ),
  );
}
