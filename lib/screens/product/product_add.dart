import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warung_makan_abg/databases/database_service.dart';

import '../register_screen.dart';

class ProductAdd extends StatefulWidget {
  const ProductAdd({Key? key}) : super(key: key);

  @override
  _ProductAddState createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAdd> {
  var _name = TextEditingController();
  var _description = TextEditingController();
  var _quantity = TextEditingController();
  var _price = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool visible = false;
  bool isImageAdd = false;
  XFile? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Tambahkan Produk Baru'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Row(
                  children: [
                    (!isImageAdd)
                        ? GestureDetector(
                            onTap: () async {
                              _image =
                                  (await DatabaseService.getImageGallery())!;
                              if (_image == null) {
                                setState(() {
                                  print("Gagal ambil foto");
                                });
                              } else {
                                setState(() {
                                  isImageAdd = true;
                                  toast('Berhasil menambah foto');
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DottedBorder(
                                color: Colors.grey,
                                strokeWidth: 1,
                                dashPattern: [6, 6],
                                child: Container(
                                  child: Center(
                                    child: Text("* Tambah Foto"),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              File(
                                _image!.path,
                              ),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Align(
                        child: Row(
                          children: [
                            Text(
                              "Nama Produk",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "*",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _name,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Masukkan Nama Produk",
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Nama produk tidak boleh kosong";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                color: Colors.white,
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Align(
                        child: Row(
                          children: [
                            Text(
                              "Deskripsi Produk",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "*",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      TextFormField(
                        controller: _description,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Masukkan Deskripsi Produk",
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Deskripsi produk tidak boleh kosong";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                color: Colors.white,
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Align(
                        child: Row(
                          children: [
                            Text(
                              "Harga Produk",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "*",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _price,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Masukkan Harga Produk",
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Harga produk tidak boleh kosong";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                color: Colors.white,
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Align(
                        child: Row(
                          children: [
                            Text(
                              "Kuantitas Produk",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "*",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _quantity,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Masukkan Kuantitas Produk",
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Kuantitas produk tidak boleh kosong";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                color: Colors.white,
              ),
              SizedBox(
                height: 7,
              ),
              Visibility(
                visible: visible,
                child: SpinKitRipple(
                  color: Colors.orange,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && _image != null) {
                        setState(() {
                          visible = true;
                        });

                        String? url = (_image != null)
                            ? await DatabaseService.uploadImageProduct(_image!)
                            : null;

                        DatabaseService.setProduct(
                          _name.text,
                          _description.text,
                          int.parse(_price.text),
                          int.parse(_quantity.text),
                          (url != null) ? url : '',
                        );

                        setState(() {
                          visible = false;
                          _formKey.currentState!.reset();
                          _image = null;
                          isImageAdd = false;
                          showAlertDialog(context);
                        });
                      } else if(_image == null) {
                        toast('Pastikan anda mengunggah gambar produk');
                      }
                    },
                    child: Text("Unggah Produk",
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    color: Colors.white,
                  ),
                ),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        backgroundColor: Theme.of(context).primaryColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Sukses Diunggah',
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
              'Anda berhasil mengunggah produk baru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 250,
                height: 50,
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
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        elevation: 10,
      );
    },
  );
}
