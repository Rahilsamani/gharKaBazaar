import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macstore/views/screens/widgets/product_models.dart';
import 'package:macstore/views/screens/widgets/reuse_text_widget.dart';

class RecommendedProduct extends StatelessWidget {
  const RecommendedProduct({Key? key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
        .collection('products')
        .where('recommened', isEqualTo: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _productsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        // Shuffle the list of products
        List<QueryDocumentSnapshot> shuffledProducts =
            snapshot.data!.docs.toList()..shuffle();

        return Column(
          children: [
            ReuseTextWidget(
                title: 'Recommended for you',
                subtitle: 'View all',
                products: shuffledProducts,
                isPopular: false),
            Container(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    shuffledProducts.length > 20 ? 20 : shuffledProducts.length,
                itemBuilder: (context, index) {
                  final productData = shuffledProducts[index];
                  return ProductModel(
                    productData: productData,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
