import 'package:flutter/material.dart';
import 'package:macstore/views/screens/bottomNav_screens/acount_screen.dart';
import 'package:macstore/views/screens/bottomNav_screens/favorite_screen.dart';
import 'package:macstore/views/screens/bottomNav_screens/stores_screen.dart';
import 'package:macstore/views/screens/home_Screen.dart';
import 'package:macstore/views/screens/bottomNav_screens/cart_product_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/widgets/drawer_screen.dart';
import '../../provider/product_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int pageIndex = 0;

  List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
    // StoresScreen(),
    CartScreenProduct(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final _cartProvider = ref.read(cartProvider.notifier);
    final cartData = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghar Ka Bazar'),
      ),
      drawer: DrawerScreen(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        currentIndex: pageIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF3C55EF),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.white.withOpacity(0.95),
            icon: Image.asset(
              'assets/icons/home.png',
              width: 25,
              color: pageIndex == 0 ? Color(0xFF3C55EF) : Colors.grey,
            ),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/love.png',
              width: 25,
              color: pageIndex == 1 ? Color(0xFF3C55EF) : Colors.grey,
            ),
            label: 'Favorite',
          ),
          // BottomNavigationBarItem(
          //   icon: Image.asset(
          //     'assets/icons/mart.png',
          //     width: 25,
          //   ),
          //   label: 'Stores',
          // ),

          BottomNavigationBarItem(
            icon:
                // cartData.isEmpty
                //     ? Image.asset(
                //         'assets/icons/cart_empty',
                //         width: 25,
                //         color: pageIndex == 2 ? Color(0xFF3C55EF) : Colors.grey,
                //       )
                //     :
                Stack(
              children: [
                Image.asset(
                  'assets/icons/cart.png',
                  width: 25,
                  color: pageIndex == 2 ? Color(0xFF3C55EF) : Colors.grey,
                ),
                if (cartData.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow.shade800,
                      ),
                      child: Text(
                        cartData.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),

          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/user.png',
              width: 25,
              color: pageIndex == 3 ? Color(0xFF3C55EF) : Colors.grey,
            ),
            label: 'Account',
          ),
        ],
      ),
      body: pages[pageIndex],
    );
  }
}
