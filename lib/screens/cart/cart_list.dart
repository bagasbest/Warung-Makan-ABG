import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'cart_detail.dart';

class ListOfCart extends StatelessWidget {
  final List<DocumentSnapshot> document;

  ListOfCart({required this.document});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: document.length,
      itemBuilder: (BuildContext context, int i) {
        String productId = document[i]['productId'].toString();
        String cartId = document[i]['cartId'].toString();
        String name = document[i]['name'].toString();
        int quantity = document[i]['qty'];
        String image = document[i]['image'].toString();
        int price = document[i]['price'];
        String description = document[i]['description'].toString();
        int priceBase = document[i]['priceBase'];

        final moneyCurrency = new NumberFormat("#,##0", "en_US");

        return GestureDetector(
          onTap: () {
            Route route = MaterialPageRoute(
                builder: (context) => CartDetail(
                  productId: productId,
                  cartId: cartId,
                  name: name,
                  qty: quantity,
                  description: description,
                  price: price,
                  image: image,
                  priceBase: priceBase,
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
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  child: Image.network(
                    (image != '')
                        ? image
                        : 'https://images.unsplash.com/photo-1579621970795-87facc2f976d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80',
                    height: 120,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 116),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16,),
                      Text(
                        'Total Pembelian: $quantity pcs',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total Harga: Rp.${moneyCurrency.format(price)}',
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
