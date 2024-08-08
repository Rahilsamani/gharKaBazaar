import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:macstore/controllers/category_controller.dart';
import 'package:macstore/views/screens/inner_screen/all_category_products_screen.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({Key? key});

  @override
  Widget build(BuildContext context) {
    final CategoryController categoryController =
        Get.find<CategoryController>();

    return Obx(
      () {
        return Container(
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: categoryController.categories.length > 8
                      ? 8
                      : categoryController.categories.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AllCategoryProductScreen(
                                categoryData:
                                    categoryController.categories[index],
                              );
                            },
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Image.network(
                              categoryController
                                  .categories[index].categoryImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                categoryController
                                    .categories[index].categoryName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.quicksand(
                                  color: Colors.black,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
