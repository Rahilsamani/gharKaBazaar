import 'package:flutter/material.dart';
import 'package:macstore/views/screens/widgets/banner_widget.dart';
import 'package:macstore/views/screens/widgets/category_item.dart';
import 'package:macstore/views/screens/widgets/header.dart';
import 'package:macstore/views/screens/widgets/popular_products.dart';
import 'package:macstore/views/screens/widgets/recommended_product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
        child: HeaderWidget(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BannerArea(),
            CategoryItem(),
            RecommendedProduct(),
            PopularProducts(),
          ],
        ),
      ),
    );
  }
}
