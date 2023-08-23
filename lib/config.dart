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
      body: Center(
        child: Column(
          children: [
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
                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.87,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: entryList.length,
                            itemBuilder: (context, index) {
                              if (entryList.isEmpty) {
                                return Container();
                              } else {
                                return Card(
                                  child: ListTile(
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
                                            builder: (context) => GoogleMapPage(
                                              configMarkers: markers,
                                            ),
                                          ),
                                        );
                                      },
                                      title: Text(configs[entryList[index]]
                                          [index]['routeName'])),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator(color: Colors.red);
                  }
                })
          ],
        ),
      ),
    );
  }
}
