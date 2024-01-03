import 'package:app_keuangan/detail.dart';
import 'package:app_keuangan/edit.dart';
import 'package:app_keuangan/login.dart';
import 'package:app_keuangan/model/allFunction.dart';
import 'package:app_keuangan/model/transaksi.dart';
import 'package:app_keuangan/tambah.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

var noSimbolInIDFormat = NumberFormat.currency(locale: "id_ID", symbol: "");

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String nama = '';

  @override
  void initState() {
    super.initState();
    userName();
  }

  Future<void> _signOut() async {
    await _auth.signOut().then((value) => {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return const Login();
          }), (route) => false)
        });
  }

  Future<void> userName() async {
    try {
      // Reference to the user collection
      CollectionReference users = _firestore.collection('Users');

      // Get the document snapshot using the document ID
      DocumentSnapshot userSnapshot =
          await users.doc(_auth.currentUser?.uid).get();

      print(userSnapshot['nama']);
      // Now, you can use the userData as needed
      setState(() {
        nama = userSnapshot['nama'];
      });
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  Future<void> deleteTransaksi(docId) async {
    await _firestore.collection('transaksi').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference transaksiCollecction =
        _firestore.collection('transaksi');
    final User? user = _auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          nama,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        elevation: 0,
        titleSpacing: 0,
        leadingWidth: 65,
        leading: Container(
          padding: const EdgeInsets.only(left: 15, right: 8, top: 4, bottom: 4),
          child: ClipRRect(
            // padding: const EdgeInsets.only(left: 10, right: 10),
            borderRadius: BorderRadius.circular(80),
            child: Image.network(
              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
            ),
          ),
        ),
        toolbarHeight: 65,
        actions: [
          Container(
              padding: const EdgeInsets.only(right: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  enableFeedback: false,
                  alignment: Alignment.center,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Apakah anda yakin ingin logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Tidak'),
                        ),
                        TextButton(
                          onPressed: () {
                            _signOut();
                          },
                          child: const Text('Ya'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(
                  Icons.logout_rounded,
                  size: 33,
                  color: Colors.cyan,
                ),
              ))
        ],
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 75),
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.zero,
              child: const Text(
                'Catatan Keuangan',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 160,
              margin: const EdgeInsets.symmetric(vertical: 15.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo anda saat ini',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Rp 100.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('transaksi')
                  .where('uid', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == null || snapshot.data?.size == 0) {
                  return const Center(
                    child: Text(
                      "Tidak ada transaksi",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  List<Transaksi> listTransaksi =
                      snapshot.data!.docs.map((document) {
                    final data = document.data();
                    final String uid = user.uid;
                    final String foto = data['foto'];
                    final int kategori = data['kategori'];
                    final String keterangan = data['keterangan'];
                    final String namaTransaksi = data['nama_transaksi'];
                    final int nominal = data['nominal'];
                    final Timestamp tglTransaksi = data['tgl_transaksi'];

                    return Transaksi(foto, kategori, keterangan, namaTransaksi,
                        nominal, tglTransaksi,
                        uid: uid);
                  }).toList();
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listTransaksi.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var transaksi = listTransaksi[index];
                      var transaksiDocId = snapshot.data!.docs[index].id;
                      return itemTransaksi(
                          id: transaksiDocId,
                          namaTransaksi: transaksi.namaTransaksi,
                          tglTransaksi: transaksi.tglTransaksi,
                          kategori: transaksi.kategori,
                          nominal: transaksi.nominal,
                          imgUrl: transaksi.foto);
                    },
                  );
                }
              },
            ),
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Tambah()));
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
    );
  }

  Container itemTransaksi(
      {required String id,
      required namaTransaksi,
      required Timestamp tglTransaksi,
      required int nominal,
      required int kategori,
      required String imgUrl}) {
    DateTime dateTransaksi = DateTime.parse(tglTransaksi.toDate().toString());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        borderRadius: BorderRadius.circular(25),
        elevation: 5,
        child: ListTile(
          minLeadingWidth: 8,
          onLongPress: () {
            dialog(title: namaTransaksi, docId: id, imgUrl: imgUrl);
          },
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Detail(
                          docId: id,
                        )));
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          trailing: Text(
            kategori == 3
                ? '+Rp ${noSimbolInIDFormat.format(nominal)}'
                : '-Rp ${noSimbolInIDFormat.format(nominal)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kategori == 3 ? Colors.green : Colors.red,
            ),
          ),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                kategori == 1
                    ? Icons.account_balance_wallet
                    : kategori == 2
                        ? Icons.payments
                        : kategori == 3
                            ? Icons.attach_money
                            : kategori == 4
                                ? Icons.payment
                                : null,
                size: 30,
                color: Colors.cyan,
              ),
            ],
          ),
          title: Text(
            namaTransaksi,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyy').format(dateTransaksi),
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> dialog({String? title, String? docId, String? imgUrl}) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title!),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Edit(
                              docId: docId!,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        shape: const StadiumBorder(),
                        foregroundColor: Colors.black,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit),
                          Text(
                            ' Edit',
                            style: TextStyle(fontSize: 17.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (imgUrl == '') {
                          deleteTransaksi(docId);
                          Navigator.pop(context);
                        } else {
                          deleteImageFromFirebaseStorage(imgUrl!)
                              .then((value) => deleteTransaksi(docId));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: const StadiumBorder(),
                        foregroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete),
                          Text(
                            ' Hapus',
                            style: TextStyle(fontSize: 17.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }
}
