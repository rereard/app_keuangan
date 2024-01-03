import 'package:app_keuangan/daftar.dart';
import 'package:app_keuangan/home.dart';
import 'package:app_keuangan/model/textfield_mod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formLoginKey = GlobalKey<FormState>();

  void login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final navigator = Navigator.of(context);
      final email = _emailController.text;
      final password = _passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        throw ("Mohon isi semua kolom");
      } else {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((value) => {
                  navigator
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return const Home();
                  }))
                });
      }
    } catch (e) {
      final snackbar = SnackBar(
        content: Text(
          e.toString(),
          style: const TextStyle(fontSize: 17),
        ),
        backgroundColor: Colors.red,
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: const Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'Silahkan masuk untuk mengakses aplikasi!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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
                          key: _formLoginKey,
                          child: Column(
                            children: [
                              TextFieldMod(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                controller: _emailController,
                              ),
                              TextFieldMod(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                isPassword: true,
                                controller: _passwordController,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {
                                    login();
                                  },
                                  style: const ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                      Colors.white,
                                    ),
                                    shape: MaterialStatePropertyAll(
                                      StadiumBorder(),
                                    ),
                                    foregroundColor: MaterialStatePropertyAll(
                                      Colors.cyan,
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 17.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Text(
                        'Atau',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 10,
                        ),
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Daftar(),
                              ),
                            );
                          },
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Colors.cyan,
                            ),
                            shape: MaterialStatePropertyAll(
                              StadiumBorder(),
                            ),
                            foregroundColor: MaterialStatePropertyAll(
                              Colors.white,
                            ),
                            side: MaterialStatePropertyAll(
                              BorderSide(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Daftar akun baru',
                            style: TextStyle(
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
