import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  void showOverlay(BuildContext context) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 200,
                // color: const Color.fromARGB(121, 0, 0, 0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromARGB(246, 0, 0, 0)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                    // const Text("Harita Yükleniyor...",
                    //     style: TextStyle(fontSize: 25, color: Colors.white)),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // CircularProgressIndicator(
                    //   color: Colors.red,
                    //   // valueColor: AlwaysStoppedAnimation(
                    //   //     getRandomColor()),
                    // ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
    overlayState?.insert(overlayEntry);
    Future<void>.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Firebase.initializeApp();
    // CollectionReference users = FirebaseFirestore.instance.collection('users');
    // users.add({'test': 'test1'});
    // print(users);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 1,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://img.freepik.com/free-vector/blue-neon-synthewave-patterned-background-vector_53876-173388.jpg?w=740&t=st=1685046966~exp=1685047566~hmac=054fd4207fbf15b5f64af357c6743f414975ba0c7a3217e0ccf7ef457217eb25',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 1,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-0.02, 0.56),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    // Timer colorTimer =
                    FocusScope.of(context).unfocus();
                    showOverlay(context);
                    Future<void>.delayed(const Duration(seconds: 2), () {
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text)
                          .then(
                              (value) => Navigator.pushNamed(context, "/main"));
                    });
                    // print('IconButton pressed ...');
                  },
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -0.05),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 50, 30, 0),
                  child: TextFormField(
                    controller: passwordController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.none,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.grey.shade500,
                      ),
                      hintStyle: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.grey.shade500,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -0.45),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -0.25),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 50, 30, 0),
                  child: TextFormField(
                    controller: emailController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.none,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      labelStyle: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.grey.shade500,
                      ),
                      hintStyle: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.grey.shade500,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.start,
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
