// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'main.dart';

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final passwordInput = TextEditingController();
  final emailInput = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      builder: (context) => const Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Harita Yükleniyor...",
                style: TextStyle(fontSize: 25, color: Colors.white)),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator(
              color: Colors.red,
              // valueColor: AlwaysStoppedAnimation(getRandomColor()),
            ),
          ],
        ),
      ),
    );
    overlayState?.insert(overlayEntry);
    Future<void>.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/images/background.jpg"), context);
    final boatNameString = ModalRoute.of(context)!.settings.arguments as String;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 1,
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/background.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-0.02, 0.43),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 55, 133),
                        shape: const CircleBorder(
                            side: BorderSide(color: Colors.white))),
                    onPressed: () async {
                      if (formKey.currentState!.validate() &&
                          formKey2.currentState!.validate()) {
                        showOverlay(context);
                        dynamic user =
                            await _auth.createUserWithEmailAndPassword(
                                email: emailInput.text,
                                password: passwordInput.text);
                        await _firestore
                            .collection('users')
                            .doc(user.user?.email)
                            .set({
                          'name': boatNameString,
                          'email': emailInput.text,
                          'locationConfig': {}
                        });
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            settings:
                                RouteSettings(arguments: passwordInput.text),
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return const Main();
                            },
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 25),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -0.30),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 60, 30, 0),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: emailInput,
                      validator: (value) => value!.isEmpty
                          ? 'E-posta adresi boş bırakılamaz'
                          : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textCapitalization: TextCapitalization.none,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsetsDirectional.fromSTEB(5, 16, 0, 0),
                        hintText: 'E-posta',
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
                        focusedBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.redAccent.shade400,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -0.60),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 20, 0),
                  child: GradientText(
                    'E-posta ve şifreni belirle',
                    style:
                        const TextStyle(fontFamily: 'Montserrat', fontSize: 50),
                    colors: const [Color(0xFF0287F7), Color(0xFFB900FF)],
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -0.10),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 60, 30, 0),
                  child: Form(
                    key: formKey2,
                    child: TextFormField(
                      controller: passwordInput,
                      validator: (value) =>
                          value!.isEmpty ? 'Şifre boş bırakılamaz' : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textCapitalization: TextCapitalization.none,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsetsDirectional.fromSTEB(5, 16, 0, 0),
                        hintText: '*********',
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
                        focusedBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.redAccent.shade400,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              //   Align(
              //     alignment: const AlignmentDirectional(0, -0.50),
              //     child: Padding(
              //       padding: const EdgeInsetsDirectional.fromSTEB(28, 0, 20, 0),
              //       child: GradientText('Bir şifre belirle',
              //           style: const TextStyle(
              //               fontFamily: 'Montserrat', fontSize: 65),
              //           colors: const [Color(0xFF0287F7), Color(0xFFB900FF)]),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
