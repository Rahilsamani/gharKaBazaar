import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:macstore/views/screens/inner_screen/product_detail.dart';

class PopularModel extends StatelessWidget {
  final dynamic popularProduct;

  const PopularModel({Key? key, required this.popularProduct})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetail(
            productData: popularProduct,
          );
        }));
      },
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFD9D9D9)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    popularProduct['productImages'][0],
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // Title
                  Text(
                    popularProduct['productName'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // description
                  Text(
                    popularProduct['description'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Price
                  Row(
                    children: [
                      // Original Price (if not equal to discounted price)
                      if (popularProduct['price'] !=
                          popularProduct['discountPrice'])
                        Row(
                          children: [
                            Text(
                              '\u{20B9}' +
                                  (popularProduct['price'] % 1 == 0
                                      ? popularProduct['price']
                                          .toInt()
                                          .toString()
                                      : popularProduct['price'].toString()),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                letterSpacing: 0.3,
                                decoration: TextDecoration.lineThrough,
                                fontFamily: 'Lato',
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                          ],
                        ),

                      // Discounted Price
                      Text(
                        '\u{20B9}' +
                            (popularProduct['discountPrice'] % 1 == 0
                                ? popularProduct['discountPrice']
                                    .toInt()
                                    .toString()
                                : popularProduct['discountPrice'].toString()),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
