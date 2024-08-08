import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:macstore/views/screens/inner_screen/order_detail_screen.dart';
import '../../../utilities/send_mail.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

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
                  'My Orders',
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
                    Icons.arrow_back_ios,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          final orders = snapshot.data!.docs;
          final reversedOrders = orders.reversed.toList();
          return ListView.builder(
            itemCount: reversedOrders.length,
            itemBuilder: (context, index) {
              final orderData =
                  reversedOrders[index].data() as Map<String, dynamic>;
              final items = orderData['items'] as List<dynamic>;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return OrderDetail(
                            orderData: orderData,
                            items: items,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFEFF0F2),
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, right: 15),
                          child: Container(
                            width: 77,
                            height: 25,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: orderData['delivered'] == true
                                  ? const Color(0xFF3C55EF)
                                  : orderData['processing'] == true
                                      ? Colors.purple
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                orderData['delivered'] == true
                                    ? "Delivered"
                                    : orderData['processing'] == true
                                        ? "Processing"
                                        : 'Cancelled',
                                style: GoogleFonts.getFont(
                                  'Lato',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        for (final item in items)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                    child: Row(
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Image.network(
                                              item['productImage'],
                                              width: 70,
                                              height: 60,
                                              fit: BoxFit.contain,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
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
                                              item['productName'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: GoogleFonts.getFont(
                                                'Lato',
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
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
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Visibility(
                                              visible: item['size'] != null &&
                                                  item['size'].isNotEmpty,
                                              child: Text(
                                                '${item['size']}',
                                                style: GoogleFonts.getFont(
                                                    'Lato',
                                                    color:
                                                        const Color(0xFF7F808C),
                                                    fontSize: 12,
                                                    height: 1.6,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '\u{20B9}' +
                                                  item['price'].toString(),
                                              style: GoogleFonts.getFont(
                                                'Lato',
                                                color: const Color(0xFF0B0C1E),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'qty:' +
                                                  item['quantity'].toString(),
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const Divider(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Total Price:',
                                    style: GoogleFonts.getFont(
                                      'Lato',
                                      color: const Color(0xFF0B0C1E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '\u{20B9}' + orderData['price'].toString(),
                                    style: GoogleFonts.getFont(
                                      'Lato',
                                      color: const Color(0xFF0B0C1E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoButton(
                                onPressed: () {
                                  orderData['processing']
                                      ? FirebaseFirestore.instance
                                          .collection('orders')
                                          .doc(orderData['orderId'])
                                          .update({
                                          'delivered': false,
                                          'processing': false
                                        }).then((_) {
                                          updateProductQuantities(orderData);
                                          sendOrderNotification(
                                              "shaikhwasiullah500@gmail.com",
                                              orderData['orderId'],
                                              true);
                                        }).catchError((error) {
                                          print(
                                              'Failed to update order: $error');
                                        })
                                      : null;
                                },
                                child: orderData['processing']
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.9),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            'Cancel Order',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> updateProductQuantities(Map<String, dynamic> orderData) async {
    final List<dynamic> products = orderData['items'];

    for (final product in products) {
      final productId = product['productId'];
      final quantity = product['quantity'];

      // Update the product quantity in Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'quantity': FieldValue.increment(quantity),
      });
    }
  }
}
