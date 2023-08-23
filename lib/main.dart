// import '../yedekLib/bluetooth2.dart';
// import '../yedekLib/bluetooth3.dart';
// import '../yedekLib/bluetooth5.dart';
// import '../yedekLib/bluetooth6.dart';
// import '../yedekLib/loading.dart';
// import 'package:flutter/material.dart';
// import '../yedekLib/config.dart';
// import '../yedekLib/map.dart';
// import '../yedekLib/boatName.dart';
// import 'package:boatapp/bluetooth2.dart';
// import 'package:boatapp/bluetooth.dart';

import 'package:boatapp/bluetooth.dart';
import 'package:boatapp/config.dart';
import 'package:boatapp/password.dart';
import 'package:boatapp/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boatapp/map.dart';

import 'boatName.dart';
import 'loading.dart';
import 'login.dart';
import 'redirect.dart';
// UUID=c048be43-e25d-482e-a5a5-fad044a8fab4

void main() async {
  // await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainStarter());
}

class MainStarter extends StatefulWidget {
  const MainStarter({super.key});

  @override
  State<MainStarter> createState() => _MainStarterState();
}

class _MainStarterState extends State<MainStarter> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/bluetooth": (context) => const Bluetooth(),
        "/boatName": (context) => const BoatName(),
        "/configs": (context) => const Config(),
        "/loading": (context) => const Loading(),
        "/login": (context) => const Login(),
        "/main": (context) => const Main(),
        "/googleMapPage": (context) => GoogleMapPage(
              configMarkers: {},
            ),
        "/password": (context) => const Password(),
        "/redirect": (context) => const Redirect(),
        "/settings": (context) => const SettingsPage(),
      },
      title: "BoatApp",
      home: const Redirect(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  Color _backgroundColor = const Color(0xfff4fff6);

  // final AuthService _auth = AuthService();

  // int currentIndex = 1;
  // final pages = <Widget>[
  //   // const Loading(),
  //   const Config(),
  //   const GoogleMapPage(),
  // ];

  // void onItemTapped(int index) {
  //   setState(() {
  //     currentIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            child: IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/login");
                  // AuthService;
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Color(0xffb8095e),
                )),
          ),
          actions: [
            MenuAnchor(
              builder: ((context, controller, child) {
                return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xffb8095e),
                  ),
                );
              }),
              menuChildren: [
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      child: const Text("Dark Mode"),
                      onPressed: () {
                        setState(() {
                          _backgroundColor = const Color(0xff191923);
                        });
                      },
                    ),
                    MenuItemButton(
                      child: const Text("Light Mode"),
                      onPressed: () {
                        setState(() {
                          _backgroundColor = const Color(0xfff4fff6);
                        });
                      },
                    ),
                  ],
                  child: const Text("Tema"),
                )
              ],
            ),
          ],
          // title: Text(
          //   "Ana Menü",
          //   style: TextStyle(
          //     fontSize: 40,
          //     color: Color(0xffb8095e),
          //   ),
          // ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: _backgroundColor,
        // title: Text("Hoş Geldin!"),
        // actions: [
        //   Row(
        //     mainAxisSize: MainAxisSize.max,
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       IconButton(
        //         onPressed: () {},
        //         icon: const Icon(Icons.arrow_back_rounded),
        //         color: Colors.black,
        //       ),
        //       IconButton(
        //         onPressed: () {},
        //         icon: const Icon(Icons.arrow_back_rounded),
        //         color: Colors.black,
        //       ),
        //     ],
        //   )
        // ],

        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: const Text(
                      "Ana menü",
                      style: TextStyle(
                        fontSize: 40,
                        color: Color(0xffb8095e),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/googleMapPage");
                          },
                          child: SizedBox(
                            width: 180,
                            height: 220,
                            child: Card(
                              color: const Color.fromARGB(255, 255, 239, 242),
                              elevation: 0,
                              // margin: EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color.fromARGB(236, 175, 188, 194),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    // width: 500,
                                    // height: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Image(
                                        height: 140,
                                        // width: 250,
                                        image: AssetImage(
                                          "assets/images/map.jpg",
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 14,
                                    // width: ,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // SizedBox(
                                      //   width: 50,
                                      // ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 0, 0),
                                        child: const Text(
                                          "Harita",
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Color(0xffb8095e),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 0, 0),
                                        child:
                                            const Text("Haritayı kontrol et"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/configs");
                          },
                          child: SizedBox(
                            width: 180,
                            height: 220,
                            child: Card(
                              color: const Color.fromARGB(255, 255, 239, 242),
                              elevation: 0,
                              // margin: EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color.fromARGB(236, 175, 188, 194),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    // width: 200,
                                    // height: 100,

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Image(
                                        height: 140,
                                        width: 180,
                                        image: AssetImage(
                                            "assets/images/marker.jpg"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            18, 0, 0, 0),
                                        child: const Text(
                                          "Yer İşaretleri",
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Color(0xffb8095e),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 0, 0),
                                        child: const Text(
                                            "Yer işaretlerini düzenle"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/settings");
                            // Navigator.pushNamed(context, "/googleMapPage");
                          },
                          child: SizedBox(
                            width: 180,
                            height: 220,
                            child: Card(
                              color: const Color.fromARGB(255, 255, 239, 242),
                              elevation: 0,
                              // margin: EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color.fromARGB(236, 175, 188, 194),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                    // width: 500,
                                    // height: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Image(
                                        height: 130,
                                        width: 180,
                                        image: AssetImage(
                                          "assets/images/settings.jpg",
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 22,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 0, 0),
                                        child: const Text(
                                          "Ayarlar",
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Color(0xffb8095e),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 0, 0, 0),
                                        child: const Text("Ayarları değiştir"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/bluetooth");
                            // Navigator.pushNamed(context, "/googleMapPage");
                          },
                          child: SizedBox(
                            width: 180,
                            height: 220,
                            child: Card(
                              color: const Color.fromARGB(255, 255, 239, 242),
                              elevation: 0,
                              // margin: EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color.fromARGB(236, 175, 188, 194),
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                    // width: 500,
                                    // height: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Image(
                                        height: 130,
                                        width: 180,
                                        image: AssetImage(
                                          "assets/images/settings.jpg",
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 22,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 0, 0),
                                        child: const Text(
                                          "Cihazlar",
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Color(0xffb8095e),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            22, 0, 0, 0),
                                        child: const Text(
                                            "Cihazın ile bağlantı kur"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return SafeArea(
    //   child: Scaffold(
    //       body: Column(
    //     children: [
    //       Card(
    //         child: Column(
    //           children: [
    //             ListTile(
    //               leading: const Icon(Icons.map_rounded),
    //               title: const Text("Haritaya göz at"),
    //               subtitle: const Text(
    //                   "Yer işaretleri yerleştirerek rotanı belirle ve cihazına gönder."),
    //               onTap: () {
    //                 Navigator.pushNamed(context, "/googleMapPage");
    //               },
    //             )
    //           ],
    //         ),
    //       )
    //     ],
    //   )),
    // );
    // return Scaffold(
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //   body: IndexedStack(
    //     index: currentIndex,
    //     children: pages,
    //   ),
    //   bottomNavigationBar: BottomAppBar(
    //     shape: CircularNotchedRectangle(),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //       children: [
    //         IconButton(
    //           icon: Icon(Icons.map_rounded),
    //           onPressed: () => onItemTapped(0),
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.settings_rounded),
    //           onPressed: () => onItemTapped(1),
    //         )
    //       ],
    //     ),
    //   ),
    //   // bottomNavigationBar: SizedBox(
    //   //   height: 68,
    //   //   child: BottomNavigationBar(
    //   //     type: BottomNavigationBarType.fixed,
    //   //     backgroundColor: Colors.white,
    //   //     selectedItemColor: Colors.red,
    //   //     unselectedItemColor: Colors.black,
    //   //     iconSize: 30,
    //   //     currentIndex: currentIndex,
    //   //     onTap: (index) => setState(
    //   //       () => currentIndex = index,
    //   //     ),
    //   //     items: const [
    //   //       BottomNavigationBarItem(
    //   //           icon: Icon(
    //   //             Icons.construction,
    //   //             size: 25,
    //   //           ),
    //   //           label: "Config"),
    //   //       BottomNavigationBarItem(
    //   //         icon: Icon(
    //   //           Icons.map_rounded,
    //   //           size: 25,
    //   //         ),
    //   //         label: "Map",
    //   //       ),
    //   //       BottomNavigationBarItem(
    //   //         icon: Icon(
    //   //           Icons.settings,
    //   //           size: 25,
    //   //         ),
    //   //         label: "Settings",
    //   //       ),
    //   //     ],
    //   //   ),
    //   // ),
    // );
  }
}
