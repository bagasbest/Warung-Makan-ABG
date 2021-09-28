import 'package:flutter/material.dart';
import 'package:warung_makan_abg/screens/product/product_screen.dart';
import 'package:warung_makan_abg/screens/transaction/transaction_screen.dart';

import 'balance/balance_screen.dart';
import 'cart/cart_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final tabs = [
    ProductScreen(),
    CartScreen(),
    TransactionScreen(),
    BalanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.all_inbox,
              color: Colors.lightBlueAccent,
            ),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon:  Icon(
              Icons.shopping_cart,
              color: Colors.lightBlueAccent,
            ),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon:  Icon(
              Icons.payment,
              color: Colors.lightBlueAccent,
            ),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon:  Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.lightBlueAccent,
            ),
            label: 'Pendapatan',
          ),
        ],
        selectedItemColor: Colors.lightBlueAccent,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: tabs[_currentIndex],
    );
  }
}
