import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'dart:math';

const double pi = 3.1415926535897932;
//ITRF96 GRS80 Dönüşüm Parametreleri
const double a = 6378137;
const double b = 6356752.31410;
const double k0 = 0.9996; //3 derece için k0 değeri

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "ITRF KonumaGit",
      home: Iskele(),
    );
  }
}

class Iskele extends StatelessWidget {
  const Iskele({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ITRF KonumaGit'),
      ),
      body: const AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnaEkranState createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  double koordx = 0, koordy = 0, sonuc = 0, enlem = 0, boylam = 0;
  double menlem = 0, mboylam = 0;
  String web = "";
  String gweb = "";
  int dilim = 0;
  //var url = "";

  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  TextEditingController t3 = TextEditingController();

  Future<void> getLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      Geolocator.requestPermission();
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      menlem = position.latitude;
      mboylam = position.longitude;
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  /*@override
  void initState() {
    super.initState();
    getLocation();
  }*/

  cografiyecevir() {
    setState(() {
      koordx = double.parse(t1.text);
      koordy = double.parse(t2.text);
      dilim = int.parse(t3.text);

      double dom = (((dilim + 3) / 6) + 30);
      double yenikoordy = (koordy - 500000) * k0 + 500000;
      double yenikoordx = (koordx * k0);

      //Hesaplama kısmı

      //double f = (a - b) / a;
      //double f1 = 1 / f;
      double e = sqrt(1 - (b / a) * (b / a));
      double eisq = e * e / (1 - (e * e));
      double ei = (1 - sqrt(1 - e * e)) / (1 + sqrt(1 - e * e));
      //double sin1 = (21 * pow(ei, 2) / 16) - (55 * pow(ei, 4) / 32);
      double kc1 = 3 * ei / 2 - 27 * pow(ei, 3) / 32;
      double kc2 = 21 * pow(ei, 2) / 16 - 55 * pow(ei, 4) / 32;
      double kc3 = 151 * pow(ei, 3) / 96;
      double kc4 = 1097 * pow(ei, 4) / 512;
      double x = 500000 - (yenikoordy);
      //double y = yenikoordx;
      double yayuzunlugu = yenikoordx / k0;
      double mu = yayuzunlugu /
          (a * (1 - (e * e / 4) - 3 * pow(e, 4) / 64 - 5 * pow(e, 6) / 256));
      double phi = mu +
          kc1 * sin(2 * mu) +
          kc2 * sin(4 * mu) +
          kc3 * sin(6 * mu) +
          kc4 * sin(8 * mu);
      double c1 = eisq * pow(cos(phi), 2);
      double at1 = tan(phi) * tan(phi);
      double n1 = a / sqrt(1 - e * sin(phi) * e * sin(phi));
      double r1 = a * (1 - e * e) / pow(1 - e * sin(phi) * e * sin(phi), 3 / 2);
      double d = x / (n1 * k0);
      double fact1 = n1 * tan(phi) / r1;
      double fact2 = (pow(d, 2) / 2);
      double fact3 =
          (5 + 3 * at1 + 10 * c1 - 4 * c1 * c1 - 9 * eisq) * pow(d, 4) / 24;
      double fact4 = (61 +
              90 * at1 +
              298 * c1 +
              45 * at1 * at1 -
              252 * eisq -
              3 * c1 * c1) *
          pow(d, 6) /
          720;
      double lofact1 = d;
      double lofact2 = (1 + 2 * at1 + c1) * pow(d, 3) / 6;
      double lofact3 =
          (5 - 2 * c1 + 28 * at1 - 3 * c1 * c1 + 8 * eisq + 24 * at1 * at1) *
              pow(d, 5) /
              120;
      double deltalong = (lofact1 - lofact2 + lofact3) / (cos(phi));
      double zoneDOM = 6 * dom - 183;
      double rawEnlem = 180 * (phi - fact1 * (fact2 + fact3 + fact4)) / pi;

      //Tüm hesaplamalara göre enlem ve boylam hesaplanır
      enlem = rawEnlem;
      boylam = zoneDOM - ((deltalong * 180) / pi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: t2,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Koordinat Y',
                hintText: '515478.53',
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: t1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Koordinat X',
                hintText: '4576513.52',
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: t3,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Dilim No',
                hintText: '27,30,33,36,39,42,45',
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: ElevatedButton(
                child: const Text('Konumu Göster'),
                onPressed: () {
                  cografiyecevir();
                  konumuAc(enlem, boylam);
                },
              )),
          Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: ElevatedButton(
                  onPressed: () async {
                    cografiyecevir();
                    await getLocation();
                    var permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied ||
                        permission == LocationPermission.deniedForever) {
                      // ignore: use_build_context_synchronously
                      _showDialog(context);
                    } else {
                      yoltarifiAl(enlem, boylam, menlem, mboylam);
                    }
                  },
                  child: const Text("Yol Tarifi Al"))),
          const Center(
            child: Text("Hesaplanan Konum"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("E: "),
              Text(enlem.toStringAsFixed(7)),
              const Text(" / B: "),
              Text(boylam.toStringAsFixed(7)),
            ],
          ),
          const Center(
            child: Text("Mevcut Konum"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("E: "),
              Text(menlem.toStringAsFixed(7)),
              const Text(" / B: "),
              Text(mboylam.toStringAsFixed(7)),
            ],
          ),
        ],
      ),
    );
  }
}

void konumuAc(double enlem, double boylam) async {
  bool? deger = await MapLauncher.isMapAvailable(MapType.google);
  if (deger!) {
    MapLauncher.showMarker(
      mapType: MapType.google,
      coords: Coords(enlem, boylam),
      title: 'KonumaGit',
    );
  }
}

void yoltarifiAl(
    double enlem, double boylam, double menlem, double mboylam) async {
  bool? deger = await MapLauncher.isMapAvailable(MapType.google);
  if (deger!) {
    MapLauncher.showDirections(
      mapType: MapType.google,
      origin: Coords(menlem, mboylam),
      destination: Coords(enlem, boylam),
    );
  }
}

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Dikkat"),
        content: const Text(
            "Bu özelliği kullanmanız için konum paylaşımına izin vermelisiniz"),
        actions: <Widget>[
          ElevatedButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
