import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:macstore/views/screens/inner_screen/all_products.dart';
import "../inner_screen/product_detail.dart";

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchedValue = '';

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream =
        FirebaseFirestore.instance.collection('products').snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3C55EF),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchedValue = value;
            });
          },
          keyboardType: TextInputType.text,
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          maxLines: 1,
          autofocus: true,
          minLines: null,
          cursorRadius: const Radius.circular(2),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white),
            focusColor: Colors.white,
            border: InputBorder.none,
            errorStyle: const TextStyle(
              color: Color(0xFFFF0000),
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
            errorMaxLines: 1,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: _productsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.pink,
                  ),
                ),
              );
            }

            final searchData = snapshot.data!.docs.where((element) {
              return element['productName']
                  .toLowerCase()
                  .contains(searchedValue.toLowerCase());
            }).toList();

            if (searchedValue.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'You can search for products',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: searchData.map((e) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetail(productData: e),
                        ),
                      );
                    },
                    child: Container(
                        height: MediaQuery.of(context).size.height ,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 100),
                          child: AllProductScreen(
                            products: searchData,
                            isPopularProducts: false,
                            isSearch: true,
                          ),
                        )),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
