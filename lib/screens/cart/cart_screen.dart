import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warung_makan_abg/databases/database_service.dart';
import 'package:warung_makan_abg/model/cart_model.dart';
import 'package:warung_makan_abg/screens/register_screen.dart';
import 'package:warung_makan_abg/screens/transaction/transaction_detail.dart';

import 'cart_list.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCartAvailable = false;
  int totalPrice = 0;
  final moneyCurrency = new NumberFormat("#,##0", "en_US");

  String transactionId = '';
  String date = '';
  String time = '';
  int priceTotal = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection('cart').get().then((value) {
      if (value.size > 0) {
        setState(() {
          _isCartAvailable = true;
        });
      }
    });

    /// ambil harga total seluruh cart
    _initializePrice();
  }

  _initializePrice() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('cart').get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      totalPrice += querySnapshot.docs[i]['price'] as int;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 40,
              left: 16,
            ),
            child: Text(
              'Keranjang',
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
            margin: EdgeInsets.only(left: 16, right: 16, top: 88, bottom: 90,),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('cart').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return (snapshot.data!.size > 0)
                      ? ListOfCart(
                          document: snapshot.data!.docs,
                        )
                      : _emptyData();
                } else {
                  return _emptyData();
                }
              },
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70, left: 16,),
              child: Text(
                "Total Biaya: Rp." + moneyCurrency.format(totalPrice),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          (_isCartAvailable)
              ? Align(
            alignment: Alignment.bottomCenter,
                child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: RaisedButton(
                      onPressed: () async {
                        /// cek apakah cart ada isi atau tidak
                        final snapshot = await FirebaseFirestore.instance
                            .collection('cart')
                            .get();
                        if (snapshot.docs.length > 0) {
                          final DateTime now = DateTime.now();
                          final DateFormat formatterDate =
                              DateFormat('dd MMMM yyyy');
                          date = formatterDate.format(now);

                          final DateFormat formatterTime =
                              DateFormat('hh:mm:ss aa');
                          time = formatterTime.format(now);

                          final String getMonth = now.month.toString();

                          transactionId =
                              DateTime.now().millisecondsSinceEpoch.toString();

                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('cart')
                              .get();
                          List<QueryDocumentSnapshot> docs = querySnapshot.docs;
                          final cartList = docs
                              .map((doc) => CartModel.fromJson(
                                  doc.data() as Map<String, dynamic>))
                              .toList();

                          /// proses cart 1 per 1 item
                          for (int i = 0; i < snapshot.docs.length; i++) {
                            priceTotal += snapshot.docs[i]['price'] as int;
                            String productId =
                                snapshot.docs[i]['productId'].toString();
                            String cartId = snapshot.docs[i]['cartId'].toString();

                            await FirebaseFirestore.instance
                                .collection('product')
                                .doc(productId)
                                .get()
                                .then((value) {
                              int qtyFinal = value.data()!['quantity'] -
                                  snapshot.docs[i]['qty'] as int;

                              FirebaseFirestore.instance
                                  .collection('product')
                                  .doc(productId)
                                  .update({
                                'quantity': qtyFinal,
                              });
                            });

                            /// hapus cart
                            await FirebaseFirestore.instance
                                .collection('cart')
                                .doc(cartId)
                                .delete();
                          }

                          /// buat transaksi baru
                          var data = await DatabaseService.createTransaction(
                            transactionId,
                            date,
                            time,
                            priceTotal,
                            cartList,
                            getMonth,
                            now.millisecondsSinceEpoch,
                          );

                          /// tampilkan hasil
                          if (data == true) {
                            showAlertDialog(context);
                          } else {
                            toast('Gagal membuat transaksi');
                          }
                        } else {
                          toast('Tidak ada produk tersedia');
                        }

                        showAlertDialog(context);


                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Checkout Semua Produk',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      color: Colors.lightBlueAccent,
                    ),
                  ),
              )
              : Container()
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

  void showAlertDialog(BuildContext context) {
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
                  'Sukses Membuat Transaksi',
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
                'Berhasil membuat transaksi baru',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _isCartAvailable = false;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 40,
                      child: Center(
                        child: Text(
                          "Tutup",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            letterSpacing: 1,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      /// ke halaman detail transaksi

                      Route route = MaterialPageRoute(
                        builder: (context) => TransactionDetail(
                          transactionId: transactionId,
                          date: date,
                          time: time,
                          priceTotal: priceTotal,
                        ),
                      );
                      Navigator.push(context, route);

                    },
                    child: Container(
                      child: Icon(Icons.print, color: Colors.white,),
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          elevation: 10,
        );
      },
    );
  }
}
