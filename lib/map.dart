import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPage extends StatefulWidget {
  // var _markers;
  Map<String, dynamic> configMarkers = {};

  GoogleMapPage({
    super.key,
    required this.configMarkers,
  });

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  // BluetoothConnection conn;

  LatLng? myLocation;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updateLocation();
    _loadMapStyles();
    // var newMarkers = widget.configMarkers;
    // _markers = widget.configMarkers;
    _refreshMarkers(widget.configMarkers);
    // rootBundle.loadString('assets/json/darkMap.json').then((string) {
    //   darkMapStyle = string;
    // });
  }

  late BluetoothConnection connection;
  late GoogleMapController? mapController;
  late GoogleMap googleMap;
  dynamic darkMapStyle;
  dynamic retroMapStyle;
  dynamic aubergineMapStyle;

  BitmapDescriptor? customIcon;
  bool mapControllerInit = false;
  bool buttonBool = true;
  late double distance = 0.0;
  // Set<Marker> configMarkers = {};
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final markerNameController = TextEditingController();
  final markerSpeedController = TextEditingController();
  StreamSubscription<Position>? positionStream;
  final _fireStore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapControllerInit = true;
    // mapController!.setMapStyle(darkMapStyle);
  }

  String generateKey() {
    var key = "";

    for (int x = 0; x < 5; x++) {
      var unique = UniqueKey().toString();
      key += unique.substring(2, unique.length - 2);
    }
    return key;
  }

  double calculateDistance(markerList) {
    var lat1 = (markerList[markerList.length - 2].position.latitude);
    var lon1 = (markerList[markerList.length - 2].position.longitude);
    var lat2 = (markerList[markerList.length - 1].position.latitude);
    var lon2 = (markerList[markerList.length - 1].position.longitude);

    return acos(
            sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1)) *
        6371 *
        19;
  }

  void setCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/pin.png');
  }

  void _updateLocation() {
    var locationOptions = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      intervalDuration: const Duration(seconds: 3),
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationOptions)
            .listen((Position position) {
      setState(() {
        _getCurrentLocation();
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    setCustomMarker();
    Position myPosition = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: false,
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      myLocation = LatLng(myPosition.latitude, myPosition.longitude);
      if (_markers.isEmpty) {
        _markers.add(Marker(
          markerId: const MarkerId("currentLocation"),
          icon: customIcon!,
          position: myLocation!,
        ));
      } else {
        Set<Marker> markersNew = {};
        List<Marker> markersList = _markers.toList();
        markersList[0] = Marker(
          markerId: const MarkerId("currentLocation"),
          icon: customIcon!,
          position: myLocation!,
        );
        markersNew.addAll(markersList);
        _markers = markersNew;
      }
      if (mapControllerInit) {
        _moveCamera();
      }
    });
  }

  Future _loadMapStyles() async {
    darkMapStyle = await rootBundle.loadString('assets/json/darkMap.json');
    retroMapStyle = await rootBundle.loadString('assets/json/retroMap.json');
    aubergineMapStyle =
        await rootBundle.loadString('assets/json/aubergineMap.json');
  }

  void _moveCamera() {
    var cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(target: myLocation!, zoom: 18));
    mapController?.animateCamera(cameraUpdate);
  }

  void setPolylines(markers, id) {
    List markerList = markers.toList();
    if (markerList.length > 2) {
      final LatLng startPoint = markerList[markerList.length - 2].position;
      final LatLng endPoint = markerList[markerList.length - 1].position;
      final Polyline poly = Polyline(
        polylineId: PolylineId(id),
        points: [startPoint, endPoint],
        width: 12,
        patterns: const [
          PatternItem.dot,
        ],
        color: Colors.red,
      );
      _polylines.add(poly);
    }
  }

  void refreshPolylines(markers) {
    List<Marker> markersList = markers.toList();
    Set<Polyline> polyNew = {};
    for (int x = 1; x < markersList.length - 1; x++) {
      LatLng startPoint = markersList[x].position;
      LatLng endPoint = markersList[x + 1].position;
      Polyline poly = Polyline(
        polylineId: PolylineId(x.toString()),
        points: [startPoint, endPoint],
        width: 12,
        patterns: const [PatternItem.dot],
        color: Colors.red,
      );
      polyNew.add(poly);
    }
    _polylines = polyNew;
  }

  void addMarker(id, latLng, {dynamic snippet = "", dynamic title = ""}) {
    _markers.add(Marker(
      markerId: MarkerId(id),
      infoWindow: InfoWindow(
        title: "Marker ${_markers.length}",
        snippet: "Toplam mesafe: ${distance.toStringAsFixed(0)} m",
        onTap: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "Yer İşaretini Düzenle",
                ),
                actions: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: TextFormField(
                          controller: markerNameController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(2, -5, 0, 0),
                            border: OutlineInputBorder(),
                            hintText: "Yer işareti ismi",
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          // height: 40,
                          // width: 200,
                          child: TextFormField(
                        controller: markerSpeedController,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            border: OutlineInputBorder(),
                            hintText: "Yer işareti hızı"),
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          markerNameController.clear();
                          markerSpeedController.clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Kaydet"),
                      ),
                      TextButton(
                        onPressed: () {
                          markerNameController.clear();
                          markerSpeedController.clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text("İptal"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            Set<Marker> markersNew = {};
                            List<Marker> markersList = _markers.toList();
                            int index = markersList.indexOf(_markers.firstWhere(
                                (element) =>
                                    element.markerId.value.toString() == id));

                            markersList.removeAt(index);
                            markersNew.addAll(markersList);
                            _markers = markersNew;
                            refreshPolylines(_markers);
                            Navigator.of(context).pop();
                          });
                        },
                        child: const Text(
                          "Yer İşaretini Sil",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  )
                ],
              );
            },
          );
        },
      ),
      position: latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    if (_markers.length > 2) {
      setPolylines(_markers, id);
    }
    // sendDataWithBluetooth(_markers);
  }

  void _onMapLongPressed(LatLng latLng) {
    var id = generateKey();

    if (_markers.length == 1) {
      setState(() {
        addMarker(id, latLng);
      });
    } else if (_markers.length > 1) {
      setState(() {
        addMarker(id, latLng);
        distance += calculateDistance(_markers.toList());
      });
      late String calculatedDistance;
      if (distance >= 1000.0) {
        setState(() {
          calculatedDistance =
              "Toplam mesafe : ${(distance / 1000).toStringAsFixed(2)} km";
        });
      } else {
        setState(() {
          calculatedDistance =
              "Toplam mesafe : ${distance.toStringAsFixed(0)} m";
        });
      }
      Marker marker = _markers.toList()[_markers.length - 1];
      Marker newMarker = marker.copyWith(
          infoWindowParam: InfoWindow(
        title: marker.infoWindow.title,
        snippet: calculatedDistance,
        onTap: marker.infoWindow.onTap,
      ));
      setState(() {
        _markers.remove(marker);
        _markers.add(newMarker);
      });
    }
  }

  void sendDataWithBluetooth(markers, {dynamic flow = "send"}) {
    if (flow == "stop") {
      String jsonString = jsonEncode("stop");
      Uint8List uint8List = Uint8List.fromList(utf8.encode(jsonString));
      connection.output.add(uint8List);
      connection.output.allSent.then((_) {});
    } else {
      String jsonString = jsonEncode(markers);
      Uint8List uint8List = Uint8List.fromList(utf8.encode(jsonString));

      connection.output.add(uint8List);
      connection.output.allSent.then((_) {
        // print('JSON verisi gönderildi: $jsonString');
      });
    }
  }

  void showClearButtonDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Bütün yer işaretlerini silmek istediğine emin misin?",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        Marker currentLocation = _markers.toList()[0];
                        Set<Marker> emptyMarkersSet = {currentLocation};
                        Set<Polyline> emptyPolylinesSet = {};
                        _markers = emptyMarkersSet;
                        _polylines = emptyPolylinesSet;
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
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
              ),
            ],
          ),
        );
      },
    );
  }

  void showClearButtonDialog2() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Bütün işaretçileri silmek istediğine emin misin?",
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      Marker currentLocation = _markers.toList()[0];
                      Set<Marker> emptyMarkersSet = {currentLocation};
                      Set<Polyline> emptyPolylinesSet = {};
                      _markers = emptyMarkersSet;
                      _polylines = emptyPolylinesSet;
                    });
                    Navigator.of(context).pop();
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

  void showConfirmationDialog() {
    // const SnackBar snackBar = SnackBar(
    //   content: Text("Veriler gönderildi."),
    //   behavior: SnackBarBehavior.floating,
    //   margin: EdgeInsets.only(bottom: 70),
    //   dismissDirection: DismissDirection.none,
    // );
    // const SnackBar snackBar2 = SnackBar(
    //   content: Align(
    //     alignment: Alignment.topCenter,
    //     child: Text("Veriler gönderildi."),
    //   ),
    //   width: 300,
    //   behavior: SnackBarBehavior.floating,
    //   // margin: EdgeInsets.only(bottom: 70),
    //   dismissDirection: DismissDirection.none,
    // );
    SnackBar snackBar3 = SnackBar(
      content: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 50, 50, 50),
            border: Border.all(
                width: 2, color: const Color.fromARGB(255, 50, 50, 50)),
            borderRadius: BorderRadius.circular(3)),
        margin: const EdgeInsets.only(bottom: 80),
        width: 450,
        height: 38,
        child: const Align(
          alignment: Alignment.center,
          child: Text(
            "Veriler gönderildi.",
            style: TextStyle(fontSize: 17),
          ),
        ),
      ),
      dismissDirection: DismissDirection.down,
      backgroundColor: Colors.transparent,
      elevation: 1000,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar3);
    // showModalBottomSheet(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return Container(
    //       padding: const EdgeInsets.all(25),
    //       child: const Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Align(
    //             alignment: AlignmentDirectional(0, -40),
    //             child: Text("Veriler başarıyla cihaza gönderildi.",
    //                 style: TextStyle(fontSize: 20)),
    //           )
    //         ],
    //       ),
    //     );
    //   },
    //   isDismissible: false,
    //   barrierColor: Color.fromARGB(21, 0, 0, 0),
    // );
    // Future.delayed(const Duration(seconds: 2), () {
    //   Navigator.of(context).pop();
    // });
  }

  void sendDataToDatabase(Set<Marker> markers) async {
    CollectionReference data = _fireStore.collection('users');
    var userData = data.doc('${user!.email}');
    DateTime today = DateTime.now();
    String date = "${today.day}/${today.month}/${today.year}";
    int x = 0;
    await _fireStore
        .collection('users')
        .doc(user!.email)
        .get()
        .then((value) async {
      Map<String, dynamic> mapOfMarkers = value['locationConfig'];
      String name = "Rota ${mapOfMarkers.length + 1}";
      // List mapOfMarkers = value['locationConfig'];
      List<Map<String, dynamic>> markersData = [];
      // markers.remove(value)
      // markers = markers.toList();
      List<Marker> tempMarkers = markers.toList();
      // tempMarkers.removeAt(0);
      markers = tempMarkers.toSet();
      for (var marker in markers) {
        if (x == 0) {
          markersData.add(
            {
              'routeName': name,
              'markerId': marker.markerId.value,
              'lat': marker.position.latitude,
              'lon': marker.position.longitude,
              'title': marker.infoWindow.title,
              'snippet': marker.infoWindow.snippet,
              'date': date,
            },
          );
          x += 1;
        } else {
          markersData.add(
            {
              'markerId': marker.markerId.value,
              'lat': marker.position.latitude,
              'lon': marker.position.longitude,
              'title': marker.infoWindow.title,
              'snippet': marker.infoWindow.snippet,
            },
          );
        }
      }
      mapOfMarkers[name] = markersData;
      // mapOfMarkers.add(markersData);
      await userData.update({'locationConfig': mapOfMarkers});
    });
  }

  void changeButtonType() {
    setState(() {
      buttonBool = !buttonBool;
    });
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
        255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
  }

  int _refreshMarkers(configMarkers) {
    if (configMarkers.length == 0) {
      return 0;
      // continue;
    } else {
      setState(() {
        _markers = {};
        for (int x = 0; x < configMarkers.length; x++) {
          addMarker(
              configMarkers[x.toString()][0],
              LatLng(configMarkers[x.toString()][1],
                  configMarkers[x.toString()][2]),
              title: configMarkers[x.toString()][3],
              snippet: configMarkers[x.toString()][4]);
        }
      });

      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget sendButton = FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(
            color: Color.fromARGB(255, 14, 121, 178),
          ),
        ),
        onPressed: () {
          // sendDataWithBluetooth(_markers);
          sendDataToDatabase(_markers);
          showConfirmationDialog();
          changeButtonType();
        },
        backgroundColor: const Color.fromARGB(255, 14, 121, 178),
        child: const Icon(Icons.send));
    Widget stopButton = FloatingActionButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: Color.fromARGB(255, 191, 19, 99))),
        onPressed: () {
          // sendDataWithBluetooth(_markers, flow: "stop");
          changeButtonType();
        },
        backgroundColor: const Color.fromARGB(255, 191, 19, 99),
        child: const Icon(Icons.stop));
    // setState(() {});
    return StreamBuilder<Object>(
        stream: null,
        builder: (context, snapshot) {
          return Scaffold(
            body: Align(
              alignment: const AlignmentDirectional(0, -0.30),
              child: myLocation != null
                  ? GestureDetector(
                      child: Scaffold(
                        bottomNavigationBar: BottomAppBar(
                          // color: Colors.black54,
                          height: 100,
                          elevation: 5,
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                  color: const Color(0xffb8095e),
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/configs");
                                  },
                                  icon: const Icon(Icons.pin_drop_rounded)),
                              const SizedBox(
                                width: 10,
                              ),

                              IconButton(
                                color: const Color(0xffb8095e),
                                onPressed: () {
                                  mapController?.setMapStyle(retroMapStyle);
                                },
                                icon: const Icon(
                                    Icons.screen_rotation_alt_rounded,
                                    size: 25),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                color: const Color(0xffb8095e),
                                onPressed: () {
                                  showClearButtonDialog();
                                },
                                icon: const Icon(
                                  Icons.cleaning_services_rounded,
                                  size: 25,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              MenuAnchor(
                                builder: (context, controller, child) {
                                  return IconButton(
                                    color:
                                        const Color.fromARGB(255, 14, 121, 178),
                                    icon: const Icon(Icons.brush_rounded),
                                    onPressed: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    }, // Icons.brush_rounded,
                                    // size: 25,
                                  );
                                },
                                menuChildren: [
                                  MenuItemButton(
                                    child: const Text("Dark Map"),
                                    onPressed: () {
                                      mapController?.setMapStyle(darkMapStyle);
                                    },
                                  ),
                                  MenuItemButton(
                                    child: const Text("Aubergine Map"),
                                    onPressed: () {
                                      mapController
                                          ?.setMapStyle(aubergineMapStyle);
                                    },
                                  ),
                                  MenuItemButton(
                                    child: const Text("Retro Map"),
                                    onPressed: () {
                                      mapController?.setMapStyle(retroMapStyle);
                                    },
                                  ),
                                ],
                              ),
                              // PopupMenuButton<String>(

                              //   // offset: ,
                              //   // position: PopupMenuPosition.under,
                              //   // padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                              //   onSelected: (result) {
                              //     setState(() {
                              //       if (result == "retro") {
                              //         mapController?.setMapStyle(retroMapStyle);
                              //       } else if (result == "dark") {
                              //         mapController?.setMapStyle(darkMapStyle);
                              //       }
                              //       if (result == "aubergine") {
                              //         mapController
                              //             ?.setMapStyle(aubergineMapStyle);
                              //       }
                              //     });
                              //   },
                              //   icon: const Icon(
                              //     Icons.brush_rounded,
                              //     size: 25,
                              //   ),
                              //   itemBuilder: (BuildContext context) {
                              //     return <PopupMenuEntry<String>>[
                              //       const PopupMenuItem<String>(
                              //         value: "retro",
                              //         child: Text("Retro Theme"),
                              //       ),
                              //       const PopupMenuItem<String>(
                              //         value: "dark",
                              //         child: Text("Dark Theme"),
                              //       ),
                              //       const PopupMenuItem<String>(
                              //         value: "aubergine",
                              //         child: Text("Aubergine Theme"),
                              //       ),
                              //     ];
                              //     // return "";
                              //   },
                              // )
                              // IconButton(
                              //   color: const Color.fromARGB(255, 191, 19, 99),
                              //   onPressed: () {
                              //     mapController?.setMapStyle(aubergineMapStyle);
                              //   },
                              //   icon: const Icon(Icons.thermostat, size: 30),
                              // )
                            ],
                          ),
                        ),
                        floatingActionButton: Container(
                          // onPressed: () {},
                          child: buttonBool != false ? sendButton : stopButton,
                        ),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.endContained,
                        // floatingActionButton: Wrap(
                        //   direction: Axis.vertical,
                        //   children: <Widget>[
                        //     Container(
                        //       margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        //       child: FloatingActionButton(
                        //         onPressed: () {
                        //           showClearButtonDialog();
                        //         },
                        //         backgroundColor: Colors.red,
                        //         child: const Icon(
                        //             Icons.cleaning_services_outlined),
                        //       ),
                        //     ),
                        //     Container(
                        //       margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        //       child: FloatingActionButton(
                        //         onPressed: () {
                        //           setState(() {
                        //             mapController?.setMapStyle(darkMapStyle);
                        //             // FloatingActionButton().backgroundColor =
                        //             // // sendData();
                        //             // _polylines = {};
                        //             // print(_markers);
                        //             // print(_polylines);
                        //             // List<Marker> newMarkers =
                        //             //     _markers.toList().reversed.toList();
                        //             // List<Polyline> newPolylines =
                        //             //     _polylines.toList().reversed.toList();
                        //             // _markers = {_markers.toList()[0]};
                        //             // // _markers = _markers.toList();
                        //             // newMarkers.forEach((element) {
                        //             //   _markers.add(element);
                        //             // });
                        //             // newPolylines.forEach((element) {
                        //             //   _polylines.add(element);
                        //             // });
                        //             // refreshPolylines(_markers);
                        //           });
                        //           // showClearButtonDialog();
                        //           print("Oyunun yönünü değiştir!");
                        //         },
                        //         backgroundColor: Colors.red,
                        //         child: const Icon(
                        //             Icons.screen_rotation_alt_rounded),
                        //       ),
                        //     ),
                        //     Container(
                        //       margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        //       child:
                        //           buttonBool != false ? sendButton : stopButton,
                        //     ),
                        //   ],
                        // ),
                        // floatingActionButtonLocation:
                        //     FloatingActionButtonLocation.miniStartFloat,
                        body: Stack(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height - 30,
                              child: GoogleMap(
                                // mapType: MapType.terrain,
                                mapToolbarEnabled: false,
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                    target: myLocation!, zoom: 19.0),
                                markers: _markers,
                                onLongPress: _onMapLongPressed,
                                polylines: _polylines,
                                zoomControlsEnabled: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 150,
                              // color: const Color.fromARGB(121, 0, 0, 0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.black),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Harita yükleniyor...",
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        getRandomColor()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
            ),
          );
        });
  }
}
