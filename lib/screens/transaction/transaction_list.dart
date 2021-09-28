import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warung_makan_abg/screens/transaction/transaction_detail.dart';

class ListOfTransaction extends StatelessWidget {
  final List<DocumentSnapshot> document;

  ListOfTransaction({required this.document});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: document.length,
      itemBuilder: (BuildContext context, int i) {
        String transactionId = document[i]['transactionId'].toString();
        String date = document[i]['date'].toString();
        String time = document[i]['time'].toString();
        int priceTotal = document[i]['priceTotal'];

        final moneyCurrency = new NumberFormat("#,##0", "en_US");

        return GestureDetector(
          onTap: () {
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
            height: 120,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.lightBlueAccent,
            ),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    top: 7,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kode Transaksi: INV-' + transactionId,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Tanggal: ' + date,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Waktu: ' + time,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Total Harga: Rp.${moneyCurrency.format(priceTotal)}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
