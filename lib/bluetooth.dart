// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:boatapp/map.dart';

// import 'bluetooth2.dart';
class Bluetooth extends StatefulWidget {
  const Bluetooth({super.key});

  @override
  State<Bluetooth> createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {
  final List<BluetoothDevice> devicesList = [];
  late BluetoothConnection conn;
  bool isConnecting = true;
  Widget closeConnectionButton = const Text("");
  bool isDisconnecting = false;

  void requestPermission() async {
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();
    }
  }

  void Function()? showModal() {
    setState(() {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    "Cihaz Bağlantısı Başarılı.",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        child: const Text("Tamam"),
                      ),
                    ],
                  ),
                ]));
          });
    });
    return null;
  }

  void Function()? showModal2() {
    // setState()
    setState(() {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    "Cihaz Bağlanıtısı Başarısız.",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        child: const Text("Tamam"),
                      ),
                    ],
                  ),
                ]));
          });
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          FutureBuilder(
              future: FlutterBluetoothSerial.instance.getBondedDevices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<BluetoothDevice>? data = snapshot.data;
                  return Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 50,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          itemCount: data!.length,
                          itemBuilder: (context, index) {
                            BluetoothDevice device = data[index];
                            return ListTile(
                              title: Text(device.name!),
                              subtitle: Text(device.address.toString()),
                              // trailing: Text(""),
                              onTap: () async {
                                setState(() {
                                  closeConnectionButton = ElevatedButton(
                                    onPressed: (() async {
                                      await conn.close();
                                    }),
                                    child: const Text("Bağlantıyı Kapa"),
                                  );
                                });
                                BluetoothConnection.toAddress(device.address)
                                    .then((connection) {
                                  setState(() {
                                    conn = connection;
                                    Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                            settings:
                                                RouteSettings(arguments: conn),
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) {
                                              return GoogleMapPage(
                                                configMarkers: {},
                                              );
                                            }));
                                  });
                                  print("Connected to ${device.name}");
                                  var dataList = [
                                    {
                                      "Sequence": 1,
                                      "Latitude": 36.792,
                                      "Longitude": 34.72,
                                      "Speed": 20
                                    },
                                    {
                                      "Sequence": 2,
                                      "Latitude": 36.801,
                                      "Longitude": 35.70,
                                      "Speed": 20
                                    },
                                    {
                                      "Sequence": 3,
                                      "Latitude": 36.8111,
                                      "Longitude": 34.75,
                                      "Speed": 20
                                    }
                                  ];

                                  String jsonString = jsonEncode(dataList);
                                  Uint8List uint8List = Uint8List.fromList(
                                      utf8.encode(jsonString));

                                  connection.output.add(uint8List);
                                  connection.output.allSent.then((_) {
                                    print(
                                        'JSON verisi gönderildi: $jsonString');
                                  });
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),
        ],
      )),
    );
  }
// }
}
