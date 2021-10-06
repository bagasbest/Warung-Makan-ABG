import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:warung_makan_abg/model/cart_model.dart';
import 'package:warung_makan_abg/screens/register_screen.dart';

class DatabaseService {
  static Future<XFile?> getImageGallery() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if ((image != null)) {
      return image;
    } else {
      return null;
    }
  }

  static Future<String?> uploadImageProduct(XFile imageFile) async {
    String filename = basename(imageFile.path);

    FirebaseStorage storage = FirebaseStorage.instance;
    final Reference reference = storage.ref().child('product/$filename');
    await reference.putFile(File(imageFile.path));

    String downloadUrl = await reference.getDownloadURL();
    if (downloadUrl != null) {
      return downloadUrl;
    } else {
      return null;
    }
  }

  static void setProduct(
      String name, String description, int price, int quantity, String image) {
    try {
      var timeInMillis = DateTime.now().millisecondsSinceEpoch;
      FirebaseFirestore.instance
          .collection('product')
          .doc(timeInMillis.toString())
          .set({
        'productId': timeInMillis.toString(),
        'name': name,
        'description': description,
        'quantity': quantity,
        'price': price,
        'image': image,
      });
    } catch (error) {
      toast(
          'Gagal menambahkan produk baru, silahkan cek koneksi anda dan coba lagi nanti');
    }
  }

  static void updateProduct(String name, String description, int price,
      int quantity, String image, String productId) {
    try {
      print(image);
      if (image != '') {
        FirebaseFirestore.instance.collection('product').doc(productId).update({
          'name': name,
          'description': description,
          'quantity': quantity,
          'image': image,
          'price': price,
        });
      } else {
        FirebaseFirestore.instance.collection('product').doc(productId).update({
          'name': name,
          'description': description,
          'quantity': quantity,
          'price': price,
        });
      }
    } catch (error) {
      toast(
          'Gagal memperbarui produk, silahkan cek koneksi anda dan coba lagi nanti');
    }
  }

  static addToCart(
    String productId,
    String name,
    int qty,
    int price,
    String image,
    String cartId,
    String description,
    int priceBase,
  ) {
    try {
      FirebaseFirestore.instance.collection('cart').doc(cartId).set({
        'cartId': cartId,
        'productId': productId,
        'name': name,
        'qty': qty,
        'price': price,
        'image': image,
        'description': description,
        'priceBase': priceBase,
      });
      toast('Sukses menambahkan produk ini kedalam keranjang');
    } catch (error) {
      toast('Gagal menambahkan produk ini kedalam keranjang');
    }
  }

  static updateCart(String cartId, int qty, int price) {
    try {
      FirebaseFirestore.instance.collection('cart').doc(cartId).update({
        'qty': qty,
        'price': price,
      });
      toast('Sukses memperbarui produk ini kedalam keranjang');
    } catch (error) {
      toast('Gagal memperbarui produk ini kedalam keranjang');
    }
  }

  static createTransaction(
    String transactionId,
    String date,
    String time,
    int priceTotal,
    List<CartModel> cartList,
    String month,
    int now,
  ) async {
    try {
      /// create invoice
      await FirebaseFirestore.instance
          .collection('invoice')
          .doc(transactionId)
          .set({
        'transactionId': transactionId,
        'date': date,
        'time': time,
        'priceTotal': priceTotal,
      });

      /// create history transaction
      for (int i = 0; i < cartList.length; i++) {
        try {
          FirebaseFirestore.instance
              .collection('history_transaction')
              .doc(cartList[i].cartId)
              .set({
            'cartId': cartList[i].cartId,
            'description': cartList[i].description,
            'image': cartList[i].image,
            'name': cartList[i].name,
            'price': cartList[i].price,
            'priceBase': cartList[i].priceBase,
            'productId': cartList[i].productId,
            'qty': cartList[i].qty,
            'transactionId': transactionId,
            'date': date,
            'time': time,
          });
        } catch (err) {
          print(err);
          return false;
        }
      }

      /// create balance
      await FirebaseFirestore.instance
          .collection('balance')
          .doc(transactionId)
          .set({
        'transactionId': transactionId,
        'date': date,
        'priceTotal': priceTotal,
        'month': month,
        'timeInMillis': now,
      });

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  static updateQuantityProduct(String productId, int newQty) {
    try {
      FirebaseFirestore.instance.collection('product').doc(productId).update({
        'quantity': newQty,
      });
      toast('Sukses memperbarui kuantitas produk ini');
    } catch (error) {
      toast('Gagal memperbarui kuantitas produk ini');
    }
  }
}
