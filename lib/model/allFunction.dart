import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

Future<void> deleteImageFromFirebaseStorage(String downloadURL) async {
  try {
    firebase_storage.Reference storageReference =
        await firebase_storage.FirebaseStorage.instance.refFromURL(downloadURL);
    await storageReference.delete();
  } catch (e) {
    throw e.toString();
  }
}

DateTime dateStringToTimestamp(String dateString) {
  List<String> dateParts = dateString.split('/');
  int day = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int year = int.parse(dateParts[2]);
  DateTime date = DateTime(year, month, day);
  return date;
}

enum KategoriLabel {
  topup('Topup', 1),
  bayar(
    'Pembayaran',
    2,
  ),
  masuk('Uang Masuk', 3),
  tf('Transfer', 4);

  const KategoriLabel(this.label, this.id);
  final String label;
  final int id;
}

KategoriLabel? getCategoryById(int id) {
  for (KategoriLabel category in KategoriLabel.values) {
    if (category.id == id) {
      return category;
    }
  }
  // Handle the case when no matching id is found
  return null;
}

class PhotoViewPage extends StatelessWidget {
  final bool fromInternet;
  final String imageUrl;
  const PhotoViewPage(
      {super.key, required this.imageUrl, this.fromInternet = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: PhotoView(
        imageProvider: fromInternet
            ? NetworkImage(imageUrl)
            : FileImage(File(imageUrl)) as ImageProvider,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.0,
        initialScale: PhotoViewComputedScale.contained,
      ),
    );
  }
}
