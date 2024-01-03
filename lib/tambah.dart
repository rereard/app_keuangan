import 'package:app_keuangan/home.dart';
import 'package:app_keuangan/model/allFunction.dart';
import 'package:app_keuangan/model/textfield_mod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Tambah extends StatefulWidget {
  const Tambah({super.key});

  @override
  State<Tambah> createState() => _TambahState();
}

class _TambahState extends State<Tambah> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formTambahKey = GlobalKey<FormState>();
  int dropdownValue = 0;
  List<XFile>? _mediaFileList;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _namaTransaksiController =
      TextEditingController();
  final TextEditingController _tglTransaksiController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  bool _isLoading = false;

  Future<String> uploadImageToFirebaseStorage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('images/$fileName');

    firebase_storage.UploadTask uploadTask =
        storageReference.putFile(imageFile);

    await uploadTask.whenComplete(() => {
          setState(() {
            _isLoading = false;
          })
        });

    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final _formTambahKey = GlobalKey<FormState>();
    CollectionReference transaksiCollection =
        _firestore.collection('transaksi');
    Future<void> addTransaksi(String imageUrl) {
      return transaksiCollection.add({
        'foto': imageUrl,
        'kategori': dropdownValue,
        'keterangan': _keteranganController.text,
        'nama_transaksi': _namaTransaksiController.text,
        'nominal': int.parse(_nominalController.text),
        'tgl_transaksi': Timestamp.fromDate(
            dateStringToTimestamp(_tglTransaksiController.text)),
        'uid': _auth.currentUser!.uid,
        // ignore: invalid_return_type_for_catch_error
      }).catchError((error) => print('Failed to add transaksi: $error'));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Transaksi',
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(
                          bottom: 10,
                          top: 30,
                        ),
                        child: const Text(
                          'Transaksi Baru',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          left: 40,
                          right: 40,
                          top: 20,
                          bottom: 10,
                        ),
                        child: Form(
                          key: _formTambahKey,
                          child: Column(
                            children: [
                              TextFieldMod(
                                labelText: 'Nama Transaksi',
                                prefixIcon: const Icon(Icons.receipt),
                                dark: true,
                                controller: _namaTransaksiController,
                                mustNotEmpty: true,
                              ),
                              TextFieldMod(
                                labelText: 'Tanggal transaksi',
                                prefixIcon: const Icon(Icons.calendar_month),
                                dark: true,
                                datepicker: true,
                                controller: _tglTransaksiController,
                                mustNotEmpty: true,
                              ),
                              TextFieldMod(
                                labelText: 'Nominal',
                                prefixIcon: const Icon(Icons.attach_money),
                                dark: true,
                                number: true,
                                controller: _nominalController,
                                mustNotEmpty: true,
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: DropdownMenu(
                                  controller: _kategoriController,
                                  width: 250,
                                  trailingIcon: const Icon(
                                    Icons.arrow_drop_down_outlined,
                                    color: Colors.cyan,
                                  ),
                                  leadingIcon: const Icon(
                                    Icons.category,
                                    color: Colors.cyan,
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    labelStyle:
                                        const TextStyle(color: Colors.cyan),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.cyan,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.cyan,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  label: const Text('Kategori'),
                                  // width: double.infinity,
                                  onSelected: (KategoriLabel? value) {
                                    // This is called when the user selects an item.
                                    setState(() {
                                      dropdownValue = value!.id;
                                    });
                                    _kategoriController.text = value!.label;
                                    print(dropdownValue);
                                  },
                                  dropdownMenuEntries: KategoriLabel.values
                                      .map<DropdownMenuEntry<KategoriLabel>>(
                                    (KategoriLabel kategori) {
                                      return DropdownMenuEntry<KategoriLabel>(
                                        value: kategori,
                                        label: kategori.label,
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                              TextFieldMod(
                                labelText: 'Keterangan',
                                dark: true,
                                textArea: true,
                                controller: _keteranganController,
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: const Text(
                                  'Bukti Transaksi',
                                  style: TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: _mediaFileList == null
                                    ? Row(
                                        children: [
                                          FloatingActionButton(
                                            backgroundColor: Colors.cyan,
                                            onPressed: () {
                                              _onImageButtonPressed(
                                                ImageSource.gallery,
                                                context: context,
                                              );
                                            },
                                            heroTag: 'image0',
                                            tooltip: 'Pick Image from gallery',
                                            child: const Icon(Icons.photo),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          FloatingActionButton(
                                            backgroundColor: Colors.cyan,
                                            onPressed: () {
                                              _onImageButtonPressed(
                                                ImageSource.camera,
                                                context: context,
                                              );
                                            },
                                            heroTag: 'image1',
                                            tooltip: 'Pick Image from Camera',
                                            child: const Icon(Icons.camera_alt),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                              if (_mediaFileList != null)
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      child: InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PhotoViewPage(
                                              imageUrl: _mediaFileList![0].path,
                                            ),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.file(
                                            File(_mediaFileList![0].path),
                                            errorBuilder: (BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace) {
                                              return const Center(
                                                  child: Text(
                                                      'This image type is not supported'));
                                            },
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          backgroundColor: Colors.transparent,
                                          shadowColor:
                                              Colors.transparent.withOpacity(0),
                                          foregroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _mediaFileList = null;
                                          });
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          size: 26.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 20),
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!_formTambahKey.currentState!
                                            .validate() &&
                                        dropdownValue == 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                          "Tolong diisi",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        backgroundColor: Colors.red,
                                      ));
                                    } else {
                                      if (_mediaFileList == null) {
                                        addTransaksi('').then(
                                            (value) => Navigator.pop(context));
                                      } else {
                                        uploadImageToFirebaseStorage(
                                                File(_mediaFileList![0].path))
                                            .then((value) =>
                                                {addTransaksi(value)})
                                            .then((val) =>
                                                {Navigator.pop(context)});
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyan,
                                    shape: const StadiumBorder(),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'Tambah',
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      try {
        final List<XFile> pickedFileList = <XFile>[];
        final XFile? media = await _picker.pickImage(source: source);
        if (media != null) {
          pickedFileList.add(media);
          setState(() {
            _mediaFileList = pickedFileList;
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

class PhotoViewPage extends StatelessWidget {
  final String imageUrl;
  const PhotoViewPage({super.key, required this.imageUrl});

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
        imageProvider: FileImage(File(imageUrl)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.0,
        initialScale: PhotoViewComputedScale.contained,
      ),
    );
  }
}
