import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:warung_makan_abg/screens/register_screen.dart';


class DatabaseService {
  static Future<XFile?> getImageGallery() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if ((image != null)) {
      return image;
    } else {
      return null;
    }
  }

  static Future<String?> uploadImageProduct(XFile imageFile) async {
    String filename = basename(imageFile.path);

    FirebaseStorage storage = FirebaseStorage.instance;
    final Reference reference =
    storage.ref().child('product/$filename');
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

  static void updateProduct(
      String name, String description, int price, int quantity, String image, String productId) {
    try {
      print(image);
      if(image != '') {
        FirebaseFirestore.instance
            .collection('product')
            .doc(productId)
            .update({
          'name': name,
          'description': description,
          'quantity': quantity,
          'image': image,
          'price': price,
        });
      } else {
        FirebaseFirestore.instance
            .collection('product')
            .doc(productId)
            .update({
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


}