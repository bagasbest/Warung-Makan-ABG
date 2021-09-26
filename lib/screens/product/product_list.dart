import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:warung_makan_abg/screens/product/product_detail.dart';

class ListOfProduct extends StatelessWidget {
  final List<DocumentSnapshot> document;

  ListOfProduct({required this.document});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(document.length, (i) {
        String productId = document[i]['productId'].toString();
        String name = document[i]['name'].toString();
        int quantity = document[i]['quantity'];
        String description = document[i]['description'].toString();
        String image = document[i]['image'].toString();
        int price = document[i]['price'];
        return GestureDetector(
          onTap: () {
            Route route = MaterialPageRoute(
                builder: (context) => ProductDetail(
                  productId: productId,
                  name: name,
                  quantity: quantity,
                  description: description,
                  price: price,
                  image: image,
                ));
            Navigator.push(context, route);
          },
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    (image != '')
                        ? image
                        : 'https://images.unsplash.com/photo-1579621970795-87facc2f976d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80',
                    height: 100,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 110),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
