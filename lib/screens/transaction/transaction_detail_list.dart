import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListOfHistoryTransaction extends StatelessWidget {
  final List<DocumentSnapshot> document;

  ListOfHistoryTransaction({required this.document});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: document.length,
      itemBuilder: (BuildContext context, int i) {
        String name = document[i]['name'].toString();
        int qty = document[i]['qty'];
        int priceBase = document[i]['priceBase'];
        int price = document[i]['price'];

        final moneyCurrency = new NumberFormat("#,##0", "en_US");

        return Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 90,
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(qty.toString()),
              Text("Rp.${moneyCurrency.format(priceBase)}"),
              Text("Rp.${moneyCurrency.format(price)}"),
            ],
          ),
        );
      },
    );
  }
}
