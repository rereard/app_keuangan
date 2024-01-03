import 'package:cloud_firestore/cloud_firestore.dart';

class Transaksi {
  final String uid;
  final String foto;
  final int kategori;
  final String keterangan;
  final String namaTransaksi;
  final int nominal;
  final Timestamp tglTransaksi;

  Transaksi(
    this.foto,
    this.kategori,
    this.keterangan,
    this.namaTransaksi,
    this.nominal,
    this.tglTransaksi, {
    required this.uid,
  });
}
