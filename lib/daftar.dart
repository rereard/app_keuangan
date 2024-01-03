import 'package:app_keuangan/login.dart';
import 'package:app_keuangan/model/textfield_mod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Daftar extends StatefulWidget {
  const Daftar({super.key});

  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHPController = TextEditingController();
  final TextEditingController _cfPasswordController = TextEditingController();

  void toLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const Login();
    }));
  }

  Future addUser(String nama, String email, String password, String noHP,
      String uid) async {
    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'nama': nama,
      'email': email,
      'password': password,
      'noHp': noHP,
    });
  }

  Future register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      final cfPassword = _cfPasswordController.text;
      final nama = _namaController.text;
      final noHP = _noHPController.text;

      if (email.isEmpty ||
          password.isEmpty ||
          nama.isEmpty ||
          noHP.isEmpty ||
          cfPassword.isEmpty) {
        throw ("Mohon isi semua data");
      } else {
        if (password.length < 6) {
          throw ("Password harus setidaknya minimal 6 kata");
        } else {
          await _auth
              .createUserWithEmailAndPassword(email: email, password: password)
              .then((value) async {
            await addUser(
              nama,
              email,
              password,
              noHP,
              value.user!.uid.toString(),
            ).then((value) {
              toLogin();
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  "Berhasil mendaftarkan akun",
                  style: TextStyle(fontSize: 17),
                ),
                backgroundColor: Colors.green,
              ));
            });
          });
        }
      }
    } catch (error) {
      final snackBar = SnackBar(
        content: Text(
          error.toString(),
          style: const TextStyle(fontSize: 17),
        ),
        backgroundColor: Colors.red,
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final _formDaftarKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                        top: 30,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'Daftar Akun',
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                shape: const CircleBorder(),
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(6),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                size: 29.0,
                              ),
                            ),
                          ),
                        ],
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
                        key: _formDaftarKey,
                        child: Column(
                          children: [
                            TextFieldMod(
                              labelText: 'Nama',
                              prefixIcon: const Icon(Icons.person_outline),
                              controller: _namaController,
                            ),
                            TextFieldMod(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              controller: _emailController,
                            ),
                            TextFieldMod(
                              labelText: 'Nomor HP',
                              prefixIcon:
                                  const Icon(Icons.phone_android_outlined),
                              controller: _noHPController,
                            ),
                            TextFieldMod(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              isPassword: true,
                              controller: _passwordController,
                            ),
                            TextFieldMod(
                              labelText: 'Konfirmasi Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              isPassword: true,
                              controller: _cfPasswordController,
                              confirmController: _passwordController,
                              formKey: _formDaftarKey,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  bool? validate =
                                      _formDaftarKey.currentState?.validate();
                                  if (!validate!) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                        "Yang bener dong",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      backgroundColor: Colors.red,
                                    ));
                                  } else {
                                    register();
                                  }
                                  // ;
                                  print(
                                      _formDaftarKey.currentState?.validate());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  foregroundColor: Colors.cyan,
                                ),
                                child: const Text(
                                  'Daftar',
                                  style: TextStyle(fontSize: 17.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
