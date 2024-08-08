import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class OrderDetail extends StatefulWidget {
  final dynamic orderData;
  final List<dynamic> items;

  OrderDetail({Key? key, required this.orderData, required this.items})
      : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  double rating = 0;

  final TextEditingController _reviewTextController = TextEditingController();

  Future<void> markAsDelivered() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderData['orderId'])
          .update({
        'delivered': true,
        'deliveredCount': FieldValue.increment(1),
      });
    } catch (error) {
      print('Error marking order as delivered: $error');
    }
  }

  Future<bool> hasUserReviewedProduct(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('productReviews')
        .where('productId', isEqualTo: productId)
        .where('uid', isEqualTo: user!.uid)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> updateProductRating(String productId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('productReviews')
        .where('productId', isEqualTo: productId)
        .get();

    double totalRating = 0;
    int totalReviews = querySnapshot.docs.length;

    for (final doc in querySnapshot.docs) {
      totalRating += doc['rating'];
    }

    final double averageRating =
        totalReviews > 0 ? totalRating / totalReviews : 0;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({
      'rating': averageRating,
      'totalReviews': totalReviews,
    });
  }

  @override
  Widget build(BuildContext context) {
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
              image: AssetImage('assets/icons/cartb.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 61,
                top: 51,
                child: Text(
                  'Order Details',
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
                top: 54,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: widget.orderData['processing'] == true
                  ? Colors.blue
                  : widget.orderData['delivered'] == true
                      ? Colors.green
                      : Colors.red.withOpacity(0.9),
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  widget.orderData['processing'] == true
                      ? 'Order Status: Processing'
                      : widget.orderData['delivered'] == true
                          ? 'Order Status: Delivered'
                          : 'Order Status: Cancelled',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            for (final item in widget.items)
              Container(
                width: MediaQuery.of(context).size.width * 0.93,
                height: 153,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFEFF0F2),
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Product Image
                      Image.network(
                        item['productImage'],
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 78,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Product Name
                            Text(
                              item['productName'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.getFont(
                                'Lato',
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Category
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item['productCategory'],
                                style: GoogleFonts.getFont(
                                  'Lato',
                                  color: const Color(0xFF7F808C),
                                  fontSize: 12,
                                  height: 1.6,
                                ),
                              ),
                            ),

                            // Size
                            Align(
                              alignment: Alignment.centerLeft,
                              child: item['size'] != '' && item['size'] != null
                                  ? Text(
                                      '${item['size']}',
                                      style: GoogleFonts.getFont('Lato',
                                          color: const Color(0xFF7F808C),
                                          fontSize: 12,
                                          height: 1.6,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : SizedBox(),
                            ),

                            // Price
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '\u{20B9} ' + item['price'].toString(),
                                style: GoogleFonts.getFont(
                                  'Lato',
                                  color: const Color(0xFF0B0C1E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 160,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFEFF0F2),
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Delivery Address',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.orderData['locality'] +
                                widget.orderData['pinCode'],
                            style: GoogleFonts.getFont(
                              'Lato',
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.orderData['city'] +
                                " " +
                                widget.orderData['state'],
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'To' + " " + widget.orderData['fullName'],
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            widget.orderData['delivered'] == true
                ? ElevatedButton(
                    onPressed: () async {
                      final productId = widget.items[0][
                          'productId'];
                      final hasReviewed =
                          await hasUserReviewedProduct(productId);

                      if (hasReviewed) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Error'),
                            content:
                                Text('You have already reviewed this product.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Leave a Review'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _reviewTextController,
                                  decoration: InputDecoration(
                                    labelText: 'Your Review',
                                  ),
                                ),
                                RatingBar.builder(
                                  initialRating: rating,
                                  minRating: 1,
                                  maxRating: 5,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 24,
                                  unratedColor: Colors.grey,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (value) {
                                    rating = value;
                                  },
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  final review = _reviewTextController.text;

                                  await FirebaseFirestore.instance
                                      .collection('productReviews')
                                      .add({
                                    'productId': productId,
                                    'fullName': widget.orderData['fullName'],
                                    'email': widget.orderData['email'],
                                    'uid':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'rating': rating,
                                    'review': review,
                                    'timestamp': Timestamp.now(),
                                  }).whenComplete(() {});

                                  updateProductRating(productId);

                                  Navigator.pop(context);
                                  _reviewTextController.clear();
                                  rating = 0;
                                },
                                child: Text('Submit'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text('Leave a Review'),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
