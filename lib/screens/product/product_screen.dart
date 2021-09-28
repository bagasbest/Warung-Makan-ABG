import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warung_makan_abg/screens/product/product_add.dart';
import 'package:warung_makan_abg/screens/product/product_list.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  var _role;

  @override
  void initState() {
    super.initState();
    _initializeRole();
  }

  _initializeRole() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      setState(() {
        _role = value.data()!["role"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// jika role == owner, maka bisa menambah,edit,menghapus produk
      floatingActionButton: (_role == 'owner')
          ? FloatingActionButton(
              onPressed: () {
                Route route = MaterialPageRoute(
                    builder: (context) => ProductAdd());
                Navigator.push(context, route);
              },
              backgroundColor: Colors.lightBlueAccent,
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : Container(),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 40,
              left: 16,
            ),
            child: Text(
              'Daftar Produk Tersedia',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.lightBlueAccent,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 77,
            ),
            child: Divider(
              color: Colors.grey,
              thickness: 2,
            ),
          ),

          /// tampilkan semua produk tersedia

          Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 90),
            child: StreamBuilder(
              stream: (_role == 'cashier')
                  ? FirebaseFirestore.instance
                      .collection('product')
                      .where('quantity', isGreaterThan: 1)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('product')
                      .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return (snapshot.data!.size > 0)
                      ? ListOfProduct(
                          document: snapshot.data!.docs,
                        )
                      : _emptyData();
                } else {
                  return _emptyData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyData() {
    return Container(
      child: Center(
        child: Text(
          'Tidak Ada Produk\nTersedia',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

}
