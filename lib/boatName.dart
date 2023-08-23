// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'password.dart';

class BoatName extends StatefulWidget {
  const BoatName({Key? key}) : super(key: key);

  @override
  _BoatNameState createState() => _BoatNameState();
}

class _BoatNameState extends State<BoatName> {
  final boatNameInput = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/images/background.jpg"), context);
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
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            settings:
                                RouteSettings(arguments: boatNameInput.text),
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return const Password();
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
                alignment: const AlignmentDirectional(0, -0.05),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(30, 50, 30, 0),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: boatNameInput,
                      validator: (value) =>
                          value!.isEmpty ? 'Araç ismi boş bırakılamaz' : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textCapitalization: TextCapitalization.none,
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsetsDirectional.fromSTEB(5, 16, 0, 0),
                        hintText: 'Örneğin: Alabora',
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
                          Icons.directions_boat_rounded,
                          color: Colors.white,
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
                alignment: const AlignmentDirectional(0, -0.45),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: GradientText('Aracın için bir isim belirle',
                      style: const TextStyle(
                          fontFamily: 'Montserrat', fontSize: 53),
                      colors: const [Color(0xFF0287F7), Color(0xFFB900FF)]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
