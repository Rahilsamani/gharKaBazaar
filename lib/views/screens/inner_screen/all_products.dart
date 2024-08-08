import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:macstore/views/screens/widgets/product_models.dart';

class AllProductScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot> products;
  final bool isPopularProducts;
  final bool isSearch;

  AllProductScreen(
      {Key? key,
      required this.products,
      required this.isPopularProducts,
      required this.isSearch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title =
        isPopularProducts ? 'Popular Products' : 'Recommended Products';

    return Scaffold(
      appBar: isSearch
          ? null
          : PreferredSize(
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
                      left: 61,
                      top: 51,
                      child: Text(
                        title,
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: GridView.count(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 300 / 500,
            children: List.generate(products.length, (index) {
              final product = products[index];
              return ProductModel(productData: product);
            }),
          ),
        ),
      ),
    );
  }
}
