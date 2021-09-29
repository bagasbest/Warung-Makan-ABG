import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warung_makan_abg/screens/transaction/transaction_detail_list.dart';
import 'package:warung_makan_abg/widget/loading_widget.dart';

class TransactionDetail extends StatefulWidget {
  final String transactionId;
  final String date;
  final String time;
  final int priceTotal;

  TransactionDetail({
    required this.transactionId,
    required this.date,
    required this.time,
    required this.priceTotal,
  });

  @override
  _TransactionDetailState createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  final moneyCurrency = new NumberFormat("#,##0", "en_US");

  String _role = '';

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeRole();
  }

  _initializeRole() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      _role = value.data()!['role'].toString();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? LoadingWidget()
        : Scaffold(
            floatingActionButton: (_role == 'owner')
                ? FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _showConfirmationDeleteTransaction();
                    },
                  )
                : Container(),
            appBar: AppBar(
              backgroundColor: Colors.lightBlueAccent,
              title: Text(
                'Transaksi INV-' + widget.transactionId,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                      top: 16,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        /// cetak transaksi ke printer

                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          child: Container(
                            height: 40,
                            width: 40,
                            child: Icon(
                              Icons.print,
                              color: Colors.lightBlueAccent,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kode Transaksi: INV-' + widget.transactionId,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Tanggal Transaksi: ' + widget.date,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Waktu Transaksi: ' + widget.time,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Total Harga: Rp.${moneyCurrency.format(widget.priceTotal)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            thickness: 2,
                            color: Colors.grey,
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Daftar Produk',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nama Produk',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Kuantitas',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Harga Pokok',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Total Harga',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.576,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('history_transaction')
                                .where(
                                  'transactionId',
                                  isEqualTo: widget.transactionId,
                                )
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              return (snapshot.hasData)
                                  ? (snapshot.data!.size > 0)
                                      ? ListOfHistoryTransaction(
                                          document: snapshot.data!.docs,
                                        )
                                      : Container()
                                  : Container();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }

  _showConfirmationDeleteTransaction() {
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
                  'Konfirmasi Hapus Transaksi',
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
                'Apakah anda yakin ingin menghapus transaksi ini ?',
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

              /// delete invoice by transactionId
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('invoice')
                    .doc(widget.transactionId)
                    .delete();

                /// delete transaction_history by transactionId
                var snapshot = await FirebaseFirestore.instance
                    .collection('history_transaction')
                    .where('transactionId', isEqualTo: widget.transactionId)
                    .get();
                for (var doc in snapshot.docs) {
                  await doc.reference.delete();
                }

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
          elevation: 10,
        );
      },
    );
  }
}
