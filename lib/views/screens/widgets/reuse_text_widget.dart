import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../inner_screen/all_products.dart';

class ReuseTextWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<QueryDocumentSnapshot> products;
  final bool isPopular;

  const ReuseTextWidget(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.products,
      required this.isPopular});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.getFont(
              'Lato',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AllProductScreen(
                  products: products,
                  isPopularProducts: isPopular,
                  isSearch: false,
                );
              }));
            },
            child: Text(
              subtitle,
              style: GoogleFonts.getFont(
                'Lato',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
