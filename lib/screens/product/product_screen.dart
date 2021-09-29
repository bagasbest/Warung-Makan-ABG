import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warung_makan_abg/screens/login_screen.dart';
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
                Route route =
                    MaterialPageRoute(builder: (context) => ProductAdd());
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Produk Tersedia',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.lightBlueAccent,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showDialogLogout();
                  },
                  child: Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                )
              ],
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

  _showDialogLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
          backgroundColor: Colors.lightBlueAccent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Konfirmasi Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Divider(
                  color: Colors.white,
                  height: 3,
                  thickness: 3,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                'Apakah anda yakin ingin Logout ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
          elevation: 10,
        );
      },
    );
  }
}
