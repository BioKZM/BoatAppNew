import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  final _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final markerNameController = TextEditingController();
  final markerSpeedController = TextEditingController();

  void showClearButtonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Bütün kayıtlı rotaları silmek istediğine emin misin?",
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    final fireStore = FirebaseFirestore.instance;
                    User? user = FirebaseAuth.instance.currentUser;
                    CollectionReference data = fireStore.collection('users');
                    var userData = data.doc('${user!.email}');
                    await fireStore
                        .collection('users')
                        .doc(user.email)
                        .get()
                        .then((value) async {
                      // print(value['locationConfig']['Rota 1']);
                      await userData.update({'locationConfig': {}});
                    });
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Text(
                    "Evet",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Hayır"),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void showClearButtonDialog2(String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Seçili rotayı silmek istediğine emin misin?",
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    final fireStore = FirebaseFirestore.instance;
                    User? user = FirebaseAuth.instance.currentUser;
                    CollectionReference data = fireStore.collection('users');
                    var userData = data.doc('${user!.email}');
                    await fireStore
                        .collection('users')
                        .doc(user.email)
                        .get()
                        .then((value) async {
                      Map newMap = value['locationConfig'];
                      newMap.remove(name);
                      await userData.update({'locationConfig': newMap});
                    });
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Text(
                    "Evet",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Hayır"),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Center(
    //       child: CircularProgressIndicator(
    //     color: Colors.red,
    //   )),
    // );
    CollectionReference data = _firestore.collection('users');
    var userData = data.doc('${user!.email}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Color(0xffb8095e),
          ),
          onPressed: () {
            // Navigator.pushReplacementNamed(context, "/main");
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded,
                color: Color(0xffb8095e)),
            onPressed: () {
              showClearButtonDialog();
              // final _fireStore = FirebaseFirestore.instance;
              // User? user = FirebaseAuth.instance.currentUser;
              // CollectionReference data = _fireStore.collection('users');
              // var userData = data.doc('${user!.email}');
              // await _fireStore
              //     .collection('users')
              //     .doc(user!.email)
              //     .get()
              //     .then((value) async {
              //   await userData.update({'locationConfig': {}});
              // });
              // Navigator.pushNamed(context, "/googleMapPage");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Text("Selam"),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 10, 0, 0),
                child: const Text(
                  "Kaydedilen rotalar",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 30, color: Color(0xffb8095e)),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          StreamBuilder<DocumentSnapshot>(
              stream: userData.snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.active) {
                  var datas = snapshot.data.data();
                  Map<String, dynamic> configs = datas['locationConfig'];
                  List entryList = [];
                  for (var entry in configs.entries) {
                    entryList.add(entry.key);
                  }
                  if (configs.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                        ),
                        const Text(
                          "Kayıtlı herhangi bir rotan yok. \nRotaları kaydetmek için haritayı kullanabilirsin.",
                          style: TextStyle(
                            color: Color.fromARGB(166, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Icon(Icons.map_rounded,
                            color: Color.fromARGB(166, 0, 0, 0))
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.79,
                          width: MediaQuery.of(context).size.width,
                          child: Align(
                            child: ListView.builder(
                              // reverse: true,
                              itemCount: entryList.length,
                              itemBuilder: (context, index) {
                                if (entryList.isEmpty) {
                                  return Container();
                                  // print(configs);
                                  // return Center(
                                  //   child: Text(
                                  //       "Kayıtlı herhangi bir rotan yok. Rotaları kaydetmek için haritayı kullanabilirsin.",
                                  //       style: TextStyle(color: Colors.red)),
                                  // );
                                } else {
                                  return Card(
                                    child: ListTile(
                                        onLongPress: () {
                                          showClearButtonDialog2(
                                              configs[entryList[index]][0]
                                                  ['routeName']);
                                        },
                                        onTap: () {
                                          List markerList =
                                              configs[entryList[index]];
                                          Map<String, dynamic> markers = {};
                                          for (int x = 0;
                                              x < markerList.length;
                                              x++) {
                                            markers[x.toString()] = [
                                              markerList[x]['markerId'],
                                              markerList[x]['lat'],
                                              markerList[x]['lon'],
                                              markerList[x]['title'],
                                              markerList[x]['snippet']
                                            ];
                                            // markers.add(markersList);
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GoogleMapPage(
                                                configMarkers: markers,
                                              ),
                                            ),
                                          );
                                        },
                                        title: Text(configs[entryList[index]][0]
                                            ['routeName']),
                                        subtitle: Text(
                                            "Kaydedilme tarihi: ${configs[entryList[index]][0]['date']}"),
                                        trailing: MenuAnchor(
                                          builder:
                                              ((context, controller, builder) {
                                            return RotatedBox(
                                              quarterTurns: 2,
                                              child: IconButton(
                                                icon: const Icon(Icons
                                                    .keyboard_control_rounded),
                                                onPressed: () {
                                                  if (controller.isOpen) {
                                                    controller.close();
                                                  } else {
                                                    controller.open();
                                                  }
                                                },
                                              ),
                                            );
                                          }),
                                          menuChildren: [
                                            MenuItemButton(
                                              child: const Text("Düzenle"),
                                              onPressed: () async {
                                                await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          "Yer İşaretini Düzenle",
                                                        ),
                                                        actions: [
                                                          SizedBox(
                                                            width: 300,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                TextFormField(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  controller:
                                                                      markerNameController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    contentPadding:
                                                                        EdgeInsets.fromLTRB(
                                                                            2,
                                                                            -5,
                                                                            0,
                                                                            0),
                                                                    border:
                                                                        OutlineInputBorder(),
                                                                    hintText:
                                                                        "Rota ismi",
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  markerNameController
                                                                      .clear();
                                                                  markerSpeedController
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: const Text(
                                                                    "Kaydet"),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  markerNameController
                                                                      .clear();
                                                                  markerSpeedController
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                        "İptal"),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      );
                                                    });
                                              },
                                            ),
                                            MenuItemButton(
                                              child: const Text(
                                                "Sil",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              onPressed: () {
                                                showClearButtonDialog2(
                                                    configs[entryList[index]][0]
                                                        ['routeName']);
                                              },
                                            ),
                                          ],
                                        )),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  // return Column(
                  //   children: [
                  //     SizedBox(
                  //       height: MediaQuery.of(context).size.height * 0.79,
                  //       width: MediaQuery.of(context).size.width,
                  //       child: Align(
                  //         child: ListView.builder(
                  //           // reverse: true,
                  //           itemCount: entryList.length,
                  //           itemBuilder: (context, index) {
                  //             if (entryList.isEmpty) {
                  //               return Container();
                  //               // print(configs);
                  //               // return Center(
                  //               //   child: Text(
                  //               //       "Kayıtlı herhangi bir rotan yok. Rotaları kaydetmek için haritayı kullanabilirsin.",
                  //               //       style: TextStyle(color: Colors.red)),
                  //               // );
                  //             } else {
                  //               return Card(
                  //                 child: ListTile(
                  //                   onTap: () {
                  //                     List markerList =
                  //                         configs[entryList[index]];
                  //                     Map<String, dynamic> markers = {};
                  //                     for (int x = 0;
                  //                         x < markerList.length;
                  //                         x++) {
                  //                       markers[x.toString()] = [
                  //                         markerList[x]['markerId'],
                  //                         markerList[x]['lat'],
                  //                         markerList[x]['lon'],
                  //                         markerList[x]['title'],
                  //                         markerList[x]['snippet']
                  //                       ];
                  //                       // markers.add(markersList);
                  //                     }
                  //                     Navigator.push(
                  //                       context,
                  //                       MaterialPageRoute(
                  //                         builder: (context) => GoogleMapPage(
                  //                           configMarkers: markers,
                  //                         ),
                  //                       ),
                  //                     );
                  //                   },
                  //                   title: Text(configs[entryList[index]][0]
                  //                       ['routeName']),
                  //                   subtitle: Text(
                  //                       "Kaydedilme tarihi: ${configs[entryList[index]][0]['date']}"),
                  //                 ),
                  //               );
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // );
                } else {
                  return const CircularProgressIndicator(color: Colors.red);
                }
              })
        ],
      ),
    );
  }
}
