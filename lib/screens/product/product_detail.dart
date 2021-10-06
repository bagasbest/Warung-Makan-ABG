import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:warung_makan_abg/databases/database_service.dart';
import 'package:warung_makan_abg/screens/product/product_edit.dart';

import '../register_screen.dart';

class ProductDetail extends StatefulWidget {
  final String productId;
  final String name;
  final int quantity;
  final String description;
  final int price;
  final String image;

  ProductDetail({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.description,
    required this.price,
    required this.image,
  });

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  String role = '';

  var _qty = TextEditingController();
  var _qtyAdd = TextEditingController();

  final _formKey = GlobalKey<FormState>();


  _initializeRole() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      setState(() {
        role = value.data()!['role'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeRole();
    _qty.text = "1";
    _qtyAdd.text = "1";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          /// konfirmasi menambahkan barang kedalam keranjang
          _showConfirmAddProduct();
        },
        child: Icon(
          Icons.shopping_cart_sharp,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Detail Produk',
        ),
        backgroundColor: Colors.lightBlueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          (role == 'owner')
              ? PopupMenuButton(
                  onSelected: _handleClick,
                  itemBuilder: (BuildContext context) {
                    return {'Edit Produk', 'Hapus Produk', 'Tambah Kuantitas Produk'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              (widget.image != '')
                  ? widget.image
                  : 'https://images.unsplash.com/photo-1579621970795-87facc2f976d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          widget.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga: Rp.' + widget.price.toString(),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Tersedia: ' + widget.quantity.toString() + ' pcs',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleClick(String value) {
    switch (value) {
      case 'Edit Produk':
        Route route = MaterialPageRoute(
            builder: (context) => ProductEdit(
                  productId: widget.productId,
                  name: widget.name,
                  description: widget.description,
                  image: widget.image,
                  quantity: widget.quantity,
                  price: widget.price,
                ));
        Navigator.push(context, route);
        break;
      case 'Hapus Produk':
        _deleteProduct(context, widget.productId);
        break;
      case 'Tambah Kuantitas Produk' :
        _showAddQtyProduct();
    }
  }

  _showAddQtyProduct() {
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
                  'Tambah Kuantitas Produk',
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
                'Tersedia ${widget.quantity} pcs, anda ingin menambahkan stok berapa banyak ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 10,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _qtyAdd,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan Kuantitas',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Kuantitas tidak boleh kosong';
                      } else if (value == '0') {
                        return 'Kuantitas tidak boleh 0';
                      } else {
                        return null;
                      }
                    },
                  ),
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

                if(_formKey.currentState!.validate()) {
                  int newQty = widget.quantity + int.parse(_qtyAdd.text);

                  await DatabaseService.updateQuantityProduct(
                    widget.productId,
                    newQty,
                  );

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
          elevation: 10,
        );
      },
    );
  }

  _showConfirmAddProduct() {
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
                  'Konfirmasi Order',
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
                'Tersedia ${widget.quantity} pcs, anda ingin order berapa banyak ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 10,
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _qty,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText: 'Input Kuantitas',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Kuantitas tidak boleh kosong';
                      } else if (value == '0') {
                        return 'Kuantitas tidak boleh 0';
                      } else {
                        return null;
                      }
                    },
                  ),
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

                if(int.parse(_qty.text) <= widget.quantity && _formKey.currentState!.validate()) {
                  int price = int.parse(_qty.text) * widget.price;
                  var timeInMillis = DateTime.now().millisecondsSinceEpoch;

                  await DatabaseService.addToCart(
                    widget.productId,
                    widget.name,
                    int.parse(_qty.text),
                    price,
                    widget.image,
                    timeInMillis.toString(),
                    widget.description,
                    widget.price,
                  );
                } else {
                  toast('Kuantitas produk tidak mencukupi untuk order');
                }

                Navigator.of(context).pop();
              },
            ),
          ],
          elevation: 10,
        );
      },
    );
  }

  _deleteProduct(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text('Konfirmasi Menghapus'),
              Icon(
                Icons.delete,
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
          content: Text(
              'Apakah anda yakin ingin menghapus produk "${widget.name}" ?'),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('product')
                    .doc(uid)
                    .delete()
                    .then(
                      (value) => {
                        toast(
                          'Berhasil Menghapus Produk ${widget.name}',
                        ),
                      },
                    )
                    .catchError(
                  (error) {
                    toast('Gagal Menghapus Produk ${widget.name}');
                  },
                );
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
