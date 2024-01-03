import 'package:app_keuangan/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

class Detail extends StatefulWidget {
  final String docId;
  const Detail({super.key, required this.docId});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String errorMsg = '';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? transaksi;
  bool _isLoading = false;

  Future<void> transact() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Reference to the user collection
      CollectionReference transaksis = _firestore.collection('transaksi');

      // Get the document snapshot using the document ID
      DocumentSnapshot transaksiGet = await transaksis.doc(widget.docId).get();

      if (transaksiGet.exists) {
        Map<String, dynamic> transactionData =
            transaksiGet.data() as Map<String, dynamic>;
        print(transactionData['nama_transaksi']);
        setState(() {
          transaksi = transactionData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    transact();
  }

  @override
  Widget build(BuildContext context) {
    // print(transaksi!['nama_transaksi']);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: !_isLoading
          ? errorMsg != ''
              ? Center(
                  child: Text(
                    errorMsg,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewPage(
                                    imageUrl: transaksi!['foto'] == ''
                                        ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/450px-No_image_available.svg.png'
                                        : transaksi!['foto']),
                              ),
                            ),
                            child: Image.network(
                              transaksi!['foto'] == ''
                                  ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/450px-No_image_available.svg.png'
                                  : transaksi!['foto'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        transaksi!['kategori'] == 1
                                            ? Icons.account_balance_wallet
                                            : transaksi!['kategori'] == 2
                                                ? Icons.payments
                                                : transaksi!['kategori'] == 3
                                                    ? Icons.attach_money
                                                    : transaksi!['kategori'] ==
                                                            4
                                                        ? Icons.payment
                                                        : null,
                                        size: 30,
                                        color: Colors.cyan,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaksi!['nama_transaksi'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            DateFormat('dd/MM/yyy').format(
                                                DateTime.parse(
                                                    transaksi!['tgl_transaksi']
                                                        .toDate()
                                                        .toString())),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    transaksi!['kategori'] == 3
                                        ? '+Rp ${noSimbolInIDFormat.format(transaksi!['nominal'])}'
                                        : '-Rp ${noSimbolInIDFormat.format(transaksi!['nominal'])}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: transaksi!['kategori'] == 3
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Keterangan Transaksi:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      transaksi!['keterangan'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
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
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.0,
        initialScale: PhotoViewComputedScale.contained,
      ),
    );
  }
}
