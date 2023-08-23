// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'boatName.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();
  late AnimationController animationController;
  late AnimationController animationController2;
  late Animation<Offset> slideAnimation;
  late Animation<Offset> slideAnimation2;

  Future<String> loadBackground() async {
    await Future.delayed(const Duration(seconds: 5));
    return "assets/images/background.jpg";
  }

  Future<void> requestPermission() async {
    if (await Permission.location.isGranted) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            pageBuilder: (context, animation, secondaryAnimation) {
              return const BoatName();
            },
          ));
    } else {
      await Permission.location.request();
      if (await Permission.location.isDenied) {
        // ignore: use_build_context_synchronously
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Uygulama İzini',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text(
                        'Uygulamanın tam fonksiyonlu olarak çalışması için navigasyon izinlerini kabul etmelisin. Buraya tıklayarak uygulama izinlerini aktifleştir.'),
                    onTap: () async {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = const Offset(1.0, 0.0);
                var end = Offset.zero;
                var curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              pageBuilder: (context, animation, secondaryAnimation) {
                return const BoatName();
              },
            ));
        // ignore: use_build_context_synchronously
      }
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    final curvedAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOutExpo);
    CurvedAnimation(parent: animationController2, curve: Curves.fastOutSlowIn);

    slideAnimation = Tween<Offset>(
      begin: const Offset(-3.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(curvedAnimation);
    slideAnimation2 = Tween<Offset>(
      begin: const Offset(0.0, -4.0),
      end: const Offset(0.0, 0.0),
    ).animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/images/background.jpg"), context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        body: FutureBuilder<String>(
            future: loadBackground(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                );
              } else {
                animationController.forward();
                animationController2.forward();
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 1,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, -0.5),
                        child: SlideTransition(
                          position: slideAnimation,
                          child: GradientText(
                            'Hoş\nGeldin! ',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 80,
                            ),
                            colors: const [
                              Color(0xFF0287F7),
                              Color(0xFFB900FF)
                            ],
                            gradientDirection: GradientDirection.ltr,
                            gradientType: GradientType.linear,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, 0.15),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              10, 0, 10, 0),
                          child: SlideTransition(
                            position: slideAnimation2,
                            child: const Text(
                              'Uygulamayı kullanmak için birkaç adımı tamamlaman gerekli.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 23,
                                  color: Colors.white),
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
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 55, 133),
                                shape: const CircleBorder(
                                    side: BorderSide(color: Colors.white))),
                            onPressed: requestPermission,
                            child: const Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 25),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
